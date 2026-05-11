// app.jsx — Root composition for Cocina

const { useState: useStateApp, useEffect: useEffectApp, useRef: useRefApp } = React;

function App() {
  const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
    "accent": "#C4623F",
    "dark": false,
    "showFrame": true,
    "screen": "inicio",
    "showOnboarding": false
  }/*EDITMODE-END*/;

  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const [tab, setTab] = useStateApp(t.screen || 'inicio');
  const [openRecipe, setOpenRecipe] = useStateApp(null);
  const [showAdd, setShowAdd] = useStateApp(false);
  const [showActionSheet, setShowActionSheet] = useStateApp(false);
  const [cookMode, setCookMode] = useStateApp(false);
  const [showOnboard, setShowOnboard] = useStateApp(t.showOnboarding);
  const [scrollY, setScrollY] = useStateApp(0);
  const inicioScrollRef = useRefApp(null);

  // sync tweak screen change to tab
  useEffectApp(() => { if (t.screen && t.screen !== tab) setTab(t.screen); }, [t.screen]);

  const accent = t.accent;
  const dark = t.dark;

  const recipe = openRecipe ? RECIPES.find(r => r.id === openRecipe) : null;

  const navTab = (id) => {
    setTab(id);
    setTweak('screen', id);
    setOpenRecipe(null);
    setShowAdd(false);
  };

  const Screen = (() => {
    if (tab === 'inicio') return (
      <InicioScreen accent={accent} dark={dark} recipes={RECIPES}
        onOpenRecipe={(id) => setOpenRecipe(id)}
        onOpenAdd={() => setShowAdd(true)}
        scrollRef={inicioScrollRef}
        onScroll={(e) => setScrollY(e.target.scrollTop)}/>
    );
    if (tab === 'listas') return <ListasScreen accent={accent} dark={dark} lists={LISTS} onOpenList={() => setTab('buscar')}/>;
    if (tab === 'buscar') return <BuscarScreen accent={accent} dark={dark} recipes={RECIPES} tags={TAGS} onOpenRecipe={(id) => setOpenRecipe(id)}/>;
    if (tab === 'ajustes') return <AjustesScreen accent={accent} dark={dark}/>;
    return null;
  })();

  // ─── Phone screen content ──────────────────────────────────────────────────
  const phoneScreen = (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      background: dark ? '#000' : '#F2F2F7',
      fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Text", "SF Pro", system-ui, sans-serif',
      WebkitFontSmoothing: 'antialiased',
      color: dark ? '#fff' : '#000',
    }}>
      {/* Status bar (always on top) */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 25, pointerEvents: 'none' }}>
        <IOSStatusBar dark={dark || (recipe && scrollY < 220) || cookMode}/>
      </div>

      {/* Main tabs view */}
      <div style={{ position: 'absolute', top: 44, left: 0, right: 0, bottom: 0 }}>
        {Screen}
      </div>

      {/* Tab bar */}
      {!recipe && !showAdd && !cookMode && !showOnboard && (
        <TabBar accent={accent} dark={dark} active={tab} onChange={navTab}/>
      )}

      {/* + FAB */}
      {tab === 'inicio' && !recipe && !showAdd && !cookMode && !showOnboard && (
        <button onClick={() => setShowActionSheet(true)} style={{
          position: 'absolute', right: 18, bottom: 100, zIndex: 20,
          width: 56, height: 56, borderRadius: '50%', border: 0,
          background: accent, color: '#fff', cursor: 'pointer',
          boxShadow: `0 6px 18px ${accent}55, 0 2px 4px rgba(0,0,0,.1)`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          transition: 'transform .15s',
        }}
          onMouseDown={(e) => e.currentTarget.style.transform = 'scale(.94)'}
          onMouseUp={(e) => e.currentTarget.style.transform = 'scale(1)'}
          onMouseLeave={(e) => e.currentTarget.style.transform = 'scale(1)'}>
          <Icon name="plus" size={26} color="#fff" stroke={2.4}/>
        </button>
      )}

      {/* Action sheet */}
      {showActionSheet && (
        <ActionSheet dark={dark} accent={accent}
          onClose={() => setShowActionSheet(false)}
          onPick={(action) => {
            setShowActionSheet(false);
            if (action === 'url') { setShowAdd(true); }
          }}/>
      )}

      {/* Recipe detail overlay */}
      {recipe && !cookMode && (
        <RecipeDetailScreen
          recipe={recipe} accent={accent} dark={dark}
          onBack={() => setOpenRecipe(null)}
          onCookMode={() => setCookMode(true)}
          onAddToList={() => {}}
          onShare={() => {}}/>
      )}

      {/* Cook mode */}
      {cookMode && recipe && (
        <ModoCocinaScreen recipe={recipe} accent={accent} onClose={() => setCookMode(false)}/>
      )}

      {/* Add Recipe */}
      {showAdd && (
        <AddRecipeScreen accent={accent} dark={dark}
          onClose={() => setShowAdd(false)}
          onSave={() => setShowAdd(false)}/>
      )}

      {/* Onboarding */}
      {showOnboard && (
        <OnboardingScreen accent={accent} onDone={() => { setShowOnboard(false); setTweak('showOnboarding', false); }}/>
      )}

      {/* Home indicator */}
      <div style={{
        position: 'absolute', bottom: 0, left: 0, right: 0, height: 34, zIndex: 60,
        display: 'flex', alignItems: 'flex-end', justifyContent: 'center', paddingBottom: 8,
        pointerEvents: 'none',
      }}>
        <div style={{
          width: 134, height: 5, borderRadius: 100,
          background: cookMode ? 'rgba(255,255,255,.7)' : (dark ? 'rgba(255,255,255,.7)' : 'rgba(0,0,0,.35)'),
        }}/>
      </div>
    </div>
  );

  // ─── Render: phone bezel or naked screen ───────────────────────────────────
  return (
    <div style={{
      minHeight: '100vh', background: dark ? '#0a0a0a' : '#E5E2DC',
      display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 24,
      fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Text", system-ui, sans-serif',
    }}>
      <style>{`
        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes slideUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        ::-webkit-scrollbar { display: none; }
        * { -webkit-tap-highlight-color: transparent; box-sizing: border-box; }
        button { font-family: inherit; }
        input, textarea { font-family: inherit; }
      `}</style>

      {t.showFrame ? (
        <div style={{
          width: 390, height: 844, position: 'relative',
          borderRadius: 56, padding: 12,
          background: 'linear-gradient(160deg, #2a2a2c, #0e0e10)',
          boxShadow: '0 50px 90px rgba(0,0,0,.35), 0 0 0 2px rgba(255,255,255,.06) inset, 0 30px 60px rgba(0,0,0,.18)',
        }}>
          <div style={{
            width: '100%', height: '100%', borderRadius: 44, overflow: 'hidden',
            position: 'relative',
          }}>
            {phoneScreen}
            {/* Dynamic island */}
            <div style={{
              position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
              width: 124, height: 36, borderRadius: 22, background: '#000', zIndex: 80,
            }}/>
          </div>
        </div>
      ) : (
        <div style={{ width: 390, height: 844, position: 'relative', borderRadius: 36, overflow: 'hidden',
          boxShadow: '0 30px 60px rgba(0,0,0,.18)' }}>
          {phoneScreen}
          <div style={{
            position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
            width: 124, height: 36, borderRadius: 22, background: '#000', zIndex: 80,
          }}/>
        </div>
      )}

      <TweaksPanel title="Tweaks">
        <TweakSection label="Tema"/>
        <TweakColor label="Acento" value={t.accent} onChange={(v) => setTweak('accent', v)}/>
        <div style={{ display: 'flex', gap: 6, marginTop: -2 }}>
          {[
            { c: '#C4623F', name: 'Terracotta' },
            { c: '#6B8E5A', name: 'Sage' },
            { c: '#B8453A', name: 'Tomate' },
            { c: '#8B6FB8', name: 'Lavanda' },
            { c: '#3F8B7A', name: 'Eucalipto' },
          ].map(p => (
            <button key={p.c} onClick={() => setTweak('accent', p.c)} title={p.name} style={{
              width: 22, height: 22, borderRadius: 6, border: t.accent === p.c ? '2px solid #29261b' : '.5px solid rgba(0,0,0,.15)',
              background: p.c, cursor: 'pointer', padding: 0, flexShrink: 0,
            }}/>
          ))}
        </div>
        <TweakToggle label="Modo oscuro" value={t.dark} onChange={(v) => setTweak('dark', v)}/>
        <TweakToggle label="Mostrar marco iPhone" value={t.showFrame} onChange={(v) => setTweak('showFrame', v)}/>
        <TweakSection label="Navegación"/>
        <TweakRadio label="Pestaña" value={t.screen}
          options={[
            { value: 'inicio', label: 'Inicio' },
            { value: 'listas', label: 'Listas' },
            { value: 'buscar', label: 'Buscar' },
            { value: 'ajustes', label: 'Ajustes' },
          ]}
          onChange={(v) => { setTweak('screen', v); navTab(v); }}/>
        <TweakButton label="Ver onboarding" onClick={() => { setShowOnboard(true); }}/>
        <TweakButton label="Abrir flujo añadir receta" secondary onClick={() => { setShowAdd(true); }}/>
      </TweaksPanel>
    </div>
  );
}

