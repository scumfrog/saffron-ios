// screens.jsx — All screens for Cocina
// Reads from window.RECIPES, LISTS, TAGS, and theme tokens via props.

const { useState, useEffect, useRef, useMemo } = React;

// ─── Icon set (SF-style line icons) ──────────────────────────────────────────
const Icon = ({ name, size = 24, color = 'currentColor', stroke = 1.8, fill = 'none' }) => {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill, stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'home': return <svg {...p}><path d="M3 11l9-7 9 7v9a2 2 0 01-2 2h-4v-7h-6v7H5a2 2 0 01-2-2v-9z"/></svg>;
    case 'lists': return <svg {...p}><rect x="3" y="3" width="8" height="8" rx="2"/><rect x="13" y="3" width="8" height="8" rx="2"/><rect x="3" y="13" width="8" height="8" rx="2"/><rect x="13" y="13" width="8" height="8" rx="2"/></svg>;
    case 'search': return <svg {...p}><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></svg>;
    case 'settings': return <svg {...p}><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.7 1.7 0 00-1.8-.3 1.7 1.7 0 00-1 1.5V21a2 2 0 11-4 0v-.1a1.7 1.7 0 00-1.1-1.5 1.7 1.7 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.7 1.7 0 00.3-1.8 1.7 1.7 0 00-1.5-1H3a2 2 0 110-4h.1a1.7 1.7 0 001.5-1.1 1.7 1.7 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.7 1.7 0 001.8.3H9a1.7 1.7 0 001-1.5V3a2 2 0 114 0v.1a1.7 1.7 0 001 1.5 1.7 1.7 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.7 1.7 0 00-.3 1.8V9a1.7 1.7 0 001.5 1H21a2 2 0 110 4h-.1a1.7 1.7 0 00-1.5 1z"/></svg>;
    case 'plus': return <svg {...p}><path d="M12 5v14M5 12h14"/></svg>;
    case 'heart': return <svg {...p} fill={fill==='solid'?color:'none'}><path d="M20.8 4.6a5.5 5.5 0 00-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 10-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 000-7.8z"/></svg>;
    case 'heart-fill': return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M20.8 4.6a5.5 5.5 0 00-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 10-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 000-7.8z"/></svg>;
    case 'share': return <svg {...p}><path d="M12 3v13M7 8l5-5 5 5M5 21h14"/></svg>;
    case 'clock': return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>;
    case 'users': return <svg {...p}><path d="M16 21v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 00-3-3.9M16 3.1a4 4 0 010 7.8"/></svg>;
    case 'flame': return <svg {...p}><path d="M9 21a5 5 0 01-3-9c2 1 3-1 3-3 0-2 2-3 2-6 4 3 7 7 7 12a5 5 0 01-9 6z"/></svg>;
    case 'minus': return <svg {...p}><path d="M5 12h14"/></svg>;
    case 'chevron-right': return <svg {...p}><path d="M9 6l6 6-6 6"/></svg>;
    case 'chevron-left': return <svg {...p}><path d="M15 6l-6 6 6 6"/></svg>;
    case 'chevron-down': return <svg {...p}><path d="M6 9l6 6 6-6"/></svg>;
    case 'check': return <svg {...p}><path d="M5 13l4 4L19 7"/></svg>;
    case 'x': return <svg {...p}><path d="M6 6l12 12M18 6L6 18"/></svg>;
    case 'link': return <svg {...p}><path d="M10 14a5 5 0 007 0l3-3a5 5 0 00-7-7l-1 1"/><path d="M14 10a5 5 0 00-7 0l-3 3a5 5 0 007 7l1-1"/></svg>;
    case 'edit': return <svg {...p}><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.1 2.1 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>;
    case 'plus-list': return <svg {...p}><path d="M3 6h13M3 12h13M3 18h9"/><path d="M19 15v6M16 18h6"/></svg>;
    case 'instagram': return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={stroke}><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="0.8" fill={color}/></svg>;
    case 'globe': return <svg {...p}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 010 18M12 3a14 14 0 000 18"/></svg>;
    case 'pencil-line': return <svg {...p}><path d="M14 4l6 6L8 22H2v-6L14 4z"/></svg>;
    case 'camera': return <svg {...p}><path d="M3 8a2 2 0 012-2h2l2-2h6l2 2h2a2 2 0 012 2v10a2 2 0 01-2 2H5a2 2 0 01-2-2V8z"/><circle cx="12" cy="13" r="4"/></svg>;
    case 'cloud': return <svg {...p}><path d="M18 16a4 4 0 00-1.6-7.7A6 6 0 005 9a4 4 0 00-1 7.9"/></svg>;
    case 'download': return <svg {...p}><path d="M12 3v13M6 11l6 6 6-6M5 21h14"/></svg>;
    case 'play': return <svg width={size} height={size} viewBox="0 0 24 24" fill={color}><path d="M6 4l14 8-14 8z"/></svg>;
    case 'sparkle': return <svg {...p}><path d="M12 3l2 6 6 2-6 2-2 6-2-6-6-2 6-2 2-6z"/></svg>;
    case 'archive': return <svg {...p}><rect x="3" y="3" width="18" height="5" rx="1"/><path d="M5 8v11a2 2 0 002 2h10a2 2 0 002-2V8M9 12h6"/></svg>;
    case 'arrow-up-right': return <svg {...p}><path d="M7 17L17 7M7 7h10v10"/></svg>;
    default: return null;
  }
};
window.Icon = Icon;

