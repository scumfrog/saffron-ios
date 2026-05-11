// screens-detail.jsx — Recipe Detail, Modo Cocina, Add Recipe, Onboarding

const { useState: useStateD, useEffect: useEffectD, useRef: useRefD, useMemo: useMemoD } = React;

// ─── Recipe Detail ───────────────────────────────────────────────────────────
function RecipeDetailScreen({ recipe, accent, dark, onBack, onCookMode, onAddToList, onShare }) {
  const [tab, setTab] = useStateD('ing'); // ing | pasos | notas
  const [servings, setServings] = useStateD(recipe.servings);
  const [checked, setChecked] = useStateD(new Set());
  const [scrollY, setScrollY] = useStateD(0);
  const [fav, setFav] = useStateD(recipe.favorite);
  const scrollRef = useRefD(null);

  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';
  const ratio = servings / recipe.servings;

  const toggleChecked = (i) => {
    setChecked(prev => {
      const n = new Set(prev);
      if (n.has(i)) n.delete(i); else n.add(i);
      return n;
    });
  };

  const fmtQty = (q) => {
    const v = q * ratio;
    if (v >= 10) return Math.round(v).toString();
    if (v >= 1) return (Math.round(v * 10) / 10).toString().replace('.', ',');
    return (Math.round(v * 100) / 100).toString().replace('.', ',');
  };

  const HERO_H = 320;
  const heroOffset = Math.min(scrollY * 0.5, HERO_H);
  const heroScale = 1 + Math.max(0, -scrollY) / 200;
  const titleOpacity = scrollY > 220 ? Math.min((scrollY - 220) / 50, 1) : 0;

  return (
    <div style={{ position: 'absolute', inset: 0, background: dark ? '#000' : '#F2F2F7', overflow: 'hidden' }}>
      {/* Floating nav bar */}
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, zIndex: 30,
        paddingTop: 54, paddingBottom: 8, paddingLeft: 12, paddingRight: 12,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        background: titleOpacity > 0.5
          ? (dark ? 'rgba(28,28,30,.85)' : 'rgba(242,242,247,.85)') : 'transparent',
        backdropFilter: titleOpacity > 0.5 ? 'blur(20px) saturate(180%)' : 'none',
        WebkitBackdropFilter: titleOpacity > 0.5 ? 'blur(20px) saturate(180%)' : 'none',
        transition: 'background .15s',
        borderBottom: titleOpacity > 0.5 ? `.5px solid ${dark ? 'rgba(255,255,255,.1)' : 'rgba(0,0,0,.1)'}` : '.5px solid transparent',
      }}>
        <CircleButton dark={dark} onClick={onBack} solid><Icon name="chevron-left" size={18} stroke={2.5} color={dark ? '#fff' : '#000'}/></CircleButton>
        <div style={{
          flex: 1, textAlign: 'center', fontSize: 16, fontWeight: 600, letterSpacing: -.4,
          color: text, opacity: titleOpacity, padding: '0 8px',
          overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
        }}>{recipe.title}</div>
        <div style={{ display: 'flex', gap: 8 }}>
          <CircleButton dark={dark} onClick={() => setFav(!fav)} solid>
            <Icon name={fav ? 'heart-fill' : 'heart'} size={16} color={fav ? accent : (dark ? '#fff' : '#000')} stroke={2}/>
          </CircleButton>
          <CircleButton dark={dark} onClick={onShare} solid>
            <Icon name="share" size={16} stroke={2} color={dark ? '#fff' : '#000'}/>
          </CircleButton>
        </div>
      </div>

      <div ref={scrollRef} onScroll={(e) => setScrollY(e.target.scrollTop)} style={{
        position: 'absolute', inset: 0, overflowY: 'auto', overflowX: 'hidden',
      }}>
        {/* Parallax hero */}
        <div style={{
          height: HERO_H, position: 'relative', overflow: 'hidden',
          background: `linear-gradient(135deg, ${accent}, ${accent}99)`,
        }}>
          <img src={recipe.cover} alt="" onError={(e) => { e.target.style.display = 'none'; }}
            style={{
              position: 'absolute', top: -heroOffset, left: 0, right: 0,
              width: '100%', height: HERO_H, objectFit: 'cover',
              transform: `scale(${heroScale})`, transformOrigin: 'center top',
            }}/>
          <div style={{
            position: 'absolute', inset: 0,
            background: 'linear-gradient(180deg, rgba(0,0,0,.1) 0%, transparent 30%, rgba(0,0,0,.4) 100%)',
          }}/>
        </div>

        {/* Body card */}
        <div style={{
          background: dark ? '#000' : '#F2F2F7',
          borderRadius: '24px 24px 0 0', marginTop: -24, position: 'relative', zIndex: 2,
          padding: '20px 0 140px',
        }}>
          {/* Title block */}
          <div style={{ padding: '0 20px' }}>
            <div style={{ marginBottom: 8 }}>
              <SourceBadge source={recipe.source} label={recipe.sourceLabel} dark={dark}/>
            </div>
            <div style={{
              fontSize: 28, fontWeight: 700, letterSpacing: -.4, lineHeight: 1.15,
              color: text, textWrap: 'pretty',
            }}>{recipe.title}</div>
          </div>

          {/* Metadata row */}
          <div style={{
            margin: '18px 16px 0', padding: '12px 14px',
            background: dark ? '#1c1c1e' : '#fff',
            borderRadius: 14, display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          }}>
            <MetaItem icon="clock" label="Tiempo" value={`${recipe.timeMin} min`} dark={dark}/>
            <Divider dark={dark}/>
            <MetaItem icon="flame" label="Dificultad" value={recipe.difficulty} dark={dark}/>
            <Divider dark={dark}/>
            <div style={{ flex: 1, textAlign: 'center' }}>
              <div style={{ fontSize: 11, color: sec, letterSpacing: .3, textTransform: 'uppercase' }}>Raciones</div>
              <div style={{
                display: 'inline-flex', alignItems: 'center', gap: 8, marginTop: 4,
              }}>
                <button onClick={() => setServings(Math.max(1, servings - 1))} style={steppBtn(dark, accent)}>
                  <Icon name="minus" size={14} stroke={2.5} color={accent}/>
                </button>
                <span style={{ fontSize: 16, fontWeight: 600, color: text, minWidth: 18, textAlign: 'center' }}>{servings}</span>
                <button onClick={() => setServings(servings + 1)} style={steppBtn(dark, accent)}>
                  <Icon name="plus" size={14} stroke={2.5} color={accent}/>
                </button>
              </div>
            </div>
          </div>

          {/* Segmented control */}
          <div style={{ padding: '20px 16px 0' }}>
            <div style={{
              display: 'flex', background: dark ? 'rgba(118,118,128,.24)' : 'rgba(118,118,128,.16)',
              borderRadius: 9, padding: 2, position: 'relative',
            }}>
              {[
                { id: 'ing', label: 'Ingredientes' },
                { id: 'pasos', label: 'Pasos' },
                { id: 'notas', label: 'Notas' },
              ].map(t => (
                <button key={t.id} onClick={() => setTab(t.id)} style={{
                  flex: 1, border: 0, padding: '7px 10px', fontSize: 13, fontWeight: 600, letterSpacing: -.2,
                  background: tab === t.id ? (dark ? '#636366' : '#fff') : 'transparent',
                  color: text, borderRadius: 7, cursor: 'pointer',
                  boxShadow: tab === t.id ? '0 1px 2px rgba(0,0,0,.1)' : 'none',
                  fontFamily: 'inherit', transition: 'background .15s',
                }}>{t.label}</button>
              ))}
            </div>
          </div>

          {/* Tab content */}
          <div style={{ padding: '14px 16px 0' }}>
            {tab === 'ing' && (
              <div style={{
                background: dark ? '#1c1c1e' : '#fff', borderRadius: 14, overflow: 'hidden',
              }}>
                {ratio !== 1 && (
                  <div style={{
                    padding: '10px 14px', fontSize: 12, color: accent, fontWeight: 500,
                    background: `${accent}14`, borderBottom: `.5px solid ${dark ? 'rgba(255,255,255,.1)' : 'rgba(0,0,0,.08)'}`,
                  }}>
                    Cantidades ajustadas para {servings} {servings === 1 ? 'ración' : 'raciones'} ({recipe.servings === 1 ? 'original 1' : `original ${recipe.servings}`})
                  </div>
                )}
                {recipe.ingredients.map((ing, i) => (
                  <div key={i} onClick={() => toggleChecked(i)} style={{
                    display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
                    borderTop: i > 0 ? `.5px solid ${dark ? 'rgba(255,255,255,.08)' : 'rgba(0,0,0,.07)'}` : 'none',
                    cursor: 'pointer',
                  }}>
                    <div style={{
                      width: 22, height: 22, borderRadius: '50%',
                      border: `1.5px solid ${checked.has(i) ? accent : (dark ? 'rgba(255,255,255,.3)' : 'rgba(0,0,0,.25)')}`,
                      background: checked.has(i) ? accent : 'transparent',
                      display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                      transition: 'all .15s',
                    }}>
                      {checked.has(i) && <Icon name="check" size={13} color="#fff" stroke={3}/>}
                    </div>
                    <div style={{ flex: 1, fontSize: 15, color: text, letterSpacing: -.2,
                      textDecoration: checked.has(i) ? 'line-through' : 'none',
                      opacity: checked.has(i) ? .4 : 1,
                    }}>
                      <span style={{ fontWeight: 600 }}>{fmtQty(ing.qty)}{ing.unit && ` ${ing.unit}`}</span>{' '}
                      <span>{ing.name}</span>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {tab === 'pasos' && (
              <div>
                <button onClick={onCookMode} style={{
                  width: '100%', padding: '14px', borderRadius: 14, border: 0, cursor: 'pointer',
                  background: accent, color: '#fff', fontFamily: 'inherit',
                  fontSize: 16, fontWeight: 600, letterSpacing: -.3,
                  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                  boxShadow: `0 6px 16px ${accent}40`,
                  marginBottom: 14,
                }}>
                  <Icon name="play" size={16} color="#fff"/>
                  Iniciar modo cocina
                </button>
                <div style={{
                  background: dark ? '#1c1c1e' : '#fff', borderRadius: 14, overflow: 'hidden',
                }}>
                  {recipe.steps.map((step, i) => (
                    <div key={i} style={{
                      display: 'flex', gap: 14, padding: '16px 14px',
                      borderTop: i > 0 ? `.5px solid ${dark ? 'rgba(255,255,255,.08)' : 'rgba(0,0,0,.07)'}` : 'none',
                    }}>
                      <div style={{
                        width: 26, height: 26, borderRadius: '50%', flexShrink: 0,
                        background: `${accent}1f`, color: accent,
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        fontSize: 13, fontWeight: 700,
                      }}>{i + 1}</div>
                      <div style={{
                        flex: 1, fontSize: 15, lineHeight: 1.5, color: text,
                        letterSpacing: -.2, textWrap: 'pretty',
                      }}>{step}</div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {tab === 'notas' && (
              <div style={{
                background: dark ? '#1c1c1e' : '#fff', borderRadius: 14, padding: 16,
                fontSize: 15, color: text, letterSpacing: -.2, lineHeight: 1.5, textWrap: 'pretty',
                minHeight: 80,
              }}>
                {recipe.notes || <span style={{ color: sec, fontStyle: 'italic' }}>Aún no hay notas. Toca para añadir.</span>}
              </div>
            )}
          </div>

          {/* Bottom actions */}
          <div style={{ padding: '24px 16px 0' }}>
            <div style={{
              background: dark ? '#1c1c1e' : '#fff', borderRadius: 14, overflow: 'hidden',
            }}>
              {recipe.sourceUrl ? (
                <ActionRowLink dark={dark} icon="link" iconColor={accent} title="Fuente original"
                  detail={recipe.sourceLabel}/>
              ) : (
                <ActionRowLink dark={dark} icon="link" iconColor={dark ? 'rgba(255,255,255,.3)' : 'rgba(0,0,0,.3)'}
                  title="Fuente original" detail="Sin enlace" disabled/>
              )}
              <ActionRowLink dark={dark} icon="edit" iconColor={accent} title="Editar receta"/>
              <ActionRowLink dark={dark} icon="plus-list" iconColor={accent} title="Añadir a lista" onClick={onAddToList} last/>
            </div>
          </div>

          {/* Local copy reassurance */}
          <div style={{
            margin: '16px 16px 0', padding: '12px 14px', borderRadius: 12,
            background: dark ? 'rgba(107,142,90,.18)' : 'rgba(107,142,90,.12)',
            display: 'flex', gap: 10, alignItems: 'flex-start',
          }}>
            <Icon name="archive" size={15} color="#6B8E5A" stroke={2.2}/>
            <div style={{ fontSize: 12, color: dark ? 'rgba(235,235,245,.85)' : '#3a4a30', lineHeight: 1.4 }}>
              Esta receta está guardada localmente. La conservas aunque desaparezca el enlace original.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
window.RecipeDetailScreen = RecipeDetailScreen;

function CircleButton({ children, onClick, dark, solid }) {
  return (
    <button onClick={onClick} style={{
      width: 36, height: 36, borderRadius: '50%', border: 0, padding: 0,
      background: solid ? (dark ? 'rgba(40,40,42,.7)' : 'rgba(255,255,255,.85)') : 'transparent',
      backdropFilter: 'blur(20px) saturate(180%)',
      WebkitBackdropFilter: 'blur(20px) saturate(180%)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      cursor: 'pointer', boxShadow: solid ? '0 1px 3px rgba(0,0,0,.1)' : 'none',
    }}>{children}</button>
  );
}
window.CircleButton = CircleButton;

function MetaItem({ icon, label, value, dark }) {
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';
  return (
    <div style={{ flex: 1, textAlign: 'center' }}>
      <div style={{ fontSize: 11, color: sec, letterSpacing: .3, textTransform: 'uppercase' }}>{label}</div>
      <div style={{ fontSize: 16, fontWeight: 600, color: text, marginTop: 4, letterSpacing: -.2 }}>{value}</div>
    </div>
  );
}
function Divider({ dark }) {
  return <div style={{ width: 1, height: 32, background: dark ? 'rgba(255,255,255,.1)' : 'rgba(0,0,0,.08)' }}/>;
}
function steppBtn(dark, accent) {
  return {
    width: 26, height: 26, borderRadius: '50%', border: 0, padding: 0,
    background: dark ? '#2c2c2e' : '#F2F2F7', cursor: 'pointer',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
  };
}
function ActionRowLink({ icon, iconColor, title, detail, onClick, disabled, last }) {
  // dark inherited via parent; use prop for inline simplicity
  return null; // placeholder, replaced below
}
// Override:
window.ActionRowLink = function ActionRowLink2({ icon, iconColor, title, detail, onClick, disabled, last, dark }) {
  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';
  return (
    <div onClick={!disabled ? onClick : undefined} style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '13px 14px',
      borderTop: !last ? '0px' : '0px',
      cursor: disabled || !onClick ? 'default' : 'pointer',
      opacity: disabled ? .5 : 1,
      borderBottom: !last ? `.5px solid ${dark ? 'rgba(255,255,255,.08)' : 'rgba(0,0,0,.07)'}` : 'none',
    }}>
      <Icon name={icon} size={20} color={iconColor} stroke={2}/>
      <div style={{ flex: 1, fontSize: 15, color: disabled ? sec : text, letterSpacing: -.2 }}>{title}</div>
      {detail && <span style={{ fontSize: 14, color: sec, letterSpacing: -.2 }}>{detail}</span>}
      {onClick && !disabled && <Icon name="chevron-right" size={13} color={dark ? 'rgba(255,255,255,.25)' : 'rgba(60,60,67,.3)'} stroke={2.5}/>}
    </div>
  );
};

// ─── Modo Cocina (fullscreen step viewer) ────────────────────────────────────
function ModoCocinaScreen({ recipe, accent, onClose }) {
  const [step, setStep] = useStateD(0);
  const total = recipe.steps.length;

  return (
    <div style={{
      position: 'absolute', inset: 0, background: '#000', color: '#fff',
      display: 'flex', flexDirection: 'column', zIndex: 100,
    }}>
      {/* Top bar */}
      <div style={{
        padding: '54px 16px 12px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <button onClick={onClose} style={{
          padding: '6px 14px', borderRadius: 100, border: 0, cursor: 'pointer',
          background: 'rgba(255,255,255,.12)', color: '#fff',
          fontFamily: 'inherit', fontSize: 14, fontWeight: 500, letterSpacing: -.2,
          display: 'inline-flex', alignItems: 'center', gap: 4,
        }}>
          <Icon name="x" size={14} stroke={2.5} color="#fff"/> Salir
        </button>
        <div style={{ fontSize: 13, opacity: .6, letterSpacing: .3 }}>MODO COCINA</div>
        <div style={{ width: 70 }}/>
      </div>

      {/* Progress bar */}
      <div style={{ padding: '0 16px 28px', display: 'flex', gap: 4 }}>
        {Array.from({ length: total }).map((_, i) => (
          <div key={i} style={{
            flex: 1, height: 3, borderRadius: 2,
            background: i <= step ? accent : 'rgba(255,255,255,.18)',
            transition: 'background .3s',
          }}/>
        ))}
      </div>

      {/* Step counter */}
      <div style={{ padding: '0 28px', fontSize: 14, opacity: .55, letterSpacing: .4, textTransform: 'uppercase', fontWeight: 500 }}>
        Paso {step + 1} de {total}
      </div>

      {/* Step content (big) */}
      <div style={{
        flex: 1, padding: '24px 28px', display: 'flex', flexDirection: 'column', justifyContent: 'center',
        overflow: 'auto',
      }}>
        <div style={{
          fontSize: 28, fontWeight: 600, lineHeight: 1.3, letterSpacing: -.5,
          textWrap: 'pretty',
        }}>{recipe.steps[step]}</div>
      </div>

      {/* Hint */}
      <div style={{ textAlign: 'center', fontSize: 12, opacity: .4, marginBottom: 8 }}>
        Pantalla activa · No se bloqueará mientras cocinas
      </div>

      {/* Nav buttons */}
      <div style={{ padding: '0 16px 40px', display: 'flex', gap: 12 }}>
        <button onClick={() => setStep(Math.max(0, step - 1))} disabled={step === 0} style={{
          flex: 1, padding: '16px', borderRadius: 14, border: 0, cursor: step === 0 ? 'default' : 'pointer',
          background: 'rgba(255,255,255,.12)', color: '#fff', opacity: step === 0 ? .35 : 1,
          fontFamily: 'inherit', fontSize: 16, fontWeight: 600, letterSpacing: -.3,
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
        }}>
          <Icon name="chevron-left" size={16} stroke={2.5} color="#fff"/> Anterior
        </button>
        <button onClick={() => setStep(Math.min(total - 1, step + 1))} disabled={step === total - 1} style={{
          flex: 2, padding: '16px', borderRadius: 14, border: 0, cursor: step === total - 1 ? 'default' : 'pointer',
          background: accent, color: '#fff', opacity: step === total - 1 ? .5 : 1,
          fontFamily: 'inherit', fontSize: 16, fontWeight: 600, letterSpacing: -.3,
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6,
        }}>
          {step === total - 1 ? '¡Listo!' : 'Siguiente'} <Icon name="chevron-right" size={16} stroke={2.5} color="#fff"/>
        </button>
      </div>
    </div>
  );
}
window.ModoCocinaScreen = ModoCocinaScreen;

// ─── Add Recipe flow ─────────────────────────────────────────────────────────
function AddRecipeScreen({ accent, dark, onClose, onSave }) {
  const [stage, setStage] = useStateD('input'); // input | extracting | preview
  const [url, setUrl] = useStateD('https://instagram.com/p/Cy3kF9XoLrA');
  const [data, setData] = useStateD(null);

  const startExtract = () => {
    setStage('extracting');
    setTimeout(() => {
      setData({
        title: 'Crema fría de calabacín y menta',
        cover: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&q=80',
        source: 'instagram',
        sourceLabel: '@cocina_de_eva',
        timeMin: 25,
        servings: 4,
        ingredients: [
          '3 calabacines medianos',
          '1 cebolla blanca',
          '500 ml caldo de verduras',
          '4 cdas yogur griego',
          '1 puñado menta fresca',
          'AOVE, sal, pimienta',
        ],
        steps: [
          'Pica la cebolla y póchala en aceite 8 minutos.',
          'Añade el calabacín en rodajas y rehoga 5 minutos.',
          'Cubre con el caldo y cuece 12 minutos hasta que esté tierno.',
          'Tritura con la menta. Enfría al menos 2 horas.',
          'Sirve con una cucharada de yogur encima.',
        ],
      });
      setStage('preview');
    }, 1800);
  };

  const text = dark ? '#fff' : '#0a0a0a';
  const sec = dark ? 'rgba(235,235,245,.6)' : 'rgba(60,60,67,.6)';
  const cardBg = dark ? '#1c1c1e' : '#fff';

  return (
    <div style={{
      position: 'absolute', inset: 0, background: dark ? '#000' : '#F2F2F7',
      display: 'flex', flexDirection: 'column', zIndex: 90,
    }}>
      {/* Sheet handle */}
      <div style={{ paddingTop: 10, display: 'flex', justifyContent: 'center' }}>
        <div style={{ width: 36, height: 5, borderRadius: 3, background: dark ? 'rgba(255,255,255,.2)' : 'rgba(0,0,0,.18)' }}/>
      </div>
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '12px 16px 6px',
      }}>
        <button onClick={onClose} style={{
          border: 0, background: 'transparent', color: accent, fontFamily: 'inherit',
          fontSize: 17, fontWeight: 400, letterSpacing: -.4, cursor: 'pointer', padding: 0,
        }}>Cancelar</button>
        <div style={{ fontSize: 17, fontWeight: 600, color: text, letterSpacing: -.4 }}>Nueva receta</div>
        {stage === 'preview' ? (
          <button onClick={() => onSave(data)} style={{
            border: 0, background: 'transparent', color: accent, fontFamily: 'inherit',
            fontSize: 17, fontWeight: 600, letterSpacing: -.4, cursor: 'pointer', padding: 0,
          }}>Guardar</button>
        ) : <div style={{ width: 60 }}/>}
      </div>

      <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden' }}>
        {stage === 'input' && (
          <div style={{ padding: '24px 16px' }}>
            <div style={{ fontSize: 13, color: sec, padding: '0 16px 6px', textTransform: 'uppercase', letterSpacing: .4 }}>Pegar enlace</div>
            <div style={{
              background: cardBg, borderRadius: 14, padding: '12px 14px',
              display: 'flex', alignItems: 'center', gap: 10,
            }}>
              <Icon name="link" size={18} color={sec} stroke={2}/>
              <input value={url} onChange={(e) => setUrl(e.target.value)}
                placeholder="https://..."
                style={{
                  flex: 1, border: 0, background: 'transparent', outline: 'none',
                  color: text, fontSize: 15, letterSpacing: -.2, fontFamily: 'inherit',
                }}/>
            </div>
            <button onClick={startExtract} disabled={!url} style={{
              width: '100%', marginTop: 16, padding: '14px', borderRadius: 14, border: 0,
              background: accent, color: '#fff', fontFamily: 'inherit',
              fontSize: 16, fontWeight: 600, letterSpacing: -.3, cursor: 'pointer',
              boxShadow: `0 4px 12px ${accent}40`,
            }}>
              <Icon name="sparkle" size={15} color="#fff" stroke={2.2}/>
              <span style={{ marginLeft: 6 }}>Extraer receta</span>
            </button>

            <div style={{
              padding: '16px 14px', marginTop: 20, borderRadius: 12,
              background: dark ? 'rgba(107,142,90,.18)' : 'rgba(107,142,90,.12)',
              display: 'flex', gap: 10, alignItems: 'flex-start',
            }}>
              <Icon name="archive" size={16} color="#6B8E5A" stroke={2.2}/>
              <div style={{ fontSize: 13, color: dark ? 'rgba(235,235,245,.85)' : '#3a4a30', lineHeight: 1.45, textWrap: 'pretty' }}>
                Guardamos una copia local para que no la pierdas si el enlace deja de funcionar.
              </div>
            </div>
          </div>
        )}

        {stage === 'extracting' && (
          <div style={{
            flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
            padding: '80px 28px', gap: 24, textAlign: 'center',
          }}>
            <div style={{
              width: 60, height: 60, borderRadius: '50%',
              border: `3px solid ${dark ? 'rgba(255,255,255,.12)' : 'rgba(0,0,0,.08)'}`,
              borderTopColor: accent,
              animation: 'spin 1s linear infinite',
            }}/>
            <div>
              <div style={{ fontSize: 19, fontWeight: 600, color: text, letterSpacing: -.4 }}>Extrayendo receta…</div>
              <div style={{ fontSize: 14, color: sec, marginTop: 6, lineHeight: 1.4, maxWidth: 260 }}>
                Estamos leyendo el contenido y separando ingredientes y pasos.
              </div>
            </div>
          </div>
        )}

        {stage === 'preview' && data && (
          <div style={{ padding: '8px 16px 32px' }}>
            <div style={{
              padding: '12px 14px', borderRadius: 12, marginBottom: 14,
              background: dark ? 'rgba(212,165,90,.18)' : 'rgba(212,165,90,.18)',
              display: 'flex', gap: 10, alignItems: 'flex-start',
            }}>
              <Icon name="sparkle" size={16} color="#B8842F" stroke={2.2}/>
              <div style={{ fontSize: 13, color: dark ? 'rgba(255,235,200,.9)' : '#7a5418', lineHeight: 1.4, textWrap: 'pretty' }}>
                <strong>Revisa antes de guardar.</strong> Hemos extraído lo que hemos podido — toca cualquier campo para corregirlo.
              </div>
            </div>

            <div style={{ background: cardBg, borderRadius: 14, overflow: 'hidden', marginBottom: 16 }}>
              <div style={{ height: 140, position: 'relative', background: '#ddd' }}>
                <img src={data.cover} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }}/>
                <div style={{
                  position: 'absolute', top: 10, right: 10,
                  padding: '5px 10px', borderRadius: 100, background: 'rgba(0,0,0,.5)',
                  color: '#fff', fontSize: 11, fontWeight: 500, backdropFilter: 'blur(8px)',
                }}>Cambiar foto</div>
              </div>
              <div style={{ padding: 14 }}>
                <EditField dark={dark} accent={accent} value={data.title} onChange={(v) => setData({...data, title: v})}
                  placeholder="Título de la receta" big/>
                <div style={{ display: 'flex', gap: 8, marginTop: 12, alignItems: 'center' }}>
                  <SourceBadge source={data.source} label={data.sourceLabel} dark={dark}/>
                  <span style={{ fontSize: 12, color: sec, marginLeft: 'auto' }}>{data.timeMin} min · {data.servings} raciones</span>
                </div>
              </div>
            </div>

            <div style={{ background: cardBg, borderRadius: 14, padding: '14px 14px 6px', marginBottom: 14 }}>
              <div style={{ fontSize: 12, color: sec, textTransform: 'uppercase', letterSpacing: .4, fontWeight: 600, marginBottom: 8 }}>Ingredientes</div>
              {data.ingredients.map((ing, i) => (
                <EditField key={i} dark={dark} accent={accent} value={ing} onChange={(v) => {
                  const ings = [...data.ingredients]; ings[i] = v; setData({...data, ingredients: ings});
                }} placeholder="Ingrediente"/>
              ))}
            </div>

            <div style={{ background: cardBg, borderRadius: 14, padding: '14px 14px 6px' }}>
              <div style={{ fontSize: 12, color: sec, textTransform: 'uppercase', letterSpacing: .4, fontWeight: 600, marginBottom: 8 }}>Pasos</div>
              {data.steps.map((s, i) => (
                <div key={i} style={{ display: 'flex', gap: 8, alignItems: 'flex-start', marginBottom: 4 }}>
                  <div style={{
                    width: 22, height: 22, borderRadius: '50%', background: `${accent}1f`, color: accent,
                    fontSize: 12, fontWeight: 700, flexShrink: 0, marginTop: 8,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>{i + 1}</div>
                  <EditField dark={dark} accent={accent} value={s} onChange={(v) => {
                    const ss = [...data.steps]; ss[i] = v; setData({...data, steps: ss});
                  }} placeholder="Paso" multiline/>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
window.AddRecipeScreen = AddRecipeScreen;

function EditField({ value, onChange, placeholder, dark, accent, big, multiline }) {
  const text = dark ? '#fff' : '#0a0a0a';
  const Tag = multiline ? 'textarea' : 'input';
  return (
    <Tag value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder}
      rows={multiline ? 2 : undefined}
      style={{
        width: '100%', border: 0, background: 'transparent', outline: 'none',
        padding: '8px 0', color: text, letterSpacing: -.2, fontFamily: 'inherit',
        fontSize: big ? 19 : 15, fontWeight: big ? 700 : 400,
        borderBottom: `.5px solid ${dark ? 'rgba(255,255,255,.08)' : 'rgba(0,0,0,.07)'}`,
        resize: 'none', lineHeight: multiline ? 1.4 : undefined, textWrap: 'pretty',
      }}/>
  );
}

// ─── Onboarding ──────────────────────────────────────────────────────────────
function OnboardingScreen({ accent, onDone }) {
  const [step, setStep] = useStateD(0);
  const [icloud, setIcloud] = useStateD(false);
  const slides = [
    {
      illustration: <ArchiveIllo accent={accent}/>,
      title: 'Guarda recetas que no se pierden',
      sub: 'Cada vez que añades una receta, hacemos una copia local. Aunque desaparezca el enlace original, tú la conservas.',
    },
    {
      illustration: <ListsIllo accent={accent}/>,
      title: 'Organiza por listas y etiquetas',
      sub: 'Vegetarianas, postres, Nochevieja… o lo que quieras. Etiqueta lo que cocinas a menudo y encuéntralo en segundos.',
    },
    {
      illustration: <CloudIllo accent={accent}/>,
      title: 'Sincroniza con iCloud',
      sub: 'Tus recetas, en todos tus dispositivos. Sin cuentas, sin contraseñas. Solo iCloud.',
      hasSync: true,
    },
  ];
  const cur = slides[step];

  return (
    <div style={{
      position: 'absolute', inset: 0, background: '#fff',
      display: 'flex', flexDirection: 'column', zIndex: 200, padding: '54px 0 0',
    }}>
      <div style={{ flex: 1, padding: '20px 32px', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', textAlign: 'center', gap: 28 }}>
        <div style={{ height: 200, width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {cur.illustration}
        </div>
        <div>
          <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -.4, color: '#0a0a0a', textWrap: 'pretty', lineHeight: 1.15 }}>
            {cur.title}
          </div>
          <div style={{ fontSize: 16, color: 'rgba(60,60,67,.7)', marginTop: 14, lineHeight: 1.4, textWrap: 'pretty', maxWidth: 320 }}>
            {cur.sub}
          </div>
        </div>

        {cur.hasSync && (
          <button onClick={() => setIcloud(!icloud)} style={{
            display: 'flex', alignItems: 'center', gap: 10, padding: '14px 18px',
            background: icloud ? `${accent}14` : '#F2F2F7',
            border: `1.5px solid ${icloud ? accent : 'transparent'}`,
            borderRadius: 14, cursor: 'pointer', fontFamily: 'inherit',
          }}>
            <div style={{
              width: 22, height: 22, borderRadius: 6,
              background: icloud ? accent : '#fff',
              border: `1.5px solid ${icloud ? accent : 'rgba(0,0,0,.2)'}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              {icloud && <Icon name="check" size={14} color="#fff" stroke={3}/>}
            </div>
            <span style={{ fontSize: 16, fontWeight: 500, color: '#0a0a0a', letterSpacing: -.2 }}>Activar iCloud</span>
          </button>
        )}
      </div>

      {/* Dots */}
      <div style={{ display: 'flex', justifyContent: 'center', gap: 6, marginBottom: 28 }}>
        {slides.map((_, i) => (
          <div key={i} style={{
            width: i === step ? 24 : 6, height: 6, borderRadius: 3,
            background: i === step ? accent : 'rgba(0,0,0,.15)',
            transition: 'all .3s',
          }}/>
        ))}
      </div>

      <div style={{ padding: '0 16px 40px' }}>
        <button onClick={() => step === slides.length - 1 ? onDone() : setStep(step + 1)} style={{
          width: '100%', padding: '16px', borderRadius: 14, border: 0, cursor: 'pointer',
          background: accent, color: '#fff', fontFamily: 'inherit',
          fontSize: 17, fontWeight: 600, letterSpacing: -.3,
          boxShadow: `0 6px 16px ${accent}40`,
        }}>
          {step === slides.length - 1 ? 'Empezar' : 'Continuar'}
        </button>
        {step < slides.length - 1 && (
          <button onClick={onDone} style={{
            width: '100%', padding: '12px', marginTop: 6, border: 0, cursor: 'pointer',
            background: 'transparent', color: 'rgba(60,60,67,.6)', fontFamily: 'inherit',
            fontSize: 15, fontWeight: 500, letterSpacing: -.2,
          }}>
            Saltar
          </button>
        )}
      </div>
    </div>
  );
}
window.OnboardingScreen = OnboardingScreen;

// Onboarding illustrations — line drawings, no stock photos
function ArchiveIllo({ accent }) {
  return (
    <svg width="200" height="180" viewBox="0 0 200 180" fill="none">
      <rect x="40" y="50" width="120" height="110" rx="14" stroke={accent} strokeWidth="2.5"/>
      <path d="M40 76 L160 76" stroke={accent} strokeWidth="2.5"/>
      <rect x="84" y="62" width="32" height="6" rx="3" fill={accent}/>
      <path d="M70 100 L130 100 M70 118 L130 118 M70 136 L110 136" stroke={accent} strokeWidth="2.5" strokeLinecap="round" opacity=".5"/>
      <circle cx="148" cy="44" r="20" fill="#fff" stroke={accent} strokeWidth="2.5"/>
      <path d="M141 44 L146 49 L156 39" stroke={accent} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
      <path d="M22 32 L30 24 M28 38 L34 32" stroke={accent} strokeWidth="2" strokeLinecap="round" opacity=".5"/>
    </svg>
  );
}
function ListsIllo({ accent }) {
  return (
    <svg width="200" height="180" viewBox="0 0 200 180" fill="none">
      <rect x="22" y="40" width="76" height="60" rx="12" stroke={accent} strokeWidth="2.5"/>
      <circle cx="40" cy="58" r="8" fill={accent} opacity=".25"/>
      <path d="M34 80 L86 80 M34 90 L72 90" stroke={accent} strokeWidth="2" strokeLinecap="round" opacity=".5"/>
      <rect x="106" y="40" width="76" height="60" rx="12" stroke={accent} strokeWidth="2.5"/>
      <circle cx="124" cy="58" r="8" fill={accent} opacity=".25"/>
      <path d="M118 80 L170 80 M118 90 L156 90" stroke={accent} strokeWidth="2" strokeLinecap="round" opacity=".5"/>
      <rect x="22" y="110" width="76" height="55" rx="12" stroke={accent} strokeWidth="2.5"/>
      <circle cx="40" cy="128" r="8" fill={accent} opacity=".25"/>
      <path d="M34 148 L86 148 M34 158 L72 158" stroke={accent} strokeWidth="2" strokeLinecap="round" opacity=".5"/>
      <rect x="106" y="110" width="76" height="55" rx="12" stroke={accent} strokeWidth="2.5" strokeDasharray="4 4" opacity=".4"/>
      <path d="M134 130 L154 130 M144 120 L144 140" stroke={accent} strokeWidth="2.5" strokeLinecap="round"/>
    </svg>
  );
}
function CloudIllo({ accent }) {
  return (
    <svg width="220" height="180" viewBox="0 0 220 180" fill="none">
      <path d="M60 100 Q40 100 40 80 Q40 60 62 60 Q64 38 90 38 Q116 38 122 60 Q146 58 150 80 Q150 100 130 100 Z" stroke={accent} strokeWidth="2.5" fill={`${accent}10`}/>
      <path d="M95 110 L95 140 M85 130 L95 140 L105 130" stroke={accent} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
      <rect x="55" y="148" width="80" height="20" rx="6" stroke={accent} strokeWidth="2.5"/>
      <circle cx="170" cy="50" r="3" fill={accent} opacity=".4"/>
      <circle cx="190" cy="80" r="2" fill={accent} opacity=".4"/>
      <circle cx="30" cy="120" r="2.5" fill={accent} opacity=".4"/>
      <path d="M180 30 L184 26 M180 30 L184 34 M180 30 L176 26 M180 30 L176 34" stroke={accent} strokeWidth="1.5" strokeLinecap="round" opacity=".4"/>
    </svg>
  );
}