// ─── Tab bar ────────────────────────────────────────────────────────────────
function TabBar({ accent, dark, active, onChange }) {
  const tabs = [
    { id: 'inicio', label: 'Inicio', icon: 'home' },
    { id: 'listas', label: 'Listas', icon: 'lists' },
    { id: 'buscar', label: 'Buscar', icon: 'search' },
    { id: 'ajustes', label: 'Ajustes', icon: 'settings' },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 50,
      paddingBottom: 26, paddingTop: 8, paddingLeft: 8, paddingRight: 8,
      background: dark ? 'rgba(28,28,30,.78)' : 'rgba(255,255,255,.78)',
      backdropFilter: 'blur(24px) saturate(180%)',
      WebkitBackdropFilter: 'blur(24px) saturate(180%)',
      borderTop: `.5px solid ${dark ? 'rgba(255,255,255,.08)' : 'rgba(0,0,0,.08)'}`,
      display: 'flex',
    }}>
      {tabs.map(t => {
        const on = active === t.id;
        return (
          <button key={t.id} onClick={() => onChange(t.id)} style={{
            flex: 1, padding: '4px 0 2px', border: 0, background: 'transparent', cursor: 'pointer',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
            position: 'relative',
          }}>
            <div style={{
              padding: '5px 14px', borderRadius: 100,
              background: on ? `${accent}1a` : 'transparent',
              transition: 'background .15s',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Icon name={t.icon} size={22} color={on ? accent : (dark ? 'rgba(255,255,255,.45)' : 'rgba(60,60,67,.5)')} stroke={on ? 2.2 : 1.8}/>
            </div>
            <span style={{
              fontSize: 10, fontWeight: 500, letterSpacing: .1,
              color: on ? accent : (dark ? 'rgba(255,255,255,.5)' : 'rgba(60,60,67,.55)'),
            }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ─── Action sheet ────────────────────────────────────────────────────────────
function ActionSheet({ accent, dark, onClose, onPick }) {
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.55)';
  const items = [
    { id: 'url', icon: 'link', title: 'Pegar enlace', sub: 'Instagram, TikTok, blogs…' },
    { id: 'share', icon: 'share', title: 'Compartir desde otra app', sub: 'Usa la hoja de compartir del sistema' },
    { id: 'manual', icon: 'pencil-line', title: 'Escribir manualmente', sub: 'Receta de la abuela' },
    { id: 'photo', icon: 'camera', title: 'Foto / screenshot', sub: 'Reconocemos texto e ingredientes' },
  ];
  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, background: 'rgba(0,0,0,.4)',
      zIndex: 70, display: 'flex', alignItems: 'flex-end',
      animation: 'fadeIn .2s',
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: '100%', padding: '0 8px 8px',
        animation: 'slideUp .25s cubic-bezier(.3,.7,.4,1)',
      }}>
        <div style={{
          background: dark ? 'rgba(44,44,46,.95)' : 'rgba(250,250,250,.95)',
          backdropFilter: 'blur(30px) saturate(180%)',
          WebkitBackdropFilter: 'blur(30px) saturate(180%)',
          borderRadius: 14, overflow: 'hidden', marginBottom: 8,
        }}>
          <div style={{
            padding: '14px 16px 12px', textAlign: 'center', fontSize: 13,
            color: sec, letterSpacing: -.1, lineHeight: 1.3,
            borderBottom: `.5px solid ${dark ? 'rgba(255,255,255,.08)' : 'rgba(0,0,0,.08)'}`,
          }}>
            Añadir nueva receta
          </div>
          {items.map((it, i) => (
            <button key={it.id} onClick={() => onPick(it.id)} style={{
              width: '100%', border: 0, background: 'transparent', cursor: 'pointer',
              padding: '14px 16px', display: 'flex', alignItems: 'center', gap: 14,
              borderTop: i > 0 ? `.5px solid ${dark ? 'rgba(255,255,255,.08)' : 'rgba(0,0,0,.08)'}` : 'none',
              textAlign: 'left',
            }}>
              <div style={{
                width: 36, height: 36, borderRadius: 10, background: `${accent}1f`,
                display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
              }}>
                <Icon name={it.icon} size={19} color={accent} stroke={2}/>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 16, fontWeight: 500, color: text, letterSpacing: -.3 }}>{it.title}</div>
                <div style={{ fontSize: 13, color: sec, marginTop: 1 }}>{it.sub}</div>
              </div>
            </button>
          ))}
        </div>
        <button onClick={onClose} style={{
          width: '100%', padding: '14px', borderRadius: 14, border: 0,
          background: dark ? 'rgba(44,44,46,.95)' : 'rgba(250,250,250,.95)',
          backdropFilter: 'blur(30px) saturate(180%)',
          WebkitBackdropFilter: 'blur(30px) saturate(180%)',
          color: accent, fontFamily: 'inherit', fontSize: 17, fontWeight: 600, letterSpacing: -.4,
          cursor: 'pointer', marginBottom: 12,
        }}>
          Cancelar
        </button>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