// ─── Source badge ────────────────────────────────────────────────────────────
function SourceBadge({ source, label, accent, dark, mini = false }) {
  const map = { instagram: 'instagram', blog: 'globe', manual: 'pencil-line' };
  const ic = map[source] || 'pencil-line';
  if (mini) {
    return <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, opacity: .55 }}>
      <Icon name={ic} size={12} stroke={2}/>
    </span>;
  }
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '5px 10px 5px 8px', borderRadius: 100,
      background: dark ? 'rgba(255,255,255,.1)' : 'rgba(0,0,0,.06)',
      color: dark ? 'rgba(255,255,255,.85)' : '#3a3a3c',
      fontSize: 12, fontWeight: 500, letterSpacing: -.1,
    }}>
      <Icon name={ic} size={13} stroke={2}/>
      <span>{label}</span>
    </div>
  );
}
window.SourceBadge = SourceBadge;

// ─── Inicio (Home) ───────────────────────────────────────────────────────────
function InicioScreen({ accent, dark, recipes, onOpenRecipe, onOpenAdd, onScroll, scrollRef }) {
  const favoritas = recipes.filter(r => r.favorite);
  const recientes = [...recipes].sort((a, b) => a.addedDays - b.addedDays);
  const [pulling, setPulling] = useState(0); // px
  const [refreshing, setRefreshing] = useState(false);
  const startY = useRef(null);

  const onTouchStart = (e) => { if (scrollRef.current.scrollTop <= 0) startY.current = e.touches[0].clientY; };
  const onTouchMove = (e) => {
    if (startY.current == null) return;
    const dy = e.touches[0].clientY - startY.current;
    if (dy > 0 && scrollRef.current.scrollTop <= 0) {
      setPulling(Math.min(dy * 0.5, 90));
      e.preventDefault();
    }
  };
  const onTouchEnd = () => {
    if (pulling > 60) {
      setRefreshing(true);
      setTimeout(() => { setRefreshing(false); setPulling(0); }, 1200);
    } else { setPulling(0); }
    startY.current = null;
  };

  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';

  return (
    <div
      ref={scrollRef}
      onScroll={onScroll}
      onTouchStart={onTouchStart} onTouchMove={onTouchMove} onTouchEnd={onTouchEnd}
      onMouseDown={(e) => { if (scrollRef.current.scrollTop <= 0) { startY.current = e.clientY; } }}
      onMouseMove={(e) => { if (startY.current != null && (e.buttons & 1)) { const dy = e.clientY - startY.current; if (dy > 0) setPulling(Math.min(dy*.5, 90)); } }}
      onMouseUp={onTouchEnd} onMouseLeave={() => { startY.current = null; setPulling(0); }}
      style={{ height: '100%', overflowY: 'auto', overflowX: 'hidden', WebkitOverflowScrolling: 'touch', position: 'relative' }}
    >
      {/* Pull to refresh indicator */}
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, height: pulling,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        opacity: pulling / 60, transition: refreshing ? 'none' : 'height .2s',
        zIndex: 1,
      }}>
        <div style={{
          width: 28, height: 28, borderRadius: '50%',
          border: `2.5px solid ${dark ? 'rgba(255,255,255,.2)' : 'rgba(0,0,0,.1)'}`,
          borderTopColor: accent,
          animation: (refreshing || pulling > 60) ? 'spin 0.8s linear infinite' : 'none',
          transform: refreshing ? 'none' : `rotate(${pulling * 4}deg)`,
        }}/>
      </div>

      {/* Large title (in scroll, will animate via opacity in nav bar) */}
      <div style={{
        padding: '6px 20px 8px', transform: `translateY(${pulling}px)`,
        transition: pulling === 0 && !refreshing ? 'transform .2s' : 'none',
      }}>
        <div style={{ fontSize: 34, fontWeight: 700, letterSpacing: .37, color: text, lineHeight: 1.1 }}>Cocina</div>
        <div style={{ fontSize: 15, color: sec, marginTop: 4 }}>{recipes.length} recetas guardadas</div>
      </div>

      {/* Favoritas carousel */}
      <div style={{ marginTop: 18, transform: `translateY(${pulling}px)`, transition: pulling === 0 && !refreshing ? 'transform .2s' : 'none' }}>
        <SectionHeader title="Favoritas" sub={`${favoritas.length} recetas`} dark={dark}/>
        <div style={{
          display: 'flex', gap: 14, overflowX: 'auto', overflowY: 'hidden',
          padding: '6px 20px 14px', scrollSnapType: 'x mandatory', WebkitOverflowScrolling: 'touch',
          scrollbarWidth: 'none',
        }}>
          {favoritas.map(r => (
            <div key={r.id} onClick={() => onOpenRecipe(r.id)}
              style={{ flexShrink: 0, width: 220, scrollSnapAlign: 'start', cursor: 'pointer' }}>
              <div style={{
                width: '100%', height: 280, borderRadius: 18, overflow: 'hidden',
                position: 'relative', background: '#ddd',
                boxShadow: dark ? '0 8px 20px rgba(0,0,0,.45)' : '0 4px 14px rgba(0,0,0,.08)',
              }}>
                <img src={r.cover} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                  onError={(e) => { e.target.style.display='none'; e.target.parentElement.style.background = `linear-gradient(135deg, ${accent}, ${accent}dd)`; }}/>
                <div style={{
                  position: 'absolute', inset: 0,
                  background: 'linear-gradient(180deg, transparent 50%, rgba(0,0,0,.65))',
                }}/>
                <div style={{
                  position: 'absolute', top: 12, right: 12, width: 32, height: 32,
                  borderRadius: '50%', background: 'rgba(0,0,0,.35)', backdropFilter: 'blur(8px)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <Icon name="heart-fill" size={16} color="#fff"/>
                </div>
                <div style={{
                  position: 'absolute', bottom: 14, left: 14, right: 14, color: '#fff',
                }}>
                  <div style={{ fontSize: 17, fontWeight: 600, lineHeight: 1.2, textShadow: '0 1px 4px rgba(0,0,0,.4)' }}>{r.title}</div>
                  <div style={{ display: 'flex', gap: 10, marginTop: 6, fontSize: 12, opacity: .9 }}>
                    <span style={{ display: 'inline-flex', gap: 4, alignItems: 'center' }}><Icon name="clock" size={12}/> {r.timeMin} min</span>
                    <span style={{ display: 'inline-flex', gap: 4, alignItems: 'center' }}><Icon name="users" size={12}/> {r.servings}</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Recientes list */}
      <div style={{ marginTop: 8, paddingBottom: 120, transform: `translateY(${pulling}px)`, transition: pulling === 0 && !refreshing ? 'transform .2s' : 'none' }}>
        <SectionHeader title="Recientes" sub="Añadidas este mes" dark={dark}/>
        <div style={{
          margin: '4px 16px 0', borderRadius: 18, overflow: 'hidden',
          background: dark ? '#1c1c1e' : '#fff',
          boxShadow: dark ? 'none' : '0 1px 2px rgba(0,0,0,.04)',
        }}>
          {recientes.slice(0, 8).map((r, i) => (
            <SwipeRow key={r.id} accent={accent} dark={dark}
              onFav={() => {}} onDelete={() => {}}>
              <div onClick={() => onOpenRecipe(r.id)} style={{
                display: 'flex', gap: 12, padding: '10px 14px', alignItems: 'center', cursor: 'pointer',
                borderTop: i > 0 ? `.5px solid ${dark ? 'rgba(255,255,255,.08)' : 'rgba(0,0,0,.07)'}` : 'none',
              }}>
                <div style={{ width: 56, height: 56, borderRadius: 12, overflow: 'hidden', flexShrink: 0, background: '#ddd' }}>
                  <img src={r.cover} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }}/>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 15, fontWeight: 600, color: text, letterSpacing: -.2,
                    overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{r.title}</div>
                  <div style={{ display: 'flex', gap: 10, marginTop: 4, fontSize: 12, color: sec, alignItems: 'center' }}>
                    <span style={{ display: 'inline-flex', gap: 3, alignItems: 'center' }}><Icon name="clock" size={11}/> {r.timeMin} min</span>
                    <span>·</span>
                    <span style={{ display: 'inline-flex', gap: 3, alignItems: 'center' }}><Icon name="users" size={11}/> {r.servings}</span>
                    <span>·</span>
                    <SourceBadge source={r.source} mini dark={dark}/>
                  </div>
                </div>
                {r.favorite && <Icon name="heart-fill" size={14} color={accent}/>}
                <Icon name="chevron-right" size={14} color={dark ? 'rgba(255,255,255,.25)' : 'rgba(60,60,67,.3)'} stroke={2.5}/>
              </div>
            </SwipeRow>
          ))}
        </div>
      </div>
    </div>
  );
}
window.InicioScreen = InicioScreen;

