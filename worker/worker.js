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

    // Route guard — accept /v1/extract (current) and /extract (legacy, v1.0 app)
    const pathname = new URL(request.url).pathname;
    if (pathname !== '/v1/extract' && pathname !== '/extract') {
      return corsResponse(json({ message: 'Not found' }, 404));
    }

    // API key guard — only enforced if WORKER_API_KEY secret is configured.
    // Set via: wrangler secret put WORKER_API_KEY
    if (env.WORKER_API_KEY) {
      const providedKey = request.headers.get('X-API-Key') ?? '';
      if (providedKey !== env.WORKER_API_KEY) {
        return corsResponse(json({ message: 'Unauthorized' }, 401));
      }
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

    // ── Path 1: JSON-LD structured data ──────────────────────────────────────
    // Most recipe sites (WordPress/WPRM, food blogs) embed schema.org/Recipe in
    // a <script type="application/ld+json"> block.  Parse it directly — no AI
    // tokens needed, no 12 000-char truncation issue.
    const ldRecipe = extractJsonLdRecipe(html);
    if (ldRecipe) {
      const recipe = mapJsonLdToRecipe(ldRecipe, url.toString(), ogImage);
      normalizeRecipe(recipe);
      return corsResponse(json(recipe, 200));
    }

    // ── Path 2: AI text extraction (fallback) ─────────────────────────────────
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

    normalizeRecipe(recipe);

    return corsResponse(json(recipe, 200));
  },
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

/**
 * Find the first schema.org/Recipe node in any <script type="application/ld+json">
 * block on the page.  Handles both top-level objects and @graph arrays.
 */
function extractJsonLdRecipe(html) {
  const scriptRe = /<script[^>]+type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi;
  let match;
  while ((match = scriptRe.exec(html)) !== null) {
    let data;
    try { data = JSON.parse(match[1]); } catch { continue; }

    const node = findRecipeNode(data);
    if (node) return node;
  }
  return null;
}

function findRecipeNode(data) {
  if (!data) return null;
  // Unwrap @graph array
  if (Array.isArray(data['@graph'])) {
    for (const item of data['@graph']) {
      const found = findRecipeNode(item);
      if (found) return found;
    }
  }
  // Top-level array
  if (Array.isArray(data)) {
    for (const item of data) {
      const found = findRecipeNode(item);
      if (found) return found;
    }
  }
  // Check @type (may be a string or array)
  const type = data['@type'];
  if (typeof type === 'string' && type.toLowerCase().includes('recipe')) return data;
  if (Array.isArray(type) && type.some(t => String(t).toLowerCase().includes('recipe'))) return data;
  return null;
}

/**
 * Map a schema.org/Recipe JSON-LD node to our ExtractedRecipe format.
 */
function mapJsonLdToRecipe(ld, pageURL, ogImage) {
  const title = textValue(ld.name) || '';

  // Cover image: schema.org image can be string, array, or ImageObject
  let coverURL = ogImage ?? null;
  if (ld.image) {
    const img = Array.isArray(ld.image) ? ld.image[0] : ld.image;
    const candidate = typeof img === 'string' ? img : (img?.url ?? img?.contentUrl ?? null);
    if (candidate) coverURL = candidate;
  }

  // Source label from URL hostname
  const host = (() => { try { return new URL(pageURL).hostname.replace(/^www\./, ''); } catch { return ''; } })();

  // Duration: ISO 8601 PT\d+[HM]
  const totalTime = parseDurationMin(ld.totalTime) ?? parseDurationMin(ld.cookTime) ?? null;

  // Servings
  const servings = parseServings(ld.recipeYield) ?? null;

  // Ingredients
  const ingredients = parseIngredients(ld.recipeIngredient ?? []);

  // Steps
  const steps = parseSteps(ld.recipeInstructions ?? []);

  // Tags: keywords + recipeCategory + recipeCuisine
  const tagSources = [
    ...(Array.isArray(ld.keywords) ? ld.keywords : (ld.keywords ? [ld.keywords] : [])),
    ...(Array.isArray(ld.recipeCategory) ? ld.recipeCategory : (ld.recipeCategory ? [ld.recipeCategory] : [])),
    ...(Array.isArray(ld.recipeCuisine) ? ld.recipeCuisine : (ld.recipeCuisine ? [ld.recipeCuisine] : [])),
  ];
  const tags = tagSources
    .flatMap(t => t.split(/[,;]/))
    .map(t => t.trim().toLowerCase())
    .filter(Boolean)
    .slice(0, 6);

  return { title, coverURL, sourceLabel: host, timeMin: totalTime, servings, difficulty: null, tags, ingredients, steps };
}

