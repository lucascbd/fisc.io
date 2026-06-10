        // SWIPE NAVIGATION - Mudar de aba deslizando
        (function() {
            let startX = 0, startY = 0, startTime = 0;
            
            // Função para obter tabs disponíveis dinamicamente
            function getAvailableTabs() {
                const allTabs = ['home', 'expenses', 'openfinance', 'charts', 'inflation', 'income', 'agent'];
                const available = [];
                for (const t of allTabs) {
                    const tab = document.getElementById(t + 'Tab');
                    if (!tab) continue;
                    // Para users, verificar se o botão está visível (admin)
                    if (t === 'users') {
                        const btn = document.getElementById('usersBtn');
                        if (btn && !btn.classList.contains('hidden')) {
                            available.push(t);
                        }
                    } else {
                        available.push(t);
                    }
                }
                return available;
            }
            
            function getActiveTabIndex() {
                const tabs = getAvailableTabs();
                for (let i = 0; i < tabs.length; i++) {
                    const tab = document.getElementById(tabs[i] + 'Tab');
                    if (tab && !tab.classList.contains('hidden')) return i;
                }
                return 0;
            }
            
            function switchToTab(idx) {
                const tabs = getAvailableTabs();
                if (idx < 0 || idx >= tabs.length) return;
                const name = tabs[idx];
                // Botão users tem ID diferente (usersBtn em vez de tabUsers)
                const btnId = name === 'users' ? 'usersBtn' : 'tab' + name.charAt(0).toUpperCase() + name.slice(1);
                const btn = document.getElementById(btnId);
                if (btn) {
                    showTab(name, btn);
                    // Scroll tab bar para mostrar o botão ativo
                    btn.scrollIntoView({ behavior: 'smooth', inline: 'center', block: 'nearest' });
                }
            }
            
            document.addEventListener('touchstart', function(e) {
                const t = e.target;
                if (t.closest('#modalContainer') || t.closest('#notificationSettingsModal') || 
                    t.tagName === 'INPUT' || t.tagName === 'SELECT' || t.tagName === 'TEXTAREA' ||
                    t.closest('button') || t.closest('details') || t.closest('[onclick]') ||
                    t.closest('.cat-option') || t.closest('.paid-option') || t.closest('.prof-option')) {
                    startX = 0; return;
                }
                startX = e.touches[0].clientX;
                startY = e.touches[0].clientY;
                startTime = Date.now();
            }, {passive: true});
            
            document.addEventListener('touchend', function(e) {
                if (!startX) return;
                const dX = e.changedTouches[0].clientX - startX;
                const dY = Math.abs(e.changedTouches[0].clientY - startY);
                const dt = Date.now() - startTime;
                startX = 0;
                
                // ✅ Detectar scroll vs swipe:
                // - Se movimento vertical > horizontal, é scroll (não swipe)
                // - Swipe precisa ser majoritariamente horizontal
                const absX = Math.abs(dX);
                if (dY > absX) return; // Movimento mais vertical que horizontal = scroll
                if (dY > 100) return; // Muito movimento vertical = scroll
                if (dt > 500) return; // Muito lento = não é swipe
                if (absX < 80) return; // Swipe muito curto
                
                const idx = getActiveTabIndex();
                switchToTab(dX < 0 ? idx + 1 : idx - 1);
                // Hide any lingering chart tooltips after swipe (chart callbacks can re-show them)
                const _hideIds = ['inflTooltip','catInflTooltip','pvTooltip','mvmTooltip'];
                _hideIds.forEach(id => { const el = document.getElementById(id); if (el) el.style.opacity = '0'; });
                setTimeout(() => _hideIds.forEach(id => { const el = document.getElementById(id); if (el) el.style.opacity = '0'; }), 200);
            }, {passive: true});
            
            console.log('Swipe ativado');
        })();