function SectionHeader({ title, sub, dark, action }) {
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';
  return (
    <div style={{ padding: '0 20px', display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 4 }}>
      <div>
        <div style={{ fontSize: 22, fontWeight: 700, color: text, letterSpacing: .35 }}>{title}</div>
        {sub && <div style={{ fontSize: 13, color: sec, marginTop: 2 }}>{sub}</div>}
      </div>
      {action}
    </div>
  );
}
window.SectionHeader = SectionHeader;

// ─── Swipeable row (swipe left for actions) ──────────────────────────────────
function SwipeRow({ children, accent, dark, onFav, onDelete }) {
  const [offset, setOffset] = useState(0);
  const startX = useRef(null);
  const startOffset = useRef(0);

  const onStart = (clientX) => { startX.current = clientX; startOffset.current = offset; };
  const onMove = (clientX) => {
    if (startX.current == null) return;
    const dx = clientX - startX.current;
    const target = Math.max(-160, Math.min(0, startOffset.current + dx));
    setOffset(target);
  };
  const onEnd = () => {
    if (offset < -80) setOffset(-160);
    else setOffset(0);
    startX.current = null;
  };

  return (
    <div style={{ position: 'relative', overflow: 'hidden' }}>
      {/* action backplate */}
      <div style={{
        position: 'absolute', inset: 0, display: 'flex', justifyContent: 'flex-end',
      }}>
        <button onClick={() => { onFav?.(); setOffset(0); }} style={{
          width: 80, border: 0, background: accent, color: '#fff',
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 3,
          fontSize: 12, fontWeight: 500, letterSpacing: -.2, cursor: 'pointer',
        }}>
          <Icon name="heart-fill" size={18} color="#fff"/>
          Favorito
        </button>
        <button onClick={() => { onDelete?.(); setOffset(0); }} style={{
          width: 80, border: 0, background: '#FF3B30', color: '#fff',
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 3,
          fontSize: 12, fontWeight: 500, letterSpacing: -.2, cursor: 'pointer',
        }}>
          <Icon name="x" size={18} color="#fff" stroke={2.5}/>
          Eliminar
        </button>
      </div>
      <div
        onTouchStart={(e) => onStart(e.touches[0].clientX)}
        onTouchMove={(e) => onMove(e.touches[0].clientX)}
        onTouchEnd={onEnd}
        onMouseDown={(e) => { onStart(e.clientX); }}
        onMouseMove={(e) => { if (startX.current != null && (e.buttons & 1)) onMove(e.clientX); }}
        onMouseUp={onEnd}
        onMouseLeave={onEnd}
        style={{
          transform: `translateX(${offset}px)`,
          transition: startX.current == null ? 'transform .25s cubic-bezier(.3,.7,.4,1)' : 'none',
          background: dark ? '#1c1c1e' : '#fff', position: 'relative',
        }}
      >
        {children}
      </div>
    </div>
  );
}
window.SwipeRow = SwipeRow;

