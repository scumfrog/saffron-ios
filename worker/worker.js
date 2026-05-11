/**
 * Saffron — Recipe Extraction Worker
 *
 * POST /extract   { url: string }
 * → ExtractedRecipe JSON
 *
 * Uses Cloudflare Workers AI — no external API key needed.
 * Requires the AI binding in wrangler.toml:
 *   [ai]
 *   binding = "AI"
 */

export default {
  async fetch(request, env) {
    // CORS preflight
    if (request.method === 'OPTIONS') {
      return corsResponse(new Response(null, { status: 204 }));
    }

    if (request.method !== 'POST') {
      return corsResponse(json({ message: 'Method not allowed' }, 405));
    }

    // Parse body
    let body;
    try {
      body = await request.json();
    } catch {
      return corsResponse(json({ message: 'Invalid JSON body' }, 400));
    }

    const rawURL = body?.url;
    if (!rawURL || typeof rawURL !== 'string') {
      return corsResponse(json({ message: '"url" field is required' }, 400));
    }

    let url;
    try {
      url = new URL(rawURL);
    } catch {
      return corsResponse(json({ message: `Invalid URL: ${rawURL}` }, 400));
    }

    // Fetch the webpage
    let html;
    try {
      const pageRes = await fetch(url.toString(), {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
          'Accept': 'text/html,application/xhtml+xml',
          'Accept-Language': 'es,en;q=0.9',
        },
        redirect: 'follow',
        cf: { cacheTtl: 300 },
      });

      if (!pageRes.ok) {
        return corsResponse(json({ message: `Page returned ${pageRes.status}` }, 502));
      }

      html = await pageRes.text();
    } catch (e) {
      return corsResponse(json({ message: `Failed to fetch page: ${e.message}` }, 502));
    }

    // Extract og:image BEFORE stripping tags
    const ogImage = extractOgImage(html);

    // Extract visible text from HTML (strip tags)
    const text = stripTags(html).substring(0, 12000);

    // Call Cloudflare Workers AI
    let aiResult;
    try {
      aiResult = await env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
        messages: [
          {
            role: 'system',
            content: 'You are a recipe extraction assistant. Extract recipe data from webpage text and return it as valid JSON only. No markdown, no explanation.',
          },
          {
            role: 'user',
            content: buildPrompt(url.toString(), text),
          },
        ],
        max_tokens: 2048,
        temperature: 0.1,
      });
    } catch (e) {
      return corsResponse(json({ message: `AI error: ${e.message}` }, 502));
    }

    const content = aiResult?.response ?? '';

    // Parse AI JSON response
    let recipe;
    try {
      const cleaned = content
        .replace(/^```(?:json)?\n?/, '')
        .replace(/\n?```$/, '')
        .trim();
      recipe = JSON.parse(cleaned);
    } catch {
      return corsResponse(json({ message: 'Could not parse recipe from AI response' }, 502));
    }

    if (recipe?.error) {
      return corsResponse(json({ message: recipe.error }, 422));
    }

    // Inject og:image if AI didn't find a cover URL
    if (ogImage && !recipe.coverURL) {
      recipe.coverURL = ogImage;
    }

    // Sanitize: quantity must always be a number
    if (Array.isArray(recipe.ingredients)) {
      recipe.ingredients = recipe.ingredients.map(ing => ({
        ...ing,
        quantity: typeof ing.quantity === 'number' ? ing.quantity : 0,
      }));
    }

    // Normalize difficulty to English canonical values
    if (recipe.difficulty) {
      const d = String(recipe.difficulty).toLowerCase();
      if (d === 'easy' || d === 'fácil' || d === 'facil' || d === 'fácil') recipe.difficulty = 'easy';
      else if (d === 'medium' || d === 'media' || d === 'medio') recipe.difficulty = 'medium';
      else if (d === 'hard' || d === 'difícil' || d === 'dificil' || d === 'alta') recipe.difficulty = 'hard';
      else recipe.difficulty = 'easy';
    }

    return corsResponse(json(recipe, 200));
  },
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

function buildPrompt(url, text) {
  return `Extract the recipe from this webpage. URL: ${url}

Return ONLY a JSON object with this exact schema (no markdown, no extra text):
{
  "title": string,
  "coverURL": string | null,
  "sourceLabel": string,
  "timeMin": number | null,
  "servings": number | null,
  "difficulty": "easy" | "medium" | "hard" | null,
  "tags": string[],
  "ingredients": [{ "quantity": number, "unit": string, "name": string }],
  "steps": string[]
}

Rules:
- "sourceLabel": website or account name (e.g. "@cocina_de_eva", "El Comidista")
- "difficulty": use "easy", "medium", or "hard" (not translated values)
- "quantity": always a number (use 1 if not applicable, 0 for "al gusto")
- "unit": unit string ("g", "ml", "dientes", "cda") or empty string ""
- "tags": 2–6 lowercase tags in the recipe's language
- If no recipe found: { "error": "No recipe found on this page" }

Webpage text:
${text}`;
}

function extractOgImage(html) {
  const match = html.match(/<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)["']/i)
    ?? html.match(/<meta[^>]+content=["']([^"']+)["'][^>]+property=["']og:image["']/i);
  return match ? match[1] : null;
}

function stripTags(html) {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/\s{2,}/g, ' ')
    .trim();
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function corsResponse(response) {
  const headers = new Headers(response.headers);
  headers.set('Access-Control-Allow-Origin', '*');
  headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  headers.set('Access-Control-Allow-Headers', 'Content-Type');
  return new Response(response.body, { status: response.status, headers });
}