// ── JSON-LD parsing utilities ──────────────────────────────────────────────

function textValue(v) {
  if (!v) return '';
  if (typeof v === 'string') return v.trim();
  if (typeof v === 'object') return String(v['@value'] ?? v.name ?? '').trim();
  return String(v).trim();
}

/** Parse ISO 8601 duration like PT1H30M or PT45M → minutes */
function parseDurationMin(iso) {
  if (!iso) return null;
  const m = String(iso).match(/PT(?:(\d+)H)?(?:(\d+)M)?/i);
  if (!m) return null;
  return (parseInt(m[1] ?? '0', 10) * 60) + parseInt(m[2] ?? '0', 10) || null;
}

/** Parse recipeYield: "4 servings", "4-6", 4 → first integer */
function parseServings(yield_) {
  if (!yield_) return null;
  const s = Array.isArray(yield_) ? yield_[0] : yield_;
  const m = String(s).match(/\d+/);
  return m ? parseInt(m[0], 10) : null;
}

/**
 * Parse recipeIngredient strings like "300 g de azúcar moreno"
 * into { quantity, unit, name }.
 * Best-effort — unit list covers the most common Spanish/English abbreviations.
 */
function parseIngredients(list) {
  const UNITS = [
    'kg','g','mg','l','ml','cl','dl',
    'taza','tazas','cup','cups',
    'cdta','cdtas','cucharadita','cucharaditas','tsp','teaspoon','teaspoons',
    'cda','cdas','cucharada','cucharadas','tbsp','tablespoon','tablespoons',
    'diente','dientes','clove','cloves',
    'pizca','pizcas','pinch','punzada',
    'rama','ramas','sprig','sprigs',
    'hoja','hojas','leaf','leaves',
    'rebanada','rebanadas','slice','slices',
    'trozo','trozos','piece','pieces',
    'paquete','paquetes','packet','packets',
    'lata','latas','can','cans',
    'bote','botes','jar','jars',
  ];
  const unitPattern = new RegExp(`^(${UNITS.join('|')})\\.?\\s*`, 'i');

  return list.map(raw => {
    const str = textValue(raw).trim();
    // Match leading number (int, decimal, or fraction like 1/2)
    const numMatch = str.match(/^(\d+(?:[.,]\d+)?(?:\s*\/\s*\d+)?)\s*/);
    if (!numMatch) return { quantity: 0, unit: '', name: str };

    let qty = numMatch[1].replace(',', '.');
    // Resolve fractions (e.g. "1/2" → 0.5)
    if (qty.includes('/')) {
      const [n, d] = qty.split('/').map(s => parseFloat(s.trim()));
      qty = d ? n / d : parseFloat(qty);
    } else {
      qty = parseFloat(qty);
    }

    const rest = str.slice(numMatch[0].length).trimStart();
    const uMatch = rest.match(unitPattern);
    const unit = uMatch ? uMatch[1].toLowerCase() : '';
    const name = rest.slice(uMatch ? uMatch[0].length : 0)
      .replace(/^de\s+/i, '')   // strip Spanish "de" connector ("300 g de azúcar" → "azúcar")
      .trim();

    return { quantity: qty, unit, name: name || str };
  });
}

/** Parse recipeInstructions: array of strings or HowToStep objects */
function parseSteps(instructions) {
  if (!Array.isArray(instructions)) return [];
  const steps = [];
  for (const item of instructions) {
    if (typeof item === 'string') {
      const t = item.trim();
      if (t) steps.push(t);
    } else if (item['@type'] === 'HowToSection' && Array.isArray(item.itemListElement)) {
      // Recurse into sections
      steps.push(...parseSteps(item.itemListElement));
    } else {
      const t = textValue(item.text ?? item.name ?? '');
      if (t) steps.push(t);
    }
  }
  return steps;
}

// ── Shared post-processing ─────────────────────────────────────────────────

/** Mutates recipe in-place: sanitize quantity, normalize difficulty. */
function normalizeRecipe(recipe) {
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
    if (d === 'easy' || d === 'fácil' || d === 'facil') recipe.difficulty = 'easy';
    else if (d === 'medium' || d === 'media' || d === 'medio') recipe.difficulty = 'medium';
    else if (d === 'hard' || d === 'difícil' || d === 'dificil' || d === 'alta') recipe.difficulty = 'hard';
    else recipe.difficulty = 'easy';
  }
}

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
