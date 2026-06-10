        // TARGETS
        // ============================================================================

        let targetsSortable = null;

        async function loadSidebarTargets() {
            targets = await api(`${API}/targets`).catch(() => []);
            const list = document.getElementById('sidebarTargetsList');
            if (!list) return;
            if (!targets.length) {
                list.innerHTML = '<p class="text-sm text-gray-400 p-4 text-center">Nenhum target criado</p>';
                return;
            }
            list.innerHTML = targets.map(t => `
                <div class="target-item" data-id="${t.id}" style="background: #f1f3f4; border-radius: 12px; padding: 12px; margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 2px rgba(0,0,0,0.1);">
                    <div style="display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0;">
                        <span style="font-size: 16px; color: #9aa0a6; cursor: grab; padding: 4px; flex-shrink: 0;" class="cursor-move">☰</span>
                        <span style="font-size: 1.5rem; flex-shrink: 0;">${t.emoji}</span>
                        <div style="min-width: 0;">
                            <p style="font-weight: 500; margin: 0; font-size: 14px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${t.name}</p>
                            <p style="font-size: 12px; color: #5f6368; margin: 2px 0 0 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">R$ ${formatBRL(t.monthly_amount)} · ${(t.category_ids?.length || 0)} cat.</p>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px; flex-shrink: 0;">
                        <button onclick="showTargetModal(${t.id})" style="background: none; border: none; cursor: pointer; font-size: 14px;">✏️</button>
                        <button onclick="deleteTarget(${t.id})" style="background: none; border: none; cursor: pointer; font-size: 14px;">🗑️</button>
                    </div>
                </div>
            `).join('');

            // Drag-and-drop
            if (targetsSortable && targetsSortable.el !== list) {
                try { targetsSortable.destroy(); } catch(e) {}
                targetsSortable = null;
            }
            if (!targetsSortable) targetsSortable = Sortable.create(list, {
                animation: 150,
                handle: '.cursor-move',
                ghostClass: 'opacity-50',
                onEnd: async (evt) => {
                    const items = list.querySelectorAll('.target-item');
                    await Promise.all(Array.from(items).map((el, i) =>
                        api(`${API}/targets/${el.dataset.id}/reorder`, { method: 'PUT', body: JSON.stringify({ sort_order: i }) })
                    ));
                    targets = await api(`${API}/targets`).catch(() => targets);
                    loadDashboardData();
                }
            });
        }

        // ── Pie exp type dropdown ──
        function togglePieExpDropdown() {
            document.getElementById('pieExpDropdown')?.classList.toggle('hidden');
        }
        function updatePieExpText() {
            const cbs = Array.from(document.querySelectorAll('.pie-exp-type:checked'));
            const total = document.querySelectorAll('.pie-exp-type').length;
            const text = cbs.length === 0 ? 'Nenhuma' : cbs.length === total ? 'Todas' :
                cbs[0]?.value === 'individual' ? 'Individuais' : 'Compartilhadas';
            const el = document.getElementById('pieExpSelectedText');
            if (el) el.textContent = text;
        }
        // Close pie exp dropdown on outside click
        document.addEventListener('click', e => {
            const btn = document.getElementById('pieExpDropdownBtn');
            const dd = document.getElementById('pieExpDropdown');
            if (dd && btn && !dd.contains(e.target) && !btn.contains(e.target)) dd.classList.add('hidden');
        });

        // ── Target category dropdown helpers ──
        function tgtUpdatePm() {
            const _dark = document.body.classList.contains('dark-mode');
            const _selBg  = _dark ? '#8ab4f8' : '#e8f0fe';
            const _selBdr = _dark ? '#8ab4f8' : '#1a73e8';
            const _defBg  = _dark ? '#3c4043' : '#f8f9fa';
            const _shadow = _dark ? '0 0 0 2px rgba(138,180,248,0.3)' : 'none';
            document.querySelectorAll('.tgt-pm-cb').forEach(cb => {
                const wrap = document.getElementById('tgt_pm_wrap_' + cb.value);
                if (!wrap) return;
                const on = cb.checked;
                wrap.classList.toggle('selected', on);
                wrap.style.borderColor = on ? _selBdr : 'transparent';
                wrap.style.background  = on ? _selBg  : _defBg;
                wrap.style.boxShadow   = on ? _shadow : 'none';
            });
        }

        function tgtToggleAll(checked) {
            document.querySelectorAll('.tgt-cat-cb').forEach(cb => cb.checked = checked);
            tgtUpdateCatText();
        }
        function tgtUpdateCatText() {
            const all = document.querySelectorAll('.tgt-cat-cb');
            const checked = Array.from(all).filter(cb => cb.checked);
            const allCb = document.getElementById('tgtCatAll');
            if (allCb) allCb.checked = checked.length === all.length;
            const textEl = document.getElementById('tgtCatBtnText');
            if (!textEl) return;
            if (checked.length === 0 || checked.length === all.length) {
                textEl.textContent = 'Todas';
            } else {
                textEl.textContent = checked.map(cb => {
                    const c = byId(categories, parseInt(cb.value));
                    return c ? (c.icon ? c.icon + ' ' + c.name : c.name) : '';
                }).filter(Boolean).join(', ');
            }
        }
        // Close target cat dropdown on outside click
        document.addEventListener('click', e => {
            const wrapper = document.getElementById('tgtCatWrapper');
            const dd = document.getElementById('tgtCatDropdown');
            if (dd && wrapper && !wrapper.contains(e.target)) dd.classList.add('hidden');
        });

        async function deleteTarget(id) {
            if (!confirm('Remover este target?')) return;
            await api(`${API}/targets/${id}`, { method: 'DELETE' });
            targets = targets.filter(t => t.id !== id);
            loadSidebarTargets();
            loadDashboardData();
        }

        async function showTargetModal(targetId = null) {
            // Ensure categories loaded
            if (!categories.length) categories = await api(`${API}/categories`).catch(() => []);
            const tgt = targetId ? targets.find(t => t.id === targetId) : null;
            const selCatIds = tgt?.category_ids || [];
            const selPmIds = tgt?.payment_methods || [];
            const isDark = document.body.classList.contains('dark-mode');
            const optionBg = isDark ? '#3c4043' : '#f8f9fa';
            const optionSelectedBg = isDark ? '#8ab4f8' : '#e8f0fe';
            const optionBorder = isDark ? '#8ab4f8' : '#1a73e8';

            const _savedScrollY = window.scrollY;
            document.body.classList.add('modal-open');
            document.body.style.top = `-${_savedScrollY}px`;
            document.getElementById('modalContainer').innerHTML = `
                <div class="fixed inset-0 flex items-center justify-center z-50" style="background:rgba(0,0,0,0.32);backdrop-filter:blur(4px);padding:1rem;">
                    <div class="bg-white w-full max-w-md overflow-hidden flex flex-col" style="border-radius:28px;box-shadow:0 4px 8px 3px rgba(60,64,67,0.15),0 1px 3px rgba(60,64,67,0.3);max-height:calc(100vh - 2rem);max-height:calc(100dvh - 2rem);">
                        <div style="background:#e8f0fe;padding:1.25rem 1.5rem;border-radius:28px 28px 0 0;flex-shrink:0;">
                            <div class="flex justify-between items-center">
                                <div class="flex items-center gap-3">
                                    <div style="width:40px;height:40px;background:#d2e3fc;border-radius:50%;display:flex;align-items:center;justify-content:center;">
                                        <span style="font-size:1.1rem;">🎯</span>
                                    </div>
                                    <h2 style="font-size:1.25rem;font-weight:500;color:#202124;margin:0;">${tgt ? 'Editar' : 'Adicionar'} target</h2>
                                </div>
                                <button type="button" onclick="closeModal()" style="width:40px;height:40px;border-radius:50%;display:flex;align-items:center;justify-content:center;background:transparent;border:none;cursor:pointer;">
                                    <span style="font-size:1.5rem;color:#5f6368;">✕</span>
                                </button>
                            </div>
                        </div>
                        <form id="targetForm" class="flex flex-col" style="flex:1;overflow:hidden;">
                            <div class="p-6 space-y-4" style="overflow-y:auto;flex:1;">
                                <div class="flex gap-3 items-end">
                                    <div style="flex:0 0 62px;">
                                        <label class="block text-sm font-medium mb-2" style="color:#5f6368;">Emoji</label>
                                        <input type="text" id="tgt_emoji" value="${tgt?.emoji || '🎯'}" maxlength="2"
                                            class="w-full border rounded-lg text-xl text-center" style="border-color:#dadce0;height:42px;padding:0 4px;">
                                    </div>
                                    <div class="flex-1">
                                        <label class="block text-sm font-medium mb-2" style="color:#5f6368;">Nome</label>
                                        <input type="text" id="tgt_name" value="${tgt?.name || ''}" placeholder="Ex: Alimentação"
                                            class="w-full px-4 border rounded-lg" style="border-color:#dadce0;height:42px;" required>
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:#5f6368;">Valor mensal (R$)</label>
                                    <input type="text" id="tgt_amount" value="${tgt?.monthly_amount || ''}"
                                        inputmode="decimal" enterkeyhint="next"
                                        onkeydown="if(event.key==='Enter'){event.preventDefault();this.blur();}"
                                        placeholder="Ex: 2000,00" class="w-full px-4 py-2 border rounded-lg" style="border-color:#dadce0;" required>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:#5f6368;">Categorias</label>
                                    <div class="relative" id="tgtCatWrapper">
                                        <button type="button" id="tgtCatBtn"
                                            onclick="event.stopPropagation(); document.getElementById('tgtCatDropdown').classList.toggle('hidden');"
                                            class="w-full px-3 py-2 text-sm flex items-center justify-between gap-2 border rounded-lg"
                                            style="border-color:#dadce0; min-height:42px; background:var(--modal-input-bg, #fff); color:var(--modal-text, #3c4043);">
                                            <span id="tgtCatBtnText" class="truncate flex-1 text-left">
                                                ${selCatIds.length === 0 ? 'Todas' : categories.filter(c=>selCatIds.includes(c.id)).map(c=>(c.icon||'')+ ' '+c.name).join(', ')}
                                            </span>
                                            <span style="color:#5f6368;flex-shrink:0;">▼</span>
                                        </button>
                                        <div id="tgtCatDropdown" class="hidden absolute left-0 right-0 border rounded-lg z-30"
                                            style="border-color:#dadce0; box-shadow:0 4px 12px rgba(60,64,67,0.25); top:calc(100% + 4px); overflow:hidden; background:#fff;">
                                            <label class="flex items-center gap-2 px-3 py-2 cursor-pointer border-b" style="border-color:#f1f3f4;"
                                                onclick="event.stopPropagation()">
                                                <input type="checkbox" id="tgtCatAll" ${selCatIds.length===0?'checked':''} onchange="tgtToggleAll(this.checked)">
                                                <span>📋</span><span class="text-sm font-medium">Todas</span>
                                            </label>
                                            <div style="max-height:180px; overflow-y:auto; scrollbar-width:thin; scrollbar-color:#dadce0 transparent;">
                                                ${categories.map(c=>`
                                                <label class="flex items-center gap-2 px-3 py-1.5 cursor-pointer">
                                                    <input type="checkbox" class="tgt-cat-cb" value="${c.id}" ${selCatIds.length===0||selCatIds.includes(c.id)?'checked':''}
                                                        onchange="tgtUpdateCatText();">
                                                    <span>${c.icon||'📁'}</span><span class="text-sm">${c.name}</span>
                                                </label>`).join('')}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:#5f6368;">Métodos de pagamento</label>
                                    <div class="flex gap-2 flex-wrap">
                                        ${userPms(user.id).map(pm => {
                                            const on = selPmIds.length===0||selPmIds.includes(pm.id);
                                            const imgHtml = pm.icon_path ? `<img src="${pm.icon_path}" style="width:26px;height:26px;object-fit:contain;">` : `<span style="width:26px;height:26px;display:inline-flex;align-items:center;justify-content:center;border-radius:50%;background:${pm.color||'#999'};font-size:12px;">💳</span>`;
                                            return `<label class="flex flex-col items-center gap-1 cursor-pointer tgt-pm-label" onclick="event.stopPropagation()">
                                                <div class="pm-option ${on?'selected':''}" id="tgt_pm_wrap_${pm.id}"
                                                     style="width:44px;height:44px;border-radius:12px;border:2px solid ${on?optionBorder:'transparent'};display:flex;align-items:center;justify-content:center;background:${on?optionSelectedBg:optionBg};box-shadow:${on&&isDark?'0 0 0 2px rgba(138,180,248,0.3)':'none'};transition:.15s;">
                                                    ${imgHtml}
                                                </div>
                                                <input type="checkbox" class="tgt-pm-cb sr-only" value="${pm.id}" ${on?'checked':''} onchange="tgtUpdatePm()">
                                                <span class="text-xs" style="max-width:48px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${pm.description}</span>
                                            </label>`;
                                        }).join('')}
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium mb-2" style="color:#5f6368;">Informação extra</label>
                                    <div class="space-y-2">
                                        <label class="flex items-center gap-3 cursor-pointer">
                                            <input type="radio" name="tgt_mode" value="daily" ${(tgt?.display_mode ?? 'daily') === 'daily' ? 'checked' : ''}
                                                onchange="document.getElementById('ticketMonthsRow').classList.add('hidden')">
                                            <span class="text-sm">R$/dia</span>
                                        </label>
                                        <label class="flex items-center gap-3 cursor-pointer">
                                            <input type="radio" name="tgt_mode" value="ticket" ${tgt?.display_mode === 'ticket' ? 'checked' : ''}
                                                onchange="document.getElementById('ticketMonthsRow').classList.remove('hidden')">
                                            <span class="text-sm">Ticket médio</span>
                                        </label>
                                        <label class="flex items-center gap-3 cursor-pointer">
                                            <input type="radio" name="tgt_mode" value="ticket_day" ${tgt?.display_mode === 'ticket_day' ? 'checked' : ''}
                                                onchange="document.getElementById('ticketMonthsRow').classList.remove('hidden')">
                                            <span class="text-sm">Ticket diário</span>
                                        </label>
                                    </div>
                                    <div id="ticketMonthsRow" class="${['ticket','ticket_day'].includes(tgt?.display_mode) ? '' : 'hidden'} mt-3">
                                        <label class="block text-sm font-medium mb-2" style="color:#5f6368;">Meses de histórico</label>
                                        <input type="number" id="tgt_ticket_months" value="${tgt?.ticket_months || 6}" min="1" max="24"
                                            class="w-full px-4 py-2 border rounded-lg" style="border-color:#dadce0;">
                                    </div>
                                </div>
                                <div id="tgtError" class="hidden text-red-600 text-sm"></div>
                            </div>
                            <div class="p-4 flex gap-3" style="border-top:1px solid #dadce0;flex-shrink:0;">
                                <button type="button" onclick="closeModal()" class="flex-1 py-3" style="background:#f1f3f4;color:#1a73e8;font-weight:500;border-radius:20px;border:none;">Cancelar</button>
                                <button type="submit" class="flex-1 py-3" style="background:#1a73e8;color:white;font-weight:500;border-radius:20px;border:none;">Salvar</button>
                            </div>
                        </form>
                    </div>
                </div>`;

            document.getElementById('targetForm').onsubmit = async (e) => {
                e.preventDefault();
                const btn = e.target.querySelector('[type=submit]');
                btn.disabled = true; btn.textContent = 'Salvando...';
                try {
                    const payload = {
                        name: document.getElementById('tgt_name').value,
                        emoji: document.getElementById('tgt_emoji').value || '🎯',
                        monthly_amount: parseFloat(document.getElementById('tgt_amount').value),
                        category_ids: (() => { const all = document.querySelectorAll('.tgt-cat-cb'); const checked = Array.from(all).filter(cb => cb.checked); return checked.length === all.length ? [] : checked.map(cb => parseInt(cb.value)); })(),
                        payment_methods: (() => { const all = document.querySelectorAll('.tgt-pm-cb'); const checked = Array.from(all).filter(cb => cb.checked); return checked.length === all.length ? [] : checked.map(cb => parseInt(cb.value)); })(),
                        display_mode: document.querySelector('input[name=tgt_mode]:checked')?.value || 'daily',
                        ticket_months: parseInt(document.getElementById('tgt_ticket_months').value) || 6,
                    };
                    if (tgt) {
                        await api(`${API}/targets/${tgt.id}`, { method: 'PUT', body: JSON.stringify(payload) });
                    } else {
                        await api(`${API}/targets`, { method: 'POST', body: JSON.stringify(payload) });
                    }
                    closeModal();
                    await loadSidebarTargets();
                    loadDashboardData();
                } catch (err) {
                    document.getElementById('tgtError').textContent = err.message;
                    document.getElementById('tgtError').classList.remove('hidden');
                    btn.disabled = false; btn.textContent = 'Salvar';
                }
            };
        }

        // ============================================================================