// ─── Listas screen ───────────────────────────────────────────────────────────
function ListasScreen({ accent, dark, lists, onOpenList }) {
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';
  return (
    <div style={{ height: '100%', overflowY: 'auto', overflowX: 'hidden', WebkitOverflowScrolling: 'touch' }}>
      <div style={{ padding: '6px 20px 18px' }}>
        <div style={{ fontSize: 34, fontWeight: 700, letterSpacing: .37, color: text }}>Listas</div>
        <div style={{ fontSize: 15, color: sec, marginTop: 4 }}>Organiza recetas por momento o gusto</div>
      </div>

      <div style={{
        display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12,
        padding: '0 16px 24px',
      }}>
        {lists.map(l => (
          <div key={l.id} onClick={() => onOpenList(l.id)} style={{
            background: dark ? '#1c1c1e' : '#fff',
            borderRadius: 18, padding: 14, cursor: 'pointer',
            boxShadow: dark ? 'none' : '0 1px 3px rgba(0,0,0,.05)',
            display: 'flex', flexDirection: 'column', gap: 10, minHeight: 120,
          }}>
            <div style={{
              width: 38, height: 38, borderRadius: 10,
              background: l.color, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 18,
            }}>
              {l.icon}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 600, color: text, letterSpacing: -.2 }}>{l.name}</div>
              <div style={{ fontSize: 13, color: sec, marginTop: 2 }}>{l.count} recetas</div>
            </div>
          </div>
        ))}
        {/* Empty card to add new list */}
        <div style={{
          background: 'transparent',
          border: `1.5px dashed ${dark ? 'rgba(255,255,255,.2)' : 'rgba(0,0,0,.15)'}`,
          borderRadius: 18, padding: 14, cursor: 'pointer',
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
          minHeight: 120, gap: 6,
          color: sec,
        }}>
          <Icon name="plus" size={22} color={accent} stroke={2.2}/>
          <span style={{ fontSize: 13, fontWeight: 500, color: accent }}>Nueva lista</span>
        </div>
      </div>
    </div>
  );
}
window.ListasScreen = ListasScreen;

// ─── Buscar screen ───────────────────────────────────────────────────────────
function BuscarScreen({ accent, dark, recipes, tags, onOpenRecipe }) {
  const [query, setQuery] = useState('');
  const [activeTags, setActiveTags] = useState([]);
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';

  const toggleTag = (t) => setActiveTags(at => at.includes(t) ? at.filter(x=>x!==t) : [...at, t]);
  const filtered = useMemo(() => recipes.filter(r => {
    const q = query.toLowerCase().trim();
    const matchQ = !q || r.title.toLowerCase().includes(q) || r.tags.some(t => t.includes(q));
    const matchT = activeTags.length === 0 || activeTags.every(t => r.tags.includes(t));
    return matchQ && matchT;
  }), [query, activeTags, recipes]);

  return (
    <div style={{ height: '100%', overflowY: 'auto', overflowX: 'hidden' }}>
      <div style={{ padding: '6px 20px 12px' }}>
        <div style={{ fontSize: 34, fontWeight: 700, letterSpacing: .37, color: text }}>Buscar</div>
      </div>

      {/* Search bar */}
      <div style={{ padding: '0 16px 12px' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 8,
          background: dark ? 'rgba(118,118,128,.24)' : 'rgba(118,118,128,.12)',
          borderRadius: 12, padding: '8px 12px',
        }}>
          <Icon name="search" size={17} color={dark ? 'rgba(235,235,245,.5)' : 'rgba(60,60,67,.5)'}/>
          <input
            value={query} onChange={(e) => setQuery(e.target.value)}
            placeholder="Recetas, ingredientes, etiquetas"
            style={{
              flex: 1, border: 0, background: 'transparent', outline: 'none',
              color: text, fontSize: 17, letterSpacing: -.4,
              fontFamily: 'inherit',
            }}
          />
          {query && <button onClick={() => setQuery('')} style={{
            border: 0, background: dark ? 'rgba(255,255,255,.15)' : 'rgba(0,0,0,.15)',
            width: 18, height: 18, borderRadius: '50%', color: dark ? '#000' : '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', padding: 0,
          }}><Icon name="x" size={11} stroke={3}/></button>}
        </div>
      </div>

      {/* Tag chips */}
      <div style={{
        display: 'flex', gap: 8, overflowX: 'auto', padding: '4px 16px 16px',
        scrollbarWidth: 'none',
      }}>
        {tags.map(t => {
          const on = activeTags.includes(t);
          return (
            <button key={t} onClick={() => toggleTag(t)} style={{
              flexShrink: 0, padding: '7px 14px', borderRadius: 100,
              border: 0, fontSize: 14, fontWeight: 500, letterSpacing: -.2,
              background: on ? accent : (dark ? 'rgba(118,118,128,.24)' : 'rgba(118,118,128,.12)'),
              color: on ? '#fff' : text, cursor: 'pointer',
              fontFamily: 'inherit',
            }}>{t}</button>
          );
        })}
      </div>

      {/* Results */}
      <div style={{ padding: '0 16px 120px' }}>
        {filtered.length === 0 ? (
          <EmptyState dark={dark} icon="search" title="Sin resultados"
            sub="Prueba con otra etiqueta o palabra clave."/>
        ) : (
          <div style={{
            background: dark ? '#1c1c1e' : '#fff', borderRadius: 18, overflow: 'hidden',
          }}>
            {filtered.map((r, i) => (
              <div key={r.id} onClick={() => onOpenRecipe(r.id)} style={{
                display: 'flex', gap: 12, padding: '10px 14px', alignItems: 'center', cursor: 'pointer',
                borderTop: i > 0 ? `.5px solid ${dark ? 'rgba(255,255,255,.08)' : 'rgba(0,0,0,.07)'}` : 'none',
              }}>
                <div style={{ width: 48, height: 48, borderRadius: 10, overflow: 'hidden', flexShrink: 0, background: '#ddd' }}>
                  <img src={r.cover} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }}/>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 15, fontWeight: 600, color: text, letterSpacing: -.2 }}>{r.title}</div>
                  <div style={{ fontSize: 12, color: sec, marginTop: 3, display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                    {r.tags.slice(0, 3).map(t => <span key={t}>#{t}</span>)}
                  </div>
                </div>
                <Icon name="chevron-right" size={14} color={dark ? 'rgba(255,255,255,.25)' : 'rgba(60,60,67,.3)'} stroke={2.5}/>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
window.BuscarScreen = BuscarScreen;

function EmptyState({ dark, icon, title, sub, accent }) {
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';
  return (
    <div style={{ padding: '60px 20px', textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
      <div style={{
        width: 64, height: 64, borderRadius: 16,
        background: dark ? 'rgba(255,255,255,.06)' : 'rgba(0,0,0,.04)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: dark ? 'rgba(255,255,255,.4)' : 'rgba(0,0,0,.3)',
      }}>
        <Icon name={icon} size={28} stroke={1.5}/>
      </div>
      <div style={{ fontSize: 17, fontWeight: 600, color: text, letterSpacing: -.4 }}>{title}</div>
      {sub && <div style={{ fontSize: 14, color: sec, lineHeight: 1.4, maxWidth: 260 }}>{sub}</div>}
    </div>
  );
}
window.EmptyState = EmptyState;

// ─── Ajustes screen ──────────────────────────────────────────────────────────
function AjustesScreen({ accent, dark }) {
  const [icloud, setIcloud] = useState(true);
  const [backup, setBackup] = useState(true);
  const [units, setUnits] = useState('métrico');
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';

  return (
    <div style={{ height: '100%', overflowY: 'auto', overflowX: 'hidden' }}>
      <div style={{ padding: '6px 20px 18px' }}>
        <div style={{ fontSize: 34, fontWeight: 700, letterSpacing: .37, color: text }}>Ajustes</div>
      </div>

      <SettingsGroup header="Sincronización" dark={dark}>
        <ToggleRow dark={dark} icon="cloud" iconBg={accent} title="Sincronizar con iCloud"
          sub={icloud ? 'Última sincronización: hace 2 min' : 'Desactivado'}
          value={icloud} onChange={setIcloud}/>
        <ToggleRow dark={dark} icon="archive" iconBg="#5A8FB8" title="Backup automático"
          sub="Copia local cada vez que añades una receta"
          value={backup} onChange={setBackup}/>
      </SettingsGroup>

      <SettingsGroup header="Datos" dark={dark}>
        <ActionRow dark={dark} icon="download" iconBg="#6B8E5A" title="Exportar todas las recetas"
          detail="PDF · JSON" onClick={() => {}}/>
        <ActionRow dark={dark} icon="archive" iconBg={dark ? '#444' : '#8E8E93'} title="Recetas archivadas"
          detail="3" onClick={() => {}}/>
      </SettingsGroup>

      <SettingsGroup header="Preferencias" dark={dark}>
        <SegmentRow dark={dark} icon="globe" iconBg="#5A8FB8" title="Unidades"
          options={['métrico', 'imperial']} value={units} onChange={setUnits} accent={accent}/>
        <ActionRow dark={dark} icon="globe" iconBg="#D9A35A" title="Idioma"
          detail="Español" onClick={() => {}}/>
      </SettingsGroup>

      <SettingsGroup header="Acerca de" dark={dark}>
        <ActionRow dark={dark} title="Versión" detail="1.0.0" chevron={false}/>
        <ActionRow dark={dark} title="Licencias" onClick={() => {}}/>
        <ActionRow dark={dark} title="Política de privacidad" onClick={() => {}}/>
      </SettingsGroup>

      <div style={{ height: 120 }}/>
    </div>
  );
}
window.AjustesScreen = AjustesScreen;

function SettingsGroup({ header, children, dark }) {
  const sec = dark ? 'rgba(235,235,245,.5)' : 'rgba(60,60,67,.5)';
  return (
    <div style={{ marginBottom: 24 }}>
      {header && <div style={{
        padding: '0 32px 6px', fontSize: 13, color: sec,
        textTransform: 'uppercase', letterSpacing: .4, fontWeight: 500,
      }}>{header}</div>}
      <div style={{
        margin: '0 16px', borderRadius: 14, overflow: 'hidden',
        background: dark ? '#1c1c1e' : '#fff',
      }}>{children}</div>
    </div>
  );
}

function ToggleRow({ icon, iconBg, title, sub, value, onChange, dark }) {
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '10px 14px',
      borderTop: `.5px solid ${dark ? 'rgba(84,84,88,.65)' : 'rgba(60,60,67,.12)'}`,
    }}>
      {icon && <div style={{
        width: 30, height: 30, borderRadius: 7, background: iconBg, color: '#fff',
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}><Icon name={icon} size={17} stroke={2.2}/></div>}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 16, color: text, letterSpacing: -.4 }}>{title}</div>
        {sub && <div style={{ fontSize: 13, color: sec, marginTop: 2 }}>{sub}</div>}
      </div>
      <button onClick={() => onChange(!value)} style={{
        width: 51, height: 31, borderRadius: 100, border: 0, padding: 0, position: 'relative',
        background: value ? '#34C759' : (dark ? '#39393D' : '#E9E9EA'),
        cursor: 'pointer', transition: 'background .2s',
      }}>
        <div style={{
          position: 'absolute', top: 2, left: value ? 22 : 2, width: 27, height: 27, borderRadius: '50%',
          background: '#fff', transition: 'left .2s',
          boxShadow: '0 3px 8px rgba(0,0,0,.15), 0 1px 1px rgba(0,0,0,.1)',
        }}/>
      </button>
    </div>
  );
}

function ActionRow({ icon, iconBg, title, detail, onClick, dark, chevron = true }) {
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '11px 14px',
      borderTop: `.5px solid ${dark ? 'rgba(84,84,88,.65)' : 'rgba(60,60,67,.12)'}`,
      cursor: onClick ? 'pointer' : 'default',
    }}>
      {icon && <div style={{
        width: 30, height: 30, borderRadius: 7, background: iconBg, color: '#fff',
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}><Icon name={icon} size={17} stroke={2.2}/></div>}
      <div style={{ flex: 1, fontSize: 16, color: text, letterSpacing: -.4 }}>{title}</div>
      {detail && <span style={{ fontSize: 16, color: sec, letterSpacing: -.4 }}>{detail}</span>}
      {chevron && onClick && <Icon name="chevron-right" size={14} color={dark ? 'rgba(255,255,255,.25)' : 'rgba(60,60,67,.3)'} stroke={2.5}/>}
    </div>
  );
}

function SegmentRow({ icon, iconBg, title, options, value, onChange, dark, accent }) {
  const text = dark ? '#fff' : '#0a0a0a';
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '10px 14px',
      borderTop: `.5px solid ${dark ? 'rgba(84,84,88,.65)' : 'rgba(60,60,67,.12)'}`,
    }}>
      {icon && <div style={{
        width: 30, height: 30, borderRadius: 7, background: iconBg, color: '#fff',
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}><Icon name={icon} size={17} stroke={2.2}/></div>}
      <div style={{ flex: 1, fontSize: 16, color: text, letterSpacing: -.4 }}>{title}</div>
      <div style={{
        display: 'flex', background: dark ? 'rgba(118,118,128,.24)' : 'rgba(118,118,128,.16)',
        borderRadius: 8, padding: 2,
      }}>
        {options.map(o => (
          <button key={o} onClick={() => onChange(o)} style={{
            border: 0, padding: '4px 10px', fontSize: 13, fontWeight: 500, letterSpacing: -.2,
            background: o === value ? (dark ? '#636366' : '#fff') : 'transparent',
            color: text, borderRadius: 6, cursor: 'pointer',
            boxShadow: o === value ? '0 1px 2px rgba(0,0,0,.1)' : 'none',
            fontFamily: 'inherit',
          }}>{o}</button>
        ))}
      </div>
    </div>
  );
}

window.SettingsGroup = SettingsGroup;
window.ToggleRow = ToggleRow;
window.ActionRow = ActionRow;
