        // GRÁFICOS - CHARTS
        // ============================================================================
        
        let categoryPieChart = null;
        let dailyLineChart = null;
        let chartsNeedReload = true; // Flag para controlar reload dos gráficos
        let lastChartsMonth = ''; // Último mês carregado
        let monthlyBarChart = null;

        // Plugin: faixas de semana no gráfico diário (bandas alternadas SegDom, rótulos no topo)
        const weekBandsPlugin = {
            id: 'weekBands',
            // Calcula semanas: SegDom. Semana 1 começa na primeira segunda do mês.
            // Dias antes da primeira segunda pertencem à "Sem 0" (semana do mês anterior).
            _getWeeks(yr, mn, N) {
                let firstMon = null;
                for (let d = 1; d <= N; d++) {
                    if (new Date(yr, mn - 1, d).getDay() === 1) { firstMon = d; break; }
                }
                if (firstMon === null) return [];
                const weeks = [];
                // Semana parcial do mês anterior (Sem 0)
                if (firstMon > 1) weeks.push({ num: null, start: 1, end: firstMon - 1 });
                let weekNum = 1;
                let start = firstMon;
                for (let d = start + 1; d <= N + 1; d++) {
                    const isNewWeek = d <= N && new Date(yr, mn - 1, d).getDay() === 1;
                    if (isNewWeek || d === N + 1) {
                        weeks.push({ num: weekNum, start, end: d - 1 });
                        weekNum++;
                        start = d;
                    }
                }
                return weeks;
            },
            beforeDraw(chart) {
                if (chart.canvas.id !== 'dailyLineChart') return;
                const { ctx, chartArea } = chart;
                if (!chartArea) return;
                const monthStr = document.getElementById('pieChartMonths')?.value;
                if (!monthStr) return;
                const [yr, mn] = monthStr.split('-').map(Number);
                const N = chart.data.labels.length;
                if (N < 2) return;
                const isDark = document.body.classList.contains('dark-mode');
                const bandColor = isDark ? 'rgba(255,255,255,0.05)' : 'rgba(99,102,241,0.07)';
                // Usa posição real dos pontos do dataset (funciona com qualquer offset/scale do Chart.js)
                const meta = chart.getDatasetMeta(0);
                if (!meta.data.length) return;
                // Banda começa exatamente no tick da segunda-feira (w.start) e termina no tick da próxima segunda (w.end+1)
                const px = d => d <= N ? (meta.data[d - 1]?.x ?? chartArea.left) : chartArea.right;
                const weeks = this._getWeeks(yr, mn, N);
                ctx.save();
                weeks.forEach((w, i) => {
                    if (i % 2 === 1) {
                        const x1 = px(w.start);
                        const x2 = px(w.end + 1);
                        ctx.fillStyle = bandColor;
                        ctx.fillRect(x1, chartArea.top, x2 - x1, chartArea.bottom - chartArea.top);
                    }
                });
                ctx.restore();
            },
            afterDraw(chart) {
                if (chart.canvas.id !== 'dailyLineChart') return;
                const { ctx, chartArea } = chart;
                if (!chartArea) return;
                const monthStr = document.getElementById('pieChartMonths')?.value;
                if (!monthStr) return;
                const [yr, mn] = monthStr.split('-').map(Number);
                const N = chart.data.labels.length;
                if (N < 2) return;
                const isDark = document.body.classList.contains('dark-mode');
                const labelColor = isDark ? '#9aa0a6' : '#80868b';
                const meta = chart.getDatasetMeta(0);
                if (!meta.data.length) return;
                const px = d => d <= N ? (meta.data[d - 1]?.x ?? chartArea.left) : chartArea.right;
                const weeks = this._getWeeks(yr, mn, N);
                ctx.save();
                ctx.font = '10px sans-serif';
                ctx.fillStyle = labelColor;
                ctx.textAlign = 'center';
                ctx.textBaseline = 'bottom';
                weeks.forEach(w => {
                    const x1 = px(w.start);
                    const x2 = px(w.end + 1);
                    const cx = (x1 + x2) / 2;
                    ctx.fillText(w.num === null ? 'Sem 0' : `Sem ${w.num}`, cx, chartArea.top - 2);
                });
                ctx.restore();
                // Triângulo ▲ vermelho abaixo do dia vigente
                const now = new Date();
                if (now.getFullYear() === yr && now.getMonth() + 1 === mn) {
                    const today = now.getDate();
                    if (today >= 1 && today <= N) {
                        const tx = meta.data[today - 1]?.x;
                        if (tx != null) {
                            const sz = 3;
                            const axisBottom = chart.scales.x?.bottom ?? (chartArea.bottom + 24);
                            const ty = axisBottom - 2;
                            ctx.save();
                            ctx.fillStyle = '#ef4444';
                            ctx.beginPath();
                            ctx.moveTo(tx, ty);
                            ctx.lineTo(tx - sz, ty + sz * 2);
                            ctx.lineTo(tx + sz, ty + sz * 2);
                            ctx.closePath();
                            ctx.fill();
                            ctx.restore();
                        }
                    }
                }
            }
        };

        // Plugin: coeficiente de orçamento ("C +x,xx") no canto do gráfico diário.
        // Lê chart.options.budgetCoeff (não closure) — obrigatório porque upsertChart
        // reutiliza a instância e plugins inline só são registrados na criação.
        const budgetCoeffPlugin = {
            id: 'budgetCoeff',
            afterDraw(chart) {
                const coeff = chart.options.budgetCoeff;
                if (coeff == null) return;
                const { ctx, chartArea } = chart;
                if (!chartArea) return;
                const sign = coeff >= 0 ? '+' : '';
                const label = 'C ' + sign + coeff.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                const color = coeff >= 0 ? '#22c55e' : '#ef4444';
                ctx.save();
                ctx.font = 'bold 11px sans-serif';
                ctx.fillStyle = color;
                ctx.textAlign = 'right';
                ctx.textBaseline = 'top';
                ctx.fillText(label, chartArea.right - 6, chartArea.top + 4);
                ctx.restore();
            }
        };

        let myInflationChart = null;
        let adjustedBarChart = null;
        let adjustedDonutChart = null;
        let categoryInflationChart = null;
        let priceVolumeChart = null;
        let mvmBarChart = null;

        function toggleBarChartDropdown() {
            const dropdown = document.getElementById('barChartDropdown');
            const isHidden = dropdown.classList.contains('hidden');
            // Fechar outros dropdowns primeiro
            document.getElementById('catFilterDropdown')?.classList.add('hidden');
            document.getElementById('userFilterDropdown')?.classList.add('hidden');
            // Abrir/fechar este
            if (isHidden) {
                dropdown.classList.remove('hidden');
            } else {
                dropdown.classList.add('hidden');
            }
        }


        // Filtro de categorias no gráfico de barras
        let selectedCatIds = [];
        let barExpTypeFilter = ['individual', 'compartilhada']; // persiste ao mudar mês
        
        function toggleCatFilterDropdown() {
            const dd = document.getElementById('catFilterDropdown');
            const isHidden = dd.classList.contains('hidden');
            // Fechar outros dropdowns primeiro
            document.getElementById('barChartDropdown')?.classList.add('hidden');
            document.getElementById('userFilterDropdown')?.classList.add('hidden');
            // Abrir/fechar este
            if (isHidden) {
                dd.classList.remove('hidden');
            } else {
                dd.classList.add('hidden');
            }
        }
        
        function updateCatFilterText() {
            const total = document.querySelectorAll('.cat-filter').length;
            const sel = selectedCatIds.length;
            let txt = sel === 0 ? 'Nenhuma' : sel >= total ? 'Todas' : sel + ' sel.';
            document.getElementById('catFilterSelectedText').textContent = txt;
        }
        
        function toggleCatFilter(catId) {
            const idx = selectedCatIds.indexOf(catId);
            if (idx > -1) selectedCatIds.splice(idx, 1);
            else selectedCatIds.push(catId);
            
            // Atualizar checkbox "Todas"
            const allCheckbox = document.getElementById('catFilterAll');
            if (allCheckbox) {
                allCheckbox.checked = selectedCatIds.length === categories.length;
            }
            
            updateCatFilterText();
            updatePmBarChart?.();
        }
        
        function toggleAllCategories(checked) {
            if (checked) {
                selectedCatIds = Array.from(document.querySelectorAll('.cat-filter')).map(cb => parseInt(cb.value));
            } else {
                selectedCatIds = [];
            }
            
            // Atualizar todos os checkboxes individuais
            document.querySelectorAll('.cat-filter').forEach(cb => {
                cb.checked = checked;
            });
            
            updateCatFilterText();
            updatePmBarChart?.();
        }

        function toggleUserFilterDropdown() {
            const dropdown = document.getElementById('userFilterDropdown');
            const isHidden = dropdown.classList.contains('hidden');
            // Fechar outros dropdowns primeiro
            document.getElementById('catFilterDropdown')?.classList.add('hidden');
            document.getElementById('barChartDropdown')?.classList.add('hidden');
            // Abrir/fechar este
            if (isHidden) {
                dropdown.classList.remove('hidden');
            } else {
                dropdown.classList.add('hidden');
            }
        }

        function updateBarChartSelectedText() {
            const checkboxes = document.querySelectorAll('.bar-chart-month:checked');
            const count = checkboxes.length;
            const text = count === 0 ? 'Nenhum' :
                         count === 1 ? '1 mês' :
                         `${count} meses`;
            document.getElementById('barChartSelectedText').textContent = text;
        }

        function toggleBarYearCollapse(year) {
            const div = document.getElementById(`bar-yr-months-${year}`);
            const arrow = document.getElementById(`bar-yr-arrow-${year}`);
            if (!div) return;
            const hidden = div.style.display === 'none';
            div.style.display = hidden ? '' : 'none';
            if (arrow) arrow.textContent = hidden ? '▼' : '▶';
        }
        function toggleBarYear(year, checked) {
            document.querySelectorAll(`.bar-chart-month[data-year="${year}"]`).forEach(cb => { cb.checked = checked; });
            updateBarChartSelectedText();
            updateBarChartFiltersDebounced();
        }
        function syncBarYearCheckbox(year) {
            const all = document.querySelectorAll(`.bar-chart-month[data-year="${year}"]`);
            const checked = document.querySelectorAll(`.bar-chart-month[data-year="${year}"]:checked`);
            const yearCb = document.querySelector(`.bar-year-cb[data-year="${year}"]`);
            if (yearCb) yearCb.checked = all.length > 0 && all.length === checked.length;
        }

        function updateUserFilterSelectedText() {
            const cbs = Array.from(document.querySelectorAll('.expense-type-filter:checked'));
            const total = document.querySelectorAll('.expense-type-filter').length;
            const text = cbs.length === 0 ? 'Nenhuma' : cbs.length === total ? 'Todas' :
                cbs[0]?.value === 'individual' ? 'Individuais' : 'Compartilhadas';
            const el = document.getElementById('userFilterSelectedText');
            if (el) el.textContent = text;
        }

        // Fechar dropdowns ao clicar fora
        document.addEventListener('click', function(event) {
            const barDropdown = document.getElementById('barChartDropdown');
            const barBtn = document.getElementById('barChartDropdownBtn');
            if (barDropdown && barBtn && !barDropdown.contains(event.target) && !barBtn.contains(event.target)) {
                barDropdown.classList.add('hidden');
            }
            
            const userDropdown = document.getElementById('userFilterDropdown');
            const userBtn = document.getElementById('userFilterDropdownBtn');
            if (userDropdown && userBtn && !userDropdown.contains(event.target) && !userBtn.contains(event.target)) {
                userDropdown.classList.add('hidden');
            }
        });

        async function loadCharts() {
            await loadAvailableMonths();
            await updatePieChartFilters();
            await updateBarChartFilters();
            if (!window._allIpcaMonths?.length) {
                try {
                    const r = await api(`${API}/inflation/months`).catch(() => ({months:[]}));
                    window._allIpcaMonths = r.months || [];
                } catch(e) { window._allIpcaMonths = []; }
            }
            initMvMSelectors();
            updateMvMChart();
        }

        // ── Inflation filter state ──
        let inflSelectedCatIds = null;  // null = all; [] = none explicitly selected
        let inflLoaded = false;

        function toggleInflMonthDropdown() {
            const dd = document.getElementById('inflMonthDropdown');
            ['inflCatDropdown','inflUserDropdown'].forEach(id => document.getElementById(id)?.classList.add('hidden'));
            dd.classList.toggle('hidden');
        }
        function toggleInflCatDropdown() {
            const dd = document.getElementById('inflCatDropdown');
            ['inflMonthDropdown','inflUserDropdown'].forEach(id => document.getElementById(id)?.classList.add('hidden'));
            dd.classList.toggle('hidden');
        }
        function toggleInflUserDropdown() {
            const dd = document.getElementById('inflUserDropdown');
            ['inflMonthDropdown','inflCatDropdown'].forEach(id => document.getElementById(id)?.classList.add('hidden'));
            dd.classList.toggle('hidden');
        }
        // Close inflation dropdowns on outside click
        document.addEventListener('click', function(e) {
            ['inflMonth','inflCat','inflUser'].forEach(prefix => {
                const btn = document.getElementById(prefix + 'DropdownBtn');
                const dd = document.getElementById(prefix + 'Dropdown');
                if (btn && dd && !btn.contains(e.target) && !dd.contains(e.target)) dd.classList.add('hidden');
            });
        });

        function updateInflMonthText() {
            const cbs = document.querySelectorAll('.infl-month-cb:checked');
            const total = document.querySelectorAll('.infl-month-cb').length;
            document.getElementById('inflMonthSelectedText').textContent =
                cbs.length === 0 ? 'Nenhum' : cbs.length === total ? 'Todos' : cbs.length + ' meses';
        }
        function toggleInflYear(year, checked) {
            document.querySelectorAll(`.infl-month-cb[data-year="${year}"]`).forEach(cb => cb.checked = checked);
            updateInflMonthText();
            loadInflationDebounced();
        }
        function syncInflYearCheckbox(year) {
            const all = document.querySelectorAll(`.infl-month-cb[data-year="${year}"]`);
            const checked = document.querySelectorAll(`.infl-month-cb[data-year="${year}"]:checked`);
            const yearCb = document.querySelector(`.infl-year-cb[data-year="${year}"]`);
            if (yearCb) yearCb.checked = all.length > 0 && all.length === checked.length;
        }
        function toggleInflYearCollapse(year) {
            const div = document.getElementById(`infl-yr-months-${year}`);
            const arrow = document.getElementById(`infl-yr-arrow-${year}`);
            if (!div) return;
            const hidden = div.style.display === 'none';
            div.style.display = hidden ? '' : 'none';
            if (arrow) arrow.textContent = hidden ? '▼' : '▶';
        }
        function updateInflCatText() {
            const total = document.querySelectorAll('.infl-cat-cb').length;
            const sel = inflSelectedCatIds.length;
            document.getElementById('inflCatSelectedText').textContent =
                sel === 0 ? 'Nenhuma' : sel >= total ? 'Todas' : sel + ' sel.';
        }
        function updateInflUserText() {
            const cbs = Array.from(document.querySelectorAll('.infl-user-cb:checked'));
            const total = document.querySelectorAll('.infl-user-cb').length;
            const text = cbs.length === 0 ? 'Nenhuma' : cbs.length === total ? 'Todas' :
                cbs[0]?.value === 'individual' ? 'Individuais' : 'Compartilhadas';
            const el = document.getElementById('inflUserSelectedText');
            if (el) el.textContent = text;
        }
        function toggleInflCat(catId) {
            if (inflSelectedCatIds === null) inflSelectedCatIds = Array.from(document.querySelectorAll('.infl-cat-cb')).map(cb => parseInt(cb.value));
            const idx = inflSelectedCatIds.indexOf(catId);
            if (idx > -1) inflSelectedCatIds.splice(idx, 1); else inflSelectedCatIds.push(catId);
            const allCb = document.getElementById('inflCatAll');
            if (allCb) allCb.checked = inflSelectedCatIds.length === document.querySelectorAll('.infl-cat-cb').length;
            updateInflCatText();
            loadInflationDebounced();
        }
        function toggleAllInflCats(checked) {
            inflSelectedCatIds = checked ? Array.from(document.querySelectorAll('.infl-cat-cb')).map(cb => parseInt(cb.value)) : [];
            document.querySelectorAll('.infl-cat-cb').forEach(cb => cb.checked = checked);
            const allCb = document.getElementById('inflCatAll');
            if (allCb) allCb.checked = checked;
            updateInflCatText();
            loadInflationDebounced();
        }

        // Helper: show/hide inflation chart messages without destroying the canvas
        function showInflMsg(prefix, msg) {
            const msgEl = document.getElementById(prefix + 'Msg');
            const wrapEl = document.getElementById(prefix + 'Wrap');
            if (!msgEl || !wrapEl) return;
            if (msg) {
                msgEl.textContent = msg;
                msgEl.classList.remove('hidden');
                wrapEl.style.display = 'none';
            } else {
                msgEl.classList.add('hidden');
                msgEl.textContent = '';
                wrapEl.style.display = '';
            }
        }

        // ── Shared external tooltip helper ──
        function showChartTooltip(id, chart, tooltip, buildHtml) {
            let el = document.getElementById(id);
            if (!el) {
                el = document.createElement('div');
                el.id = id;
                el.style.cssText = 'position:fixed;pointer-events:none;z-index:9999;border-radius:8px;padding:10px 12px;font-size:12px;line-height:1.6;white-space:nowrap;box-shadow:0 2px 8px rgba(0,0,0,0.3);transition:opacity 0.1s;';
                document.body.appendChild(el);
            }
            if (tooltip.opacity === 0 || _suppressTooltips) { el.style.opacity = '0'; return; }

            const dark = document.body.classList.contains('dark-mode');
            el.style.background = dark ? '#3c4043' : '#fff';
            el.style.color = dark ? '#e8eaed' : '#202124';
            el.style.border = `1px solid ${dark ? '#5f6368' : '#dadce0'}`;
            el.innerHTML = buildHtml(dark);
            el.style.opacity = '1';

            // Smart positioning: stay within viewport
            const rect = chart.canvas.getBoundingClientRect();
            const pad = 8;
            let x = rect.left + tooltip.caretX + 14;
            let y = rect.top  + tooltip.caretY - 10;

            // Measure after render
            const w = el.offsetWidth;
            const h = el.offsetHeight;
            if (x + w > window.innerWidth  - pad) x = rect.left + tooltip.caretX - w - 14;
            if (x < pad) x = pad;
            if (y + h > window.innerHeight - pad) y = window.innerHeight - h - pad;
            if (y < pad) y = pad;

            el.style.left = x + 'px';
            el.style.top  = y + 'px';
        }

        // Oculta tooltips externos ao rolar ou trocar de aba (evita tooltip "voando")
        let _suppressTooltips = false;
        let _suppressTooltipTimer = null;
        function _hideCustomTooltips() {
            // Sem cache: os elementos são criados sob demanda em showChartTooltip
            ['inflTooltip','catInflTooltip','pvTooltip','mvmTooltip'].forEach(id => {
                const el = document.getElementById(id);
                if (el) el.style.opacity = '0';
            });
        }
        function _suppressTooltipsNow() {
            _hideCustomTooltips();
            _suppressTooltips = true;
            clearTimeout(_suppressTooltipTimer);
            _suppressTooltipTimer = setTimeout(() => { _suppressTooltips = false; }, 300);
        }
        // capture:true pega scroll de containers internos; touchmove cobre o caso
        // mobile em que a página não rola mais (sem evento scroll) mas o Chart.js
        // continua re-exibindo o tooltip a cada movimento do dedo sobre o canvas
        window.addEventListener('scroll', _suppressTooltipsNow, { capture: true, passive: true });
        window.addEventListener('touchmove', _suppressTooltipsNow, { capture: true, passive: true });
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) _hideCustomTooltips();
        });

        async function triggerIpcaIngest() {
            const btn = document.getElementById('ipcaIngestBtn');
            const icon = document.getElementById('ipcaIngestIcon');
            btn.disabled = true;
            icon.style.animation = 'spin 1s linear infinite';
            icon.style.display = 'inline-block';
            try {
                const res = await api(`${API}/admin/ipca/ingest`, { method: 'POST' });
                icon.style.animation = '';
                icon.textContent = '✅';
                setTimeout(() => { icon.textContent = '🔄'; }, 3000);
                await loadInflation();
            } catch(e) {
                icon.style.animation = '';
                icon.textContent = '❌';
                alert('Erro ao atualizar IPCA: ' + e.message);
                setTimeout(() => { icon.textContent = '🔄'; }, 3000);
            } finally {
                btn.disabled = false;
            }
        }

        async function loadInflation() {
            // Suppress tooltips during load/rebuild to prevent phantom tooltips
            _hideCustomTooltips();
            clearTimeout(_suppressTooltipTimer);
            _suppressTooltips = true;
            _suppressTooltipTimer = setTimeout(() => { _suppressTooltips = false; }, 1500);

            const isDark = document.body.classList.contains('dark-mode');
            const textColor = isDark ? '#e8eaed' : '#202124';
            const gridColor = isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.07)';

            // ── Init filter UI on first load ──
            if (!inflLoaded) {
                inflLoaded = true;

                // Load locations
                try {
                    const locs = await api(`${API}/inflation/locations`);
                    const sel = document.getElementById('inflLocationFilter');
                    sel.innerHTML = locs.map(l => `<option value="${l.code}">${l.name}</option>`).join('');
                    // Pre-select user's preferred IPCA location
                    const prefLoc = user?.preferred_ipca_location || 1;
                    sel.value = String(prefLoc);
                } catch(e) {}

                // Months from IPCA table (grouped by year)
                const ipcaMonthsResp = await api(`${API}/inflation/months`).catch(() => ({months:[], latest: null}));
                const allIpcaMonths = ipcaMonthsResp.months; // ["2026-03","2026-02",...]
                window._allIpcaMonths = allIpcaMonths; // persist for fallback in loadInflation
                initMvMSelectors();
                // Group months by year
                const byYear = {};
                allIpcaMonths.forEach(m => {
                    const y = m.slice(0,4);
                    if (!byYear[y]) byYear[y] = [];
                    byYear[y].push(m);
                });
                Object.keys(byYear).forEach(y => byYear[y].sort());

                const currentYearStr = String(new Date().getFullYear());
                const latestYear = byYear[currentYearStr]
                    ? currentYearStr
                    : (ipcaMonthsResp.latest ? ipcaMonthsResp.latest.slice(0,4) : null);

                let monthHtml = '';
                Object.keys(byYear).sort((a,b) => a-b).forEach(yr => {
                    const isLatest = yr === latestYear;
                    monthHtml += `
                        <div style="border-bottom:1px solid #f1f3f4; margin-bottom:4px; padding-bottom:4px;">
                            <div class="flex items-center gap-1 py-1 px-2 rounded hover:bg-blue-50">
                                <label class="flex items-center gap-2 cursor-pointer flex-1 font-semibold">
                                    <input type="checkbox" class="infl-year-cb" data-year="${yr}"
                                        ${isLatest ? 'checked' : ''}
                                        onchange="toggleInflYear('${yr}', this.checked)">
                                    <span class="text-sm">${yr}</span>
                                </label>
                                <span id="infl-yr-arrow-${yr}" class="text-xs text-gray-400" style="cursor:pointer;user-select:none;padding:0 4px;" onclick="toggleInflYearCollapse('${yr}')">${isLatest ? '▼' : '▶'}</span>
                            </div>
                            <div id="infl-yr-months-${yr}" ${isLatest ? '' : 'style="display:none"'}>
                                ${byYear[yr].map(m => `
                                <label class="flex items-center gap-2 py-0.5 cursor-pointer rounded hover:bg-gray-100" style="padding-left:26px;padding-right:8px;">
                                    <input type="checkbox" class="infl-month-cb" value="${m}" data-year="${yr}"
                                        ${isLatest ? 'checked' : ''}
                                        onchange="syncInflYearCheckbox('${yr}'); updateInflMonthText(); loadInflationDebounced();">
                                    <span class="text-sm">${m}</span>
                                </label>`).join('')}
                            </div>
                        </div>`;
                });
                document.getElementById('inflMonthContainer').innerHTML = monthHtml || '<p class="text-xs text-gray-400 p-2">Sem dados</p>';
                updateInflMonthText();

            }

            // ── Filtros dinâmicos por período (categorias + despesas) ──
            {
                const _sel = Array.from(document.querySelectorAll('.infl-month-cb:checked')).map(cb => cb.value);
                const _months = _sel.length ? _sel : (window._allIpcaMonths || []);

                // Coletar categorias e tipos que existem nos meses selecionados
                const _catSet = new Set();
                let _hasIndividual = false, _hasShared = false;
                const _allMonthExp = await Promise.all(_months.map(m => fetchMonthExpenses(m).catch(() => [])));
                for (let _mi = 0; _mi < _months.length; _mi++) {
                    const m = _months[_mi];
                    const [_y, _n] = m.split('-').map(Number);
                    for (const ex of _allMonthExp[_mi]) {
                        const splitsInMonth = ex.splits.filter(s => {
                            const d = new Date(s.due_date + 'T00:00:00');
                            return d.getFullYear() === _y && d.getMonth() + 1 === _n;
                        });
                        if (!splitsInMonth.length) continue;
                        _catSet.add(ex.category_id);
                        const us = new Set(splitsInMonth.map(s => s.user_id));
                        if (us.size > 1 || (us.size === 1 && !us.has(user.id))) _hasShared = true;
                        else _hasIndividual = true;
                    }
                }

                // Categorias disponíveis no período
                const _availCats = categories.filter(c => _catSet.has(c.id));
                if (inflSelectedCatIds === null) {
                    // Primeira carga: selecionar todas
                    inflSelectedCatIds = _availCats.map(c => c.id);
                } else if (inflSelectedCatIds.length > 0) {
                    // Preservar apenas as que ainda existem no período
                    const _prevCatIds = new Set(inflSelectedCatIds);
                    const _kept = _availCats.map(c => c.id).filter(id => _prevCatIds.has(id));
                    inflSelectedCatIds = _kept.length ? _kept : _availCats.map(c => c.id);
                }
                // inflSelectedCatIds === []  manter vazio (usuário desmarcou tudo)
                const _allCatSel = inflSelectedCatIds.length >= _availCats.length;
                document.getElementById('inflCatContainer').innerHTML =
                    '<label class="flex items-center gap-2 py-1 hover:bg-blue-50 cursor-pointer px-2 rounded font-medium border-b mb-1 pb-2"><input type="checkbox" id="inflCatAll" ' + (_allCatSel ? 'checked' : '') + ' onchange="toggleAllInflCats(this.checked)"><span>📋</span><span class="text-sm">Todas</span></label>' +
                    _availCats.map(c =>
                        '<label class="flex items-center gap-2 py-1 hover:bg-gray-100 cursor-pointer px-2 rounded"><input type="checkbox" class="infl-cat-cb" value="' + c.id + '" ' + (inflSelectedCatIds.includes(c.id) ? 'checked' : '') + ' onchange="toggleInflCat(' + c.id + ')"><span>' + (c.icon || '📁') + '</span><span class="text-sm truncate">' + c.name + '</span></label>'
                    ).join('');
                updateInflCatText();

            }

            // ── Build query params from filters ──
            const d1c = document.getElementById('inflLocationFilter')?.value || '1';
            const checkedMonths = Array.from(document.querySelectorAll('.infl-month-cb:checked')).map(cb => cb.value);
const monthsToSend = checkedMonths.length > 0 ? checkedMonths : (window._allIpcaMonths || []);

            const params = new URLSearchParams({ d1c });
            if (monthsToSend.length) params.set('months', monthsToSend.join(','));
            if (inflSelectedCatIds !== null && inflSelectedCatIds.length > 0) params.set('category_ids', inflSelectedCatIds.join(','));
            if (inflSelectedCatIds !== null && inflSelectedCatIds.length === 0) { showInflMsg('myInflation',''); showInflMsg('categoryInflation',''); showInflMsg('adjustedBar',''); showInflMsg('priceVolume',''); return; }
            if (activePvPmFilter.length > 0) params.set('pm_ids', activePvPmFilter.join(','));

            try {
                const data = await api(`${API}/inflation/data?${params}`);

                if (!data.my_inflation?.length) {
                    showInflMsg('myInflation', 'Sem dados para os filtros selecionados. Associe categorias IPCA às suas categorias de gastos.');
                    showInflMsg('categoryInflation', '');
                    showInflMsg('adjustedBar', '');
                    showInflMsg('priceVolume', '');
                    return;
                }

                const labels = data.my_inflation.map(d => d.month);

                // ── Chart 1: Minha Inflação vs IPCA Índice Geral ──
                showInflMsg('myInflation', '');
                myInflationChart = upsertChart(myInflationChart, document.getElementById('myInflationChart').getContext('2d'), {
                    type: 'line',
                    data: {
                        labels,
                        datasets: [
                            {
                                label: 'Minha inflação',
                                data: data.my_inflation.map(d => d.cumulative),
                                borderColor: '#1a73e8', backgroundColor: 'rgba(26,115,232,0.12)',
                                borderWidth: 2.5, pointRadius: 4, pointBackgroundColor: '#1a73e8',
                                fill: true, tension: 0.3,
                                datalabels: {
                                    align: 'top', anchor: 'end', offset: 4,
                                    color: '#1a73e8', font: { size: 11, weight: 'bold' },
                                    formatter: v => fmtPct(v) + '%'
                                }
                            },
                            {
                                label: 'IPCA Índice Geral',
                                data: data.ipca_geral.map(d => d.cumulative),
                                borderColor: '#ea4335', backgroundColor: 'rgba(234,67,53,0.07)',
                                borderWidth: 2, pointRadius: 4, pointBackgroundColor: '#ea4335',
                                borderDash: [5, 3], fill: false, tension: 0.3,
                                datalabels: {
                                    align: 'bottom', anchor: 'start', offset: 4,
                                    color: '#ea4335', font: { size: 11, weight: 'bold' },
                                    formatter: v => fmtPct(v) + '%'
                                }
                            }
                        ]
                    },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        layout: { padding: { top: 20, bottom: 20 } },
                        interaction: { mode: 'index', intersect: false },
                        plugins: {
                            legend: { position: 'top', labels: { color: textColor, font: { size: 13 } } },
                            tooltip: {
                                enabled: false,
                                external: ctx => {
                                    if (!ctx.tooltip.dataPoints?.length) { showChartTooltip('inflTooltip', ctx.chart, ctx.tooltip, () => ''); return; }
                                    const idx = ctx.tooltip.dataPoints[0].dataIndex;
                                    const month = labels[idx] || '';
                                    const dsColors = ['#1a73e8', '#ea4335'];
                                    showChartTooltip('inflTooltip', ctx.chart, ctx.tooltip, dark => {
                                        const hr = `<div style="border-top:1px solid ${dark?'#5f6368':'#dadce0'};margin:4px 0;"></div>`;
                                        const nc = dark ? '#9aa0a6' : '#5f6368';
                                        let html = `<div style="font-weight:600;margin-bottom:4px;">${month}</div>`;
                                        ctx.tooltip.dataPoints.forEach((dp, i) => {
                                            const dsIdx = dp.datasetIndex;
                                            const dsLabel = dsIdx === 0 ? 'Minha inflação' : 'IPCA Índice Geral';
                                            const color = dsColors[dsIdx] || '#999';
                                            const monthly = dsIdx === 0 ? data.my_inflation[idx]?.rate : data.ipca_geral[idx]?.rate;
                                            html += hr;
                                            html += `<div style="display:flex;align-items:center;gap:5px;font-weight:600;margin-bottom:2px;"><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:${color};flex-shrink:0;"></span>${dsLabel}</div>`;
                                            html += `<div style="padding-left:15px;"><b>Acum.:</b> <span style="color:${nc}">${fmtPct(dp.parsed.y)}%</span> &nbsp;<b>Mês:</b> <span style="color:${nc}">${fmtPct(monthly||0)}%</span></div>`;
                                        });
                                        return html;
                                    });
                                }
                            },
                            datalabels: { display: labels.length <= 12 }
                        },
                        scales: {
                            x: { ticks: { color: textColor }, grid: { color: gridColor } },
                            y: { ticks: { color: textColor, callback: v => fmtPct(v, 1) + '%' }, grid: { color: gridColor } }
                        }
                    },
                    plugins: [window.ChartDataLabels].filter(Boolean)
                });

                // ── Chart 1b: Inflação por Categoria (usar cor do DB) ──
                if (data.category_inflation?.length) {
                    showInflMsg('categoryInflation', '');
                        const catChartIsMobile = window.innerWidth < 640;
                        // Ordenar do maior para o menor acumulado (último ponto da série)
                        const sortedCatInflation = [...data.category_inflation].sort((a, b) => {
                            const aLast = a.series.length ? a.series[a.series.length - 1].cumulative : 0;
                            const bLast = b.series.length ? b.series[b.series.length - 1].cumulative : 0;
                            return bLast - aLast;
                        });
                        categoryInflationChart = upsertChart(categoryInflationChart, document.getElementById('categoryInflationChart').getContext('2d'), {
                            type: 'line',
                            data: {
                                labels,
                                datasets: sortedCatInflation.map((cat) => {
                                    const catObj = byId(categories, cat.category_id);
                                    const color = catObj?.color || '#999999';
                                    return {
                                        label: `${cat.icon} ${cat.name}`,
                                        _icon: cat.icon,
                                        data: cat.series.map(d => d.cumulative),
                                        borderColor: color,
                                        backgroundColor: 'transparent',
                                        borderWidth: 2, pointRadius: 3,
                                        tension: 0.3,
                                        _monthlyRates: cat.series.map(d => d.rate)
                                    };
                                })
                            },
                            options: {
                                responsive: true, maintainAspectRatio: false,
                                interaction: { mode: 'index', intersect: false },
                                plugins: {
                                    legend: {
                                        position: catChartIsMobile ? 'bottom' : 'right',
                                        labels: {
                                            color: textColor,
                                            font: { size: catChartIsMobile ? 14 : 16 },
                                            boxWidth: catChartIsMobile ? 12 : 16,
                                            padding: catChartIsMobile ? 6 : 10,
                                            generateLabels: chart => chart.data.datasets.map((ds, i) => ({
                                                text: catChartIsMobile ? ds._icon || '📁' : (ds._icon || '📁'),
                                                fillStyle: ds.borderColor,
                                                strokeStyle: ds.borderColor,
                                                lineWidth: 2,
                                                hidden: !chart.isDatasetVisible(i),
                                                datasetIndex: i,
                                                fontColor: textColor
                                            }))
                                        }
                                    },
                                tooltip: {
                                    enabled: false,
                                    external: ctx => {
                                        if (!ctx.tooltip.dataPoints?.length) { showChartTooltip('catInflTooltip', ctx.chart, ctx.tooltip, () => ''); return; }
                                        const idx = ctx.tooltip.dataPoints[0].dataIndex;
                                        const month = labels[idx] || '';
                                        // Ordenar por acumulado desc para o mês hovado
                                        const sorted = ctx.tooltip.dataPoints.slice().sort((a, b) => b.parsed.y - a.parsed.y);
                                        showChartTooltip('catInflTooltip', ctx.chart, ctx.tooltip, dark => {
                                            const nc = dark ? '#9aa0a6' : '#5f6368';
                                            let html = `<div style="font-weight:600;margin-bottom:4px;">${month}</div>`;
                                            sorted.forEach(dp => {
                                                const ds = dp.dataset;
                                                const rate = ds._monthlyRates?.[dp.dataIndex] ?? 0;
                                                html += `<div style="margin:1px 0;"><b>${ds.label}</b> - Acum.: <span style="color:${nc};">${fmtPct(dp.parsed.y)}%</span> Mês: <span style="color:${nc};">${fmtPct(rate)}%</span></div>`;
                                            });
                                            return html;
                                        });
                                    }
                                },
                                datalabels: { display: false }
                            },
                            scales: {
                                x: { ticks: { color: textColor }, grid: { color: gridColor } },
                                y: { ticks: { color: textColor, callback: v => fmtPct(v, 1) + '%' }, grid: { color: gridColor } }
                            }
                        },
                        plugins: [window.ChartDataLabels].filter(Boolean)
                    });
                } else {
                    showInflMsg('categoryInflation', 'Associe categorias IPCA às suas categorias para ver este gráfico.');
                }

                // ── Chart 2: Total ajustado ──
                const adjDatasets = [{ label: 'Total', data: data.adjusted_by_month.map(d => d.adjusted || 0), backgroundColor: 'rgba(26,115,232,0.75)', borderColor: '#1a73e8', borderRadius: 0, borderSkipped: false }];
                const adjTotals = data.adjusted_by_month.map(d => d.adjusted || 0);

                showInflMsg('adjustedBar', '');
                adjustedBarChart = upsertChart(adjustedBarChart, document.getElementById('adjustedBarChart').getContext('2d'), {
                    type: 'bar',
                    data: { labels, datasets: adjDatasets },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: { callbacks: { label: ctx => { const t = adjTotals[ctx.dataIndex]||1; return `${ctx.dataset.label}: R$ ${formatBRL(ctx.parsed.y)} (${t>0?((ctx.parsed.y/t)*100).toFixed(1):0}%)`; } } },
                            datalabels: { display: false }
                        },
                        animation: { onComplete: function() {
                            const ci = this; if (!ci.data.datasets.length) return;
                            const nBars = ci.data.labels.length;
                            for (let i = 0; i < nBars; i++) {
                                let topBar = null, visTotal = 0;
                                for (let d = ci.data.datasets.length - 1; d >= 0; d--) {
                                    const meta = ci.getDatasetMeta(d);
                                    if (meta.hidden) continue;
                                    if (!topBar && meta.data[i]) topBar = meta.data[i];
                                    visTotal += ci.data.datasets[d].data[i] || 0;
                                }
                                if (!topBar || visTotal <= 0) continue;
                                ci.ctx.fillStyle = isDark ? '#e8eaed' : '#5f6368';
                                ci.ctx.font = 'bold 10px Arial'; ci.ctx.textAlign = 'center';
                                const _fmtAdj = v => window.innerWidth < 640 && v >= 1000 ? (v/1000).toFixed(1).replace('.',',')+'k' : Math.round(v).toLocaleString('pt-BR');
                                ci.ctx.fillText(_fmtAdj(visTotal), topBar.x, topBar.y - 8);
                            }
                        }},
                        scales: {
                            x: { stacked: true, ticks: { color: textColor, font: { size: 11 } }, grid: { color: gridColor, drawOnChartArea: false } },
                            y: { display: false, stacked: true, beginAtZero: true, suggestedMax: Math.max(...adjTotals, 1)*1.15 }
                        }
                    },
                    plugins: [window.ChartDataLabels].filter(Boolean)
                });

                // ── Chart 2b: Donut média por categoria (ajustado) ──
                if (data.price_volume?.length) {
                    showInflMsg('adjustedDonut', '');
                    const nMonths = labels.length;
                    // Média por categoria: (avg_prev*(n-1) + avg_last) / n
                    const allDonutData = data.price_volume
                        .map(d => ({
                            name: d.name,
                            icon: d.icon,
                            avg: nMonths > 1
                                ? (d.avg_spend_prev * (nMonths - 1) + d.avg_spend_last) / nMonths
                                : d.avg_spend_last,
                            color: byId(categories, d.category_id)?.color || '#999'
                        }))
                        .filter(d => d.avg !== 0)
                        .sort((a, b) => b.avg - a.avg);

                    // True total includes negatives
                    const donutTotal = allDonutData.reduce((s, d) => s + d.avg, 0);
                    // Only positive slices appear in the chart
                    const donutData = allDonutData.filter(d => d.avg > 0);
                    const donutNegData = allDonutData.filter(d => d.avg < 0);

                    document.getElementById('adjustedDonutAverage').textContent = `Média: R$ ${formatBRL(donutTotal)}`;
                    const donutIsMobile = window.innerWidth < 640;
                    const donutNegColor = isDark ? '#f28b82' : '#d93025';

                    adjustedDonutChart = upsertChart(adjustedDonutChart, document.getElementById('adjustedDonutChart').getContext('2d'), {
                        type: 'doughnut',
                        data: {
                            labels: donutData.map(d => d.name),
                            datasets: [{ data: donutData.map(d => d.avg), backgroundColor: donutData.map(d => d.color), borderWidth: 2, borderColor: isDark ? '#292a2d' : '#fff' }]
                        },
                        options: {
                            responsive: true, maintainAspectRatio: false,
                            cutout: '50%',
                            centerValue: donutTotal,
                            layout: { padding: { top: donutIsMobile ? 8 : 0, bottom: donutIsMobile ? 8 : 0 } },
                            plugins: {
                                legend: {
                                    position: 'right',
                                    align: 'center',
                                    labels: {
                                        color: textColor,
                                        font: { size: donutIsMobile ? 13 : 14 },
                                        boxWidth: donutIsMobile ? 12 : 14,
                                        padding: donutIsMobile ? 5 : 8,
                                        generateLabels: chart => {
                                            const posItems = chart.data.labels.map((label, i) => ({
                                                text: donutIsMobile
                                                    ? `${donutData[i].icon} ${Math.round(donutData[i].avg).toLocaleString('pt-BR')}`
                                                    : `${donutData[i].icon} R$ ${Math.round(donutData[i].avg).toLocaleString('pt-BR')}`,
                                                fillStyle: donutData[i].color,
                                                fontColor: textColor,
                                                hidden: false,
                                                datasetIndex: 0,
                                                index: i
                                            }));
                                            const negItems = donutNegData.map(d => ({
                                                text: donutIsMobile
                                                    ? `${d.icon} −${Math.abs(Math.round(d.avg)).toLocaleString('pt-BR')}`
                                                    : `${d.icon} −R$ ${Math.round(Math.abs(d.avg)).toLocaleString('pt-BR')}`,
                                                fillStyle: d.color,
                                                fontColor: donutNegColor,
                                                strokeStyle: donutNegColor,
                                                hidden: false,
                                                datasetIndex: 0,
                                                index: -1
                                            }));
                                            return [...posItems, ...negItems];
                                        }
                                    }
                                },
                                tooltip: {
                                    callbacks: {
                                        label: ctx => {
                                            const d = donutData[ctx.dataIndex];
                                            const posTotal = donutData.reduce((s, x) => s + x.avg, 0);
                                            const pct = posTotal > 0 ? ((d.avg / posTotal) * 100).toFixed(1) : '0';
                                            return `${d.icon}: R$ ${formatBRL(d.avg)} (${pct}%)`;
                                        }
                                    }
                                }
                            }
                        },
                        plugins: [{
                            id: 'donutCenterAvg',
                            afterDraw(chart) {
                                if (chart.tooltip?._active?.length) return;
                                const { ctx, chartArea: { width, height, left, top } } = chart;
                                const cx = left + width / 2, cy = top + height / 2;
                                const isDark = document.body.classList.contains('dark-mode');
                                ctx.save();
                                ctx.textAlign = 'center';
                                ctx.textBaseline = 'middle';
                                ctx.fillStyle = isDark ? '#8ab4f8' : '#1a73e8';
                                ctx.font = `bold ${Math.round(Math.min(width, height) * 0.085)}px Arial`;
                                ctx.fillText(Math.round(chart.options.centerValue ?? 0).toLocaleString('pt-BR'), cx, cy);
                                ctx.restore();
                            }
                        }]
                    });
                } else {
                    if (adjustedDonutChart) { try { adjustedDonutChart.destroy(); } catch(e) {} adjustedDonutChart = null; }
                    showInflMsg('adjustedDonut', 'Sem dados por categoria para os filtros selecionados.');
                }
                if (data.price_volume?.length && data.months?.length >= 2) {
                    const lastM = data.months[data.months.length - 1];
                    const pvData = data.price_volume.filter(d => Math.abs(d.efeito_preco + d.efeito_volume) >= 0.5);

                    if (!pvData.length) {
                        showInflMsg('priceVolume', 'Sem variação detectada entre os meses.');
                    } else {
                        showInflMsg('priceVolume', '');

                        // Calcular total geral com base real
                        const _allPv = data.price_volume;
                        const totalPreco   = _allPv.reduce((s, d) => s + d.efeito_preco, 0);
                        const totalVolume  = _allPv.reduce((s, d) => s + d.efeito_volume, 0);
                        const totalBase    = _allPv.reduce((s, d) => s + d.avg_spend_prev, 0);
                        const totalLast    = _allPv.reduce((s, d) => s + d.avg_spend_last, 0);
                        const totalPrecoPct  = totalBase > 0 ? Math.round(totalPreco  / totalBase * 1000) / 10 : 0;
                        const totalVolumePct = totalBase > 0 ? Math.round(totalVolume / totalBase * 1000) / 10 : 0;

                        // Linha de total no topo (com totais de gasto)
                        const totalRow = {
                            name: 'Total', icon: '💸',
                            efeito_preco: totalPreco, efeito_volume: totalVolume,
                            efeito_preco_pct: totalPrecoPct,
                            efeito_volume_pct: totalVolumePct,
                            avg_price_prev: null, avg_price_last: null,
                            vol_prev: null, vol_last: null,
                            avg_spend_prev: totalBase, avg_spend_last: totalLast
                        };

                        const rows = [totalRow, ...pvData.slice().sort((a, b) => Math.abs(b.efeito_preco + b.efeito_volume) - Math.abs(a.efeito_preco + a.efeito_volume))];
                        const labels = rows.map(d => `${d.icon} ${d.name}`);
                        const totals = rows.map(d => d.efeito_preco + d.efeito_volume);
                        const bgColors = totals.map(v => v >= 0 ? '#ea4335' : '#34a853');
                        const totalPcts = rows.map(d => Math.round((d.efeito_preco_pct + d.efeito_volume_pct) * 10) / 10);

                        // Eixo X simétrico — padding extra para caber label externo
                        const maxAbs = Math.max(...totals.map(Math.abs));
                        const isMobile = window.innerWidth < 640;
                        // Mobile: label é curto ("+13%") ~5 chars; Desktop: longo ("+567 (13.4%)") ~15 chars
                        // Estimativa: cada char ocupa ~7px no canvas, convertido em unidades do eixo
                        const xPad = Math.ceil(maxAbs * (isMobile ? 1.7 : 1.55));

                        // Altura dinâmica
                        const pvWrap = document.getElementById('priceVolumeWrap');
                        if (pvWrap) {
                            pvWrap.style.height = Math.max(200, rows.length * 36 + 60) + 'px';
                        }

                        priceVolumeChart = upsertChart(priceVolumeChart, document.getElementById('priceVolumeChart').getContext('2d'), {
                            type: 'bar',
                            data: {
                                labels,
                                datasets: [{
                                    label: 'Variação vs Média (R$)',
                                    data: totals,
                                    backgroundColor: bgColors,
                                    borderRadius: 4
                                }]
                            },
                            options: {
                                indexAxis: 'y',
                                responsive: true,
                                maintainAspectRatio: false,
                                layout: { padding: { right: 0, left: 0 } },
                                plugins: {
                                    legend: { display: false },
                                    tooltip: {
                                        enabled: false,
                                        external: ctx => {
                                            const d = rows[ctx.tooltip.dataPoints?.[0]?.dataIndex];
                                            if (!d) return;
                                            showChartTooltip('pvTooltip', ctx.chart, ctx.tooltip, dark => {
                                                const fmtSign = v => v >= 0 ? '+' : '-';
                                                const numColor = isDark ? '#9aa0a6' : '#5f6368';
                                                const precoCor = d.efeito_preco === 0 ? numColor : (d.efeito_preco < 0 ? '#34a853' : '#ea4335');
                                                const volumeCor = d.efeito_volume === 0 ? numColor : (d.efeito_volume < 0 ? '#34a853' : '#ea4335');
                                                const hr = `<div style="border-top:1px solid ${dark?'#5f6368':'#dadce0'};margin:5px 0;"></div>`;
                                                let html = `<div style="font-weight:600;margin-bottom:4px;">${ctx.tooltip.title?.[0] ?? ''}</div>`;
                                                html += `<div><b>Preço:</b> <span style="color:${precoCor}">${fmtSign(d.efeito_preco)}R$ ${formatBRL(Math.abs(d.efeito_preco))} (${fmtSign(d.efeito_preco)}${fmtPct(Math.abs(d.efeito_preco_pct),1)}%)</span></div>`;
                                                html += `<div><b>Volume:</b> <span style="color:${volumeCor}">${fmtSign(d.efeito_volume)}R$ ${formatBRL(Math.abs(d.efeito_volume))} (${fmtSign(d.efeito_volume)}${fmtPct(Math.abs(d.efeito_volume_pct),1)}%)</span></div>`;
                                                if (d.avg_spend_last != null) {
                                                    html += hr;
                                                    html += `<div><b>Total:</b> <span style="color:${numColor}">R$ ${formatBRL(d.avg_spend_prev)}</span> ➔ <span style="color:${numColor}">R$ ${formatBRL(d.avg_spend_last)}</span></div>`;
                                                }
                                                if (d.avg_price_last != null) {
                                                    const fmtVol = v => v == null ? '—' : (v % 1 === 0 ? String(v) : Number(v).toFixed(1).replace('.', ','));
                                                    html += `<div><b>Ticket:</b> <span style="color:${numColor}">R$ ${formatBRL(d.avg_price_prev)}</span> ➔ <span style="color:${numColor}">R$ ${formatBRL(d.avg_price_last)}</span></div>`;
                                                    html += `<div><b>Qtd:</b> <span style="color:${numColor}">${fmtVol(d.vol_prev)}</span> ➔ <span style="color:${numColor}">${fmtVol(d.vol_last)}</span></div>`;
                                                }
                                                return html;
                                            });
                                        }
                                    },
                                    datalabels: {
                                        display: true,
                                        anchor: 'end',
                                        align: 'end',
                                        offset: 2,
                                        clip: false,
                                        color: textColor,
                                        font: { size: 11, weight: '600' },
                                        formatter: (v, ctx) => {
                                            const pct = totalPcts[ctx.dataIndex] ?? 0;
                                            const sign = v >= 0 ? '+' : '-';
                                            return `${sign}${Math.round(Math.abs(v)).toLocaleString('pt-BR')} (${fmtPct(Math.abs(pct), 1)}%)`;
                                        }
                                    }
                                },
                                scales: {
                                    x: {
                                        display: false,
                                        min: -xPad,
                                        max: xPad,
                                        grid: { color: gridColor }
                                    },
                                    y: {
                                        ticks: {
                                            color: textColor,
                                            font: { size: isMobile ? 14 : 16 },
                                            callback: (val, idx) => rows[idx]?.icon ?? ''
                                        },
                                        grid: { color: gridColor }
                                    }
                                }
                            },
                            plugins: [window.ChartDataLabels].filter(Boolean)
                        });
                    }
                } else {
                    const msg = !data.months || data.months.length < 2
                        ? 'Selecione pelo menos 2 meses para ver este gráfico.'
                        : 'Sem dados para os filtros selecionados.';
                    showInflMsg('priceVolume', msg);
                }

            } catch (err) {
                console.error('Erro ao carregar inflação:', err);
            }
        }

        function initMvMSelectors() {
            // Usa meses de despesa como base; garante que o mês atual também aparece
            const expenseMonths = (window._allExpenseMonths || []).slice();
            const pad = n => String(n).padStart(2,'0');
            const now = new Date();
            const currentMonth = `${now.getFullYear()}-${pad(now.getMonth()+1)}`;
            if (!expenseMonths.includes(currentMonth)) expenseMonths.push(currentMonth);
            const months = [...new Set(expenseMonths)].sort();
            if (months.length < 2) return;
            const opts = months.map(m => `<option value="${m}">${m}</option>`).join('');
            const selA = document.getElementById('mvmMonthA');
            const selB = document.getElementById('mvmMonthB');
            if (!selA || !selB) return;
            selA.innerHTML = opts;
            selB.innerHTML = opts;
            // Default: A = último mês fechado (mês atual - 1), B = penúltimo fechado (mês atual - 2)
            const prevA = new Date(now.getFullYear(), now.getMonth() - 1, 1);
            const prevB = new Date(now.getFullYear(), now.getMonth() - 2, 1);
            const mA = `${prevA.getFullYear()}-${pad(prevA.getMonth()+1)}`;
            const mB = `${prevB.getFullYear()}-${pad(prevB.getMonth()+1)}`;
            selA.value = months.includes(mA) ? mA : months[months.length - 2] ?? months[0];
            selB.value = months.includes(mB) ? mB : months[months.length - 3] ?? months[0];
        }

        async function updateMvMChart() {
            // Suppress tooltips during chart rebuild to prevent phantom tooltip popups
            _hideCustomTooltips();
            clearTimeout(_suppressTooltipTimer);
            _suppressTooltips = true;
            _suppressTooltipTimer = setTimeout(() => { _suppressTooltips = false; }, 1500);

            const selA = document.getElementById('mvmMonthA');
            const selB = document.getElementById('mvmMonthB');
            const msgEl = document.getElementById('mvmMsg');
            const wrap = document.getElementById('mvmWrap');
            if (!selA || !selB) return;
            const monthA = selA.value;
            const monthB = selB.value;
            const showMsg = (txt) => {
                if (msgEl) { msgEl.textContent = txt; msgEl.classList.remove('hidden'); }
                if (wrap) wrap.style.display = 'none';
            };
            if (!monthA || !monthB || monthA === monthB) {
                showMsg('Selecione dois meses diferentes.');
                return;
            }
            if (msgEl) msgEl.classList.add('hidden');
            if (wrap) wrap.style.display = '';

            const isDark = document.body.classList.contains('dark-mode');
            const textColor = isDark ? '#e8eaed' : '#202124';
            const gridColor = isDark ? '#3c4043' : '#e0e0e0';
            const isMobile = window.innerWidth < 640;

            try {
                // Enviar [B, A] ordenado — B é referência (prev), A é comparação (last)
                const orderedMonths = [monthB, monthA].sort((a,b) => a.localeCompare(b));
                const params = new URLSearchParams({ d1c: '1', no_adjust: 'true', months: orderedMonths.join(',') });
                if (activeMvmPmFilter.length > 0) params.set('pm_ids', activeMvmPmFilter.join(','));
                const data = await api(`${API}/inflation/data?${params}`);


                if (!data.price_volume?.length || data.months?.length < 2) {
                    showMsg('Sem dados suficientes para os meses selecionados.');
                    return;
                }

                const pvData = data.price_volume.filter(d => Math.abs(d.efeito_preco + d.efeito_volume) >= 0.5);
                if (!pvData.length) { showMsg('Sem variação detectada entre os meses.'); return; }

                // Totais baseados em TODOS os dados — incluindo categorias sem variação (efeitos zero)
                const allPv = data.price_volume;
                const totalPreco   = allPv.reduce((s,d) => s + d.efeito_preco, 0);
                const totalVolume  = allPv.reduce((s,d) => s + d.efeito_volume, 0);
                const totalBase    = allPv.reduce((s,d) => s + d.avg_spend_prev, 0);
                const totalLast    = allPv.reduce((s,d) => s + d.avg_spend_last, 0);
                const totalPrecoPct  = totalBase > 0 ? Math.round(totalPreco  / totalBase * 1000) / 10 : 0;
                const totalVolumePct = totalBase > 0 ? Math.round(totalVolume / totalBase * 1000) / 10 : 0;

                const totalRow = {
                    name: 'Total', icon: '💸',
                    efeito_preco: totalPreco, efeito_volume: totalVolume,
                    efeito_preco_pct: totalPrecoPct, efeito_volume_pct: totalVolumePct,
                    avg_price_prev: null, avg_price_last: null,
                    vol_prev: null, vol_last: null,
                    avg_spend_prev: totalBase, avg_spend_last: totalLast
                };

                const rows = [totalRow, ...pvData.slice().sort((a,b) => Math.abs(b.efeito_preco+b.efeito_volume) - Math.abs(a.efeito_preco+a.efeito_volume))];
                const labels = rows.map(d => `${d.icon} ${d.name}`);
                const totals = rows.map(d => d.efeito_preco + d.efeito_volume);
                const bgColors = totals.map(v => v >= 0 ? '#ea4335' : '#34a853');
                const totalPcts = rows.map(d => Math.round((d.efeito_preco_pct + d.efeito_volume_pct) * 10) / 10);

                const maxAbs = Math.max(...totals.map(Math.abs));
                const xPad = Math.ceil(maxAbs * (isMobile ? 1.7 : 1.55));

                const mvmWrap = document.getElementById('mvmWrap');
                if (mvmWrap) mvmWrap.style.height = Math.max(200, rows.length * 36 + 60) + 'px';

                const fmtMonthLabel = m => m;
                mvmBarChart = upsertChart(mvmBarChart, document.getElementById('mvmChart').getContext('2d'), {
                    type: 'bar',
                    data: {
                        labels,
                        datasets: [{
                            label: `${fmtMonthLabel(monthA)} vs ${fmtMonthLabel(monthB)} (R$)`,
                            data: totals,
                            backgroundColor: bgColors,
                            borderRadius: 4
                        }]
                    },
                    options: {
                        indexAxis: 'y',
                        responsive: true,
                        maintainAspectRatio: false,
                        layout: { padding: { right: 0, left: 0 } },
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                enabled: false,
                                external: ctx => {
                                    const d = rows[ctx.tooltip.dataPoints?.[0]?.dataIndex];
                                    if (!d) return;
                                    showChartTooltip('mvmTooltip', ctx.chart, ctx.tooltip, dark => {
                                        const fmtSign = v => v >= 0 ? '+' : '-';
                                        const numColor = dark ? '#9aa0a6' : '#5f6368';
                                        const precoCor = d.efeito_preco === 0 ? numColor : (d.efeito_preco < 0 ? '#34a853' : '#ea4335');
                                        const volumeCor = d.efeito_volume === 0 ? numColor : (d.efeito_volume < 0 ? '#34a853' : '#ea4335');
                                        const hr = `<div style="border-top:1px solid ${dark?'#5f6368':'#dadce0'};margin:5px 0;"></div>`;
                                        let html = `<div style="font-weight:600;margin-bottom:4px;">${ctx.tooltip.title?.[0] ?? ''}</div>`;
                                        html += `<div style="font-size:11px;color:${numColor};margin-bottom:4px;">${fmtMonthLabel(monthB)} ➔ ${fmtMonthLabel(monthA)}</div>`;
                                        html += `<div><b>Preço:</b> <span style="color:${precoCor}">${fmtSign(d.efeito_preco)}R$ ${formatBRL(Math.abs(d.efeito_preco))} (${fmtSign(d.efeito_preco)}${fmtPct(Math.abs(d.efeito_preco_pct),1)}%)</span></div>`;
                                        html += `<div><b>Volume:</b> <span style="color:${volumeCor}">${fmtSign(d.efeito_volume)}R$ ${formatBRL(Math.abs(d.efeito_volume))} (${fmtSign(d.efeito_volume)}${fmtPct(Math.abs(d.efeito_volume_pct),1)}%)</span></div>`;
                                        if (d.avg_spend_last != null) {
                                            html += hr;
                                            html += `<div><b>Total:</b> <span style="color:${numColor}">R$ ${formatBRL(d.avg_spend_prev)}</span> ➔ <span style="color:${numColor}">R$ ${formatBRL(d.avg_spend_last)}</span></div>`;
                                        }
                                        if (d.avg_price_last != null) {
                                            const fmtVol = v => v == null ? '—' : (v % 1 === 0 ? String(v) : Number(v).toFixed(1).replace('.', ','));
                                            html += `<div><b>Ticket:</b> <span style="color:${numColor}">R$ ${formatBRL(d.avg_price_prev)}</span> ➔ <span style="color:${numColor}">R$ ${formatBRL(d.avg_price_last)}</span></div>`;
                                            html += `<div><b>Qtd:</b> <span style="color:${numColor}">${fmtVol(d.vol_prev)}</span> ➔ <span style="color:${numColor}">${fmtVol(d.vol_last)}</span></div>`;
                                        }
                                        return html;
                                    });
                                }
                            },
                            datalabels: {
                                display: true,
                                anchor: 'end',
                                align: 'end',
                                offset: 2,
                                clip: false,
                                color: textColor,
                                font: { size: 11, weight: '600' },
                                formatter: (v, ctx) => {
                                    const pct = totalPcts[ctx.dataIndex] ?? 0;
                                    const sign = v >= 0 ? '+' : '-';
                                    return `${sign}${Math.round(Math.abs(v)).toLocaleString('pt-BR')} (${fmtPct(Math.abs(pct),1)}%)`;
                                }
                            }
                        },
                        scales: {
                            x: {
                                display: false,
                                min: -xPad, max: xPad,
                                grid: { color: gridColor }
                            },
                            y: {
                                ticks: {
                                    color: textColor,
                                    font: { size: isMobile ? 14 : 16 },
                                    callback: (val, idx) => rows[idx]?.icon ?? ''
                                },
                                grid: { color: gridColor }
                            }
                        }
                    },
                    plugins: [window.ChartDataLabels].filter(Boolean)
                });
            } catch (err) {
                console.error('Erro ao carregar gráfico MvM:', err);
                showMsg('Erro ao carregar dados.');
            }
        }

        async function loadAvailableMonths() {
            try {
                const _mdata=await api(`${API}/expenses/months`);
                const months=_mdata.map(m=>m.value).reverse();
                if(!months.length)return;
                // Armazena globalmente para o seletor MvM
                window._allExpenseMonths = months.slice();
                const today=new Date();
                const currentMonth=`${today.getFullYear()}-${String(today.getMonth()+1).padStart(2,'0')}`;
                let selectedMonth=months.includes(currentMonth)?currentMonth:months[months.length-1];
                const pieSelect=document.getElementById('pieChartMonths');
                pieSelect.innerHTML=months.map(m=>`<option value="${m}" ${m===selectedMonth?'selected':''}>${m}</option>`).join('');
                const barContainer=document.getElementById('barChartMonthsContainer');
                // Group by year — years collapsed except the latest
                const barByYear = {};
                months.forEach(m => { const y=m.slice(0,4); if(!barByYear[y])barByYear[y]=[]; barByYear[y].push(m); });
                const currentYear = String(new Date().getFullYear());
                const barLatestYear = barByYear[currentYear] ? currentYear : Object.keys(barByYear).sort().pop();
                barContainer.innerHTML = Object.keys(barByYear).sort((a,b)=>b-a).map(yr => {
                    const isLatest = yr === barLatestYear;
                    const allChecked = isLatest; // só o ano vigente marcado por default
                    return `<div style="border-bottom:1px solid #f1f3f4;margin-bottom:4px;padding-bottom:4px;">
                        <div class="flex items-center gap-1 py-1 px-2 rounded hover:bg-blue-50">
                            <label class="flex items-center gap-2 cursor-pointer flex-1 font-semibold">
                                <input type="checkbox" class="bar-year-cb" data-year="${yr}" ${allChecked?'checked':''} onchange="toggleBarYear('${yr}', this.checked)">
                                <span class="text-sm">${yr}</span>
                            </label>
                            <span id="bar-yr-arrow-${yr}" class="text-xs text-gray-400" style="cursor:pointer;user-select:none;padding:0 4px;" onclick="toggleBarYearCollapse('${yr}')">${isLatest?'▼':'▶'}</span>
                        </div>
                        <div id="bar-yr-months-${yr}" ${isLatest?'':'style="display:none"'}>
                            ${barByYear[yr].map(m=>`<label class="flex items-center gap-2 py-0.5 cursor-pointer rounded hover:bg-gray-100" style="padding-left:26px;padding-right:8px;"><input type="checkbox" class="bar-chart-month" value="${m}" data-year="${yr}" ${isLatest?'checked':''} onchange="syncBarYearCheckbox('${yr}');updateBarChartFiltersDebounced();"><span class="text-sm">${m}</span></label>`).join('')}
                        </div>
                    </div>`;
                }).join('');

                // Atualizar texto inicial
                updateBarChartSelectedText();
                
                // Categorias e usuários do stacked serão populados por updateBarChartFilters()
                // com base no período selecionado — não popular aqui com dados globais.


            } catch (err) {
                console.error('Erro ao carregar meses:', err);
            }
        }

        // Atualiza filtro de usuário do donut com base nos splits do mês (usa cache)
        async function updatePieChartFilters() {
            const pieM=document.getElementById('pieChartMonths')?.value;
            if(pieM){
                const {expenses:pExps}=await fetchExpensesWithCache(pieM);
                const [pyr,pmn]=pieM.split('-').map(Number);
                let pHasShared=false;
                for(const ex of pExps){const us=new Set(ex.splits.filter(s=>{const d=new Date(s.due_date+'T00:00:00');return d.getFullYear()===pyr&&d.getMonth()+1===pmn;}).map(s=>s.user_id));if(us.size>1||(us.size===1&&!us.has(user.id))){pHasShared=true;break;}}
                const pDrop=document.getElementById('pieExpDropdown')?.querySelector('.p-2');
                if(pDrop){
                    pDrop.innerHTML=`<label class="flex items-center gap-2 py-1 hover:bg-gray-100 cursor-pointer px-2 rounded"><input type="checkbox" class="pie-exp-type" value="individual" checked onchange="updatePieExpText();updatePieChart();"> <span class="text-sm">Individuais</span></label>${pHasShared?`<label class="flex items-center gap-2 py-1 hover:bg-gray-100 cursor-pointer px-2 rounded"><input type="checkbox" class="pie-exp-type" value="compartilhada" checked onchange="updatePieExpText();updatePieChart();"> <span class="text-sm">Compartilhadas</span></label>`:''}`;updatePieExpText();
                }
            }
            await updatePieChart();
            await updateDailyChart();
        }

        // Atualiza filtros de categoria e usuário do stacked usando o cache dos meses selecionados
        async function updateBarChartFilters() {
            updateBarChartSelectedText();

            const checkboxes = document.querySelectorAll('.bar-chart-month:checked');
            const selectedMonths = Array.from(checkboxes).map(cb => cb.value);

            if (selectedMonths.length === 0) { await updatePmBarChart(); return; }

            // Construir sets de user_ids e category_ids presentes EXATAMENTE nos meses selecionados
            const userIdSet = new Set();
            const catIdSet = new Set();

            const _prefetched = await Promise.all(selectedMonths.map(m => fetchMonthExpenses(m)));
            const _expByMonth = Object.fromEntries(selectedMonths.map((m, i) => [m, _prefetched[i]]));

            for (const month of selectedMonths) {
                const [year, mon] = month.split('-').map(Number);
                for (const expense of _expByMonth[month]) {
                    for (const split of expense.splits) {
                        const d = new Date(split.due_date + 'T00:00:00');
                        if (d.getFullYear() === year && d.getMonth() + 1 === mon) {
                            userIdSet.add(split.user_id);
                            catIdSet.add(expense.category_id);
                        }
                    }
                }
            }

            // --- Atualizar checkboxes de categoria ---
            const catContainer = document.getElementById('catFilterContainer');
            if (catContainer) {
                const prevSelected = new Set(selectedCatIds);
                const availableCats = categories.filter(c => catIdSet.has(c.id));
                // Preservar selecionados que ainda existem; se nenhum, selecionar todos disponíveis
                selectedCatIds = availableCats.map(c => c.id)
                    .filter(id => prevSelected.size === 0 || prevSelected.has(id));
                if (selectedCatIds.length === 0) selectedCatIds = availableCats.map(c => c.id);

                const allSelected = selectedCatIds.length >= availableCats.length;
                catContainer.innerHTML = `
                    <label class="flex items-center gap-2 py-1 hover:bg-blue-50 cursor-pointer px-2 rounded font-medium border-b mb-1 pb-2">
                        <input type="checkbox" id="catFilterAll" ${allSelected ? 'checked' : ''}
                               onchange="toggleAllCategories(this.checked)">
                        <span>📋</span><span class="text-sm">Todas</span>
                    </label>
                ` + availableCats.map(c => `
                    <label class="flex items-center gap-2 py-1 hover:bg-gray-100 cursor-pointer px-2 rounded">
                        <input type="checkbox" class="cat-filter" value="${c.id}"
                               ${selectedCatIds.includes(c.id) ? 'checked' : ''}
                               onchange="toggleCatFilter(${c.id})">
                        <span>${c.icon || '📁'}</span>
                        <span class="text-sm truncate">${c.name}</span>
                    </label>
                `).join('');
                updateCatFilterText();
            }

            // Expense-type: popular dinamicamente com base nos tipos presentes no período
            const ufContainer=document.getElementById('userFilterContainer');
            if(ufContainer){
                let hasShared=false;
                outer: for(const month of selectedMonths){
                    const [yr,mn]=month.split('-').map(Number);
                    for(const ex of _expByMonth[month]){
                        const us=new Set(ex.splits.filter(s=>{const d=new Date(s.due_date+'T00:00:00');return d.getFullYear()===yr&&d.getMonth()+1===mn;}).map(s=>s.user_id));
                        if(us.size>1||(us.size===1&&!us.has(user.id))){hasShared=true;break outer;}
                    }
                }
                ufContainer.innerHTML=`
                    <label class="flex items-center gap-2 py-1 hover:bg-gray-100 cursor-pointer px-2 rounded"><input type="checkbox" class="expense-type-filter" value="individual" ${barExpTypeFilter.includes('individual')?'checked':''} onchange="barExpTypeFilter=Array.from(document.querySelectorAll('.expense-type-filter:checked')).map(cb=>cb.value);updateUserFilterSelectedText();updatePmBarChart();"> <span class="text-sm">Individuais</span></label>
                    ${hasShared?`<label class="flex items-center gap-2 py-1 hover:bg-gray-100 cursor-pointer px-2 rounded"><input type="checkbox" class="expense-type-filter" value="compartilhada" ${barExpTypeFilter.includes('compartilhada')?'checked':''} onchange="barExpTypeFilter=Array.from(document.querySelectorAll('.expense-type-filter:checked')).map(cb=>cb.value);updateUserFilterSelectedText();updatePmBarChart();"> <span class="text-sm">Compartilhadas</span></label>`:''}
                `;
                updateUserFilterSelectedText();
            }
            await updatePmBarChart();
        }

        async function updatePieChart() {
            const select = document.getElementById('pieChartMonths');
            const selectedMonth = select.value;
            const pieExpTypes = Array.from(document.querySelectorAll('.pie-exp-type:checked')).map(cb => cb.value);
            const pieShowIndividual = pieExpTypes.includes('individual');
            const pieShowShared = pieExpTypes.includes('compartilhada');

            if (!selectedMonth) return;

            try {
                const expensesByCategory = {};
                const { expenses } = await fetchExpensesWithCache(selectedMonth);
                const [year, mon] = selectedMonth.split('-').map(Number);

                const isSharedExp = (e) => {
                    const us = new Set(e.splits
                        .filter(s => { const d = new Date(s.due_date + 'T00:00:00'); return d.getFullYear() === year && d.getMonth() + 1 === mon; })
                        .map(s => s.user_id));
                    return us.size > 1 || (us.size === 1 && !us.has(user.id));
                };

                for (const expense of expenses) {
                    const isShared = isSharedExp(expense);
                    if (isShared && !pieShowShared) continue;
                    if (!isShared && !pieShowIndividual) continue;

                    const categoryName = expense.category_name;
                    if (!expensesByCategory[categoryName]) {
                        const cat = byId(categories, expense.category_id);
                        expensesByCategory[categoryName] = { total: 0, color: cat?.color || '#999', emoji: cat?.icon || '📁' };
                    }
                    for (const split of expense.splits) {
                        if (split.user_id !== user.id) continue;
                        const d = new Date(split.due_date + 'T00:00:00');
                        if (d.getFullYear() === year && d.getMonth() + 1 === mon) {
                            expensesByCategory[categoryName].total += parseFloat(split.user_amount);
                        }
                    }
                }

                // Preparar dados para o gráfico
                const categoryData = Object.entries(expensesByCategory).map(([name, data]) => ({
                    name, total: data.total, color: data.color, emoji: data.emoji || '📁'
                })).filter(d => d.total !== 0);

                categoryData.sort((a, b) => b.total - a.total);
                
                // True total includes negatives (credits/reversals affect overall balance)
                const total = categoryData.reduce((sum, val) => sum + val.total, 0);
                // Only positive-value categories become slices in the donut
                const positiveData = categoryData.filter(d => d.total > 0);

                const labels = positiveData.map(c => c.name);
                const data = positiveData.map(c => c.total);
                const colors = positiveData.map(c => c.color);

                // Atualizar label de total
                document.getElementById('pieChartTotal').textContent = `Total: R$ ${formatBRL(total)}`;

                const ctx = document.getElementById('categoryPieChart').getContext('2d');
                const isDark = document.body.classList.contains('dark-mode');
                const textColor = isDark ? '#e8eaed' : '#202124';

                const negativeData = categoryData.filter(d => d.total < 0);
                const negColor = isDark ? '#f28b82' : '#d93025';
                const pieIsMobile = window.innerWidth < 640;
                categoryPieChart = upsertChart(categoryPieChart, ctx, {
                    type: 'doughnut',
                    data: {
                        labels: labels,
                        datasets: [{
                            data: data,
                            backgroundColor: colors,
                            borderWidth: 2,
                            borderColor: isDark ? '#292a2d' : '#fff'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '50%',
                        centerValue: total,
                        layout: { padding: { right: pieIsMobile ? 0 : 4, top: pieIsMobile ? 8 : 0, bottom: pieIsMobile ? 8 : 0 } },
                        plugins: {
                            legend: {
                                position: 'right',
                                align: 'center',
                                labels: {
                                    color: textColor,
                                    font: { size: pieIsMobile ? 13 : 14 },
                                    boxWidth: pieIsMobile ? 12 : 14,
                                    padding: pieIsMobile ? 5 : 8,
                                    generateLabels: function(chart) {
                                        const posItems = chart.data.labels.map((label, i) => {
                                            const value = chart.data.datasets[0].data[i];
                                            const emoji = positiveData[i]?.emoji || '📁';
                                            return {
                                                text: pieIsMobile
                                                    ? `${emoji} ${Math.round(value).toLocaleString('pt-BR')}`
                                                    : `${emoji} R$ ${formatBRL(value)}`,
                                                fillStyle: chart.data.datasets[0].backgroundColor[i],
                                                fontColor: textColor,
                                                hidden: false,
                                                datasetIndex: 0,
                                                index: i
                                            };
                                        });
                                        const negItems = negativeData.map(d => ({
                                            text: pieIsMobile
                                                ? `${d.emoji} −${Math.abs(Math.round(d.total)).toLocaleString('pt-BR')}`
                                                : `${d.emoji} −R$ ${formatBRL(Math.abs(d.total))}`,
                                            fillStyle: d.color,
                                            fontColor: negColor,
                                            strokeStyle: negColor,
                                            hidden: false,
                                            datasetIndex: 0,
                                            index: -1
                                        }));
                                        return [...posItems, ...negItems];
                                    }
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        const value = context.parsed;
                                        const posTotal = positiveData.reduce((s, d) => s + d.total, 0);
                                        const percentage = posTotal > 0 ? ((value / posTotal) * 100).toFixed(1) : '0';
                                        const emoji = positiveData[context.dataIndex]?.emoji || '📁';
                                        return `${emoji}: R$ ${formatBRL(value)} (${percentage}%)`;
                                    }
                                }
                            }
                        }
                    },
                    plugins: [{
                        id: 'pieCenterTotal',
                        afterDraw(chart) {
                            if (chart.tooltip?._active?.length) return;
                            const { ctx, chartArea: { width, height, left, top } } = chart;
                            const cx = left + width / 2, cy = top + height / 2;
                            const isDark = document.body.classList.contains('dark-mode');
                            ctx.save();
                            ctx.textAlign = 'center';
                            ctx.textBaseline = 'middle';
                            ctx.fillStyle = isDark ? '#8ab4f8' : '#1a73e8';
                            ctx.font = `bold ${Math.round(Math.min(width, height) * 0.085)}px Arial`;
                            ctx.fillText(formatBRL(chart.options.centerValue ?? 0), cx, cy);
                            ctx.restore();
                        }
                    }]
                });
                await updateDailyChart();
            } catch (err) {
                console.error('Erro ao atualizar gráfico de pizza:', err);
                alert('Erro ao carregar dados do gráfico');
            }
        }

        async function updateDailyChart() {
            const selectedMonth = document.getElementById('pieChartMonths')?.value;
            if (!selectedMonth) return;
            const [year, mon] = selectedMonth.split('-').map(Number);
            const daysInMonth = new Date(year, mon, 0).getDate();
            const days = Array.from({length: daysInMonth}, (_, i) => i + 1);
            const pieExpTypes = Array.from(document.querySelectorAll('.pie-exp-type:checked')).map(cb => cb.value);
            const showIndividual = pieExpTypes.includes('individual');
            const showShared = pieExpTypes.includes('compartilhada');
            try {
                // Busca mês atual + mês seguinte para capturar despesas com original_date
                // no mês atual mas due_date no próximo (fechamento de cartão)
                const nextMon = mon === 12 ? `${year + 1}-01` : `${year}-${String(mon + 1).padStart(2, '0')}`;
                const [{ expenses: curExp }, { expenses: nextExp }] = await Promise.all([
                    fetchExpensesWithCache(selectedMonth),
                    fetchExpensesWithCache(nextMon)
                ]);
                // Combina e deduplica por id; registra quais estão no mês atual (curExp)
                const curExpIds = new Set(curExp.map(e => e.id));
                const seenIds = new Set();
                const expenses = [...curExp, ...nextExp].filter(e => {
                    if (seenIds.has(e.id)) return false;
                    seenIds.add(e.id);
                    return true;
                });
                // PMs com despesas neste mês (original_date) — para filtrar os botões exibidos
                const _pmSetDiary = new Set();
                for (const e of expenses) {
                    if (e.payment_method_id == null) continue;
                    const origStr = e.original_date || e.expense_date;
                    if (!origStr) continue;
                    const d = new Date(origStr + 'T00:00:00');
                    if (d.getFullYear() === year && d.getMonth() + 1 === mon) _pmSetDiary.add(e.payment_method_id);
                }
                window._pmIdsDiary = _pmSetDiary.size > 0 ? _pmSetDiary : null;
                // Remove filtros ativos de PMs que não existem neste mês
                if (window._pmIdsDiary) activeDailyPmFilter = activeDailyPmFilter.filter(id => window._pmIdsDiary.has(id));
                renderPmFilterButtons();

                // Popular filtro de categorias com as disponíveis no mês
                const dailyCatContainer = document.getElementById('dailyCatFilterContainer');
                if (dailyCatContainer) {
                    const catIdsInMonth = new Set(expenses
                        .filter(e => { const o=e.original_date||e.expense_date; if(!o) return false; const d=new Date(o+'T00:00:00'); return d.getFullYear()===year&&d.getMonth()+1===mon; })
                        .map(e => e.category_id));
                    const availableCats = categories.filter(c => catIdsInMonth.has(c.id));
                    const monthChanged = selectedMonth !== dailyCatMonth;
                    dailyCatMonth = selectedMonth;
                    if (availableCats.length === 0) {
                        selectedDailyCatIds = null;
                    } else if (monthChanged || selectedDailyCatIds === null) {
                        // Mês trocou ou primeira carga: aplicar categorias e PM do target (ou todas/nenhum)
                        const tSelEl = document.getElementById('dailyTargetSelect');
                        const tId = dailyTargetInitialized ? parseInt(tSelEl?.value) : ((targets||[]).filter(t=>t.display_mode==='daily'&&t.is_active!==false)[0]?.id);
                        const tgt = tId ? (targets||[]).find(t=>t.id===tId) : null;
                        // Categorias: normalizar para Number para comparação segura
                        const tgtCats = tgt?.category_ids?.length ? tgt.category_ids.map(Number) : null;
                        if (tgtCats) {
                            selectedDailyCatIds = availableCats.map(c=>c.id).filter(id=>tgtCats.includes(id));
                            if (selectedDailyCatIds.length === 0) selectedDailyCatIds = availableCats.map(c=>c.id);
                        } else {
                            selectedDailyCatIds = availableCats.map(c=>c.id);
                        }
                        // Métodos de pagamento: resetar para os do target
                        activeDailyPmFilter = tgt?.payment_methods?.length ? [...tgt.payment_methods] : [];
                        applyDailyPmFilterStyles();
                    }
                    // [] = usuário desmarcou tudo dentro do mesmo mês ➔ manter vazio
                    const allSel = availableCats.length > 0 && (selectedDailyCatIds === null || selectedDailyCatIds.length >= availableCats.length);
                    dailyCatContainer.innerHTML = `
                        <label class="flex items-center gap-2 py-1 hover:bg-blue-50 cursor-pointer px-2 rounded font-medium border-b mb-1 pb-2">
                            <input type="checkbox" id="dailyCatFilterAll" ${allSel?'checked':''} onchange="toggleAllDailyCategories(this.checked)">
                            <span>📋</span><span class="text-sm">Todas</span>
                        </label>
                    ` + availableCats.map(c=>`
                        <label class="flex items-center gap-2 py-1 hover:bg-gray-100 cursor-pointer px-2 rounded">
                            <input type="checkbox" class="daily-cat-filter" value="${c.id}" ${selectedDailyCatIds.includes(c.id)?'checked':''} onchange="toggleDailyCatFilter(${c.id})">
                            <span>${c.icon||'📁'}</span><span class="text-sm truncate">${c.name}</span>
                        </label>
                    `).join('');
                    updateDailyCatFilterText();
                }

                // dailyData[d] = { total, cats: { name: {total, color, emoji} } }
                const dailyData = {};
                for (let d = 1; d <= daysInMonth; d++) dailyData[d] = { total: 0, cats: {} };
                for (const expense of expenses) {
                    // Filtra pelo original_date no mês selecionado (independente do due_date do split)
                    const origStr = expense.original_date || expense.expense_date;
                    if (!origStr) continue;
                    const origDate = new Date(origStr + 'T00:00:00');
                    if (origDate.getFullYear() !== year || origDate.getMonth() + 1 !== mon) continue;
                    // Shared/individual baseado em todos os splits da despesa
                    const allUids = new Set(expense.splits.map(s => s.user_id));
                    const isShared = allUids.size > 1 || (allUids.size === 1 && !allUids.has(user.id));
                    if (isShared && !showShared) continue;
                    if (!isShared && !showIndividual) continue;
                    // Filtro de forma de pagamento
                    if (activeDailyPmFilter.length > 0 && !activeDailyPmFilter.includes(expense.payment_method_id)) continue;
                    // Filtro de categorias
                    if (selectedDailyCatIds !== null && !selectedDailyCatIds.includes(expense.category_id)) continue;
                    const day = origDate.getDate();
                    const cat = byId(categories, expense.category_id);
                    const catName = expense.category_name;
                    const emoji = cat?.icon || '📁';
                    const color = cat?.color || '#999';
                    // Só conta splits com due_date no mês atual (exclui despesas que caem no próximo mês)
                    for (const split of expense.splits) {
                        if (split.user_id !== user.id) continue;
                        const splitDue = new Date(split.due_date + 'T00:00:00');
                        if (splitDue.getFullYear() !== year || splitDue.getMonth() + 1 !== mon) continue;
                        const amt = parseFloat(split.user_amount);
                        if (amt === 0) continue;
                        dailyData[day].total += amt;
                        if (!dailyData[day].cats[catName]) dailyData[day].cats[catName] = { total: 0, color, emoji };
                        dailyData[day].cats[catName].total += amt;
                    }
                }
                const totals = days.map(d => dailyData[d].total);

                // Bolinhas vazadas: despesas com original_date neste mês mas due_date no próximo
                const nextMonthDayTotals = {};
                for (let d = 1; d <= daysInMonth; d++) nextMonthDayTotals[d] = 0;
                for (const expense of expenses) {
                    const origStr2 = expense.original_date || expense.expense_date;
                    if (!origStr2) continue;
                    const origDate2 = new Date(origStr2 + 'T00:00:00');
                    if (origDate2.getFullYear() !== year || origDate2.getMonth() + 1 !== mon) continue;
                    const allUids2 = new Set(expense.splits.map(s => s.user_id));
                    const isShared2 = allUids2.size > 1 || (allUids2.size === 1 && !allUids2.has(user.id));
                    if (isShared2 && !showShared) continue;
                    if (!isShared2 && !showIndividual) continue;
                    if (activeDailyPmFilter.length > 0 && !activeDailyPmFilter.includes(expense.payment_method_id)) continue;
                    if (selectedDailyCatIds !== null && !selectedDailyCatIds.includes(expense.category_id)) continue;
                    const day2 = origDate2.getDate();
                    for (const split of expense.splits) {
                        if (split.user_id !== user.id) continue;
                        const splitDue2 = new Date(split.due_date + 'T00:00:00');
                        if (splitDue2.getFullYear() === year && splitDue2.getMonth() + 1 === mon) continue;
                        const amt2 = parseFloat(split.user_amount);
                        if (amt2 === 0) continue;
                        nextMonthDayTotals[day2] += amt2;
                    }
                }
                const nextMonthTotals = days.map(d => nextMonthDayTotals[d] > 0 ? nextMonthDayTotals[d] : null);

                // Totais por due_date para cálculo de orçamento (igual ao valor de fechamento da aba Início)
                const dueDateDayTotals = {};
                for (let d = 1; d <= daysInMonth; d++) dueDateDayTotals[d] = 0;
                for (const expense of curExp) {
                    for (const split of expense.splits) {
                        if (split.user_id !== user.id) continue;
                        const dd = new Date(split.due_date + 'T00:00:00');
                        if (dd.getFullYear() !== year || dd.getMonth() + 1 !== mon) continue;
                        dueDateDayTotals[dd.getDate()] += parseFloat(split.user_amount);
                    }
                }
                const dueDateTotals = days.map(d => dueDateDayTotals[d]);

                const isDark = document.body.classList.contains('dark-mode');
                const textColor = isDark ? '#e8eaed' : '#202124';
                const gridColor = isDark ? '#3c4043' : '#e0e0e0';

                // Popular seletor de targets R$/dia; auto-seleciona o primeiro se ainda não há seleção
                const targetSel = document.getElementById('dailyTargetSelect');
                if (targetSel) {
                    const allTargets = (targets || []);
                    const currentVal = targetSel.value;
                    // Auto-selecionar o primeiro target elegível apenas na primeira carga
                    const defaultVal = dailyTargetInitialized ? currentVal : (allTargets.length ? String(allTargets[0].id) : '');
                    targetSel.innerHTML = '<option value="">Sem meta</option>' +
                        allTargets.map(t => `<option value="${t.id}" ${String(t.id)===defaultVal?'selected':''}>${t.emoji} ${t.name}</option>`).join('');
                    if (!dailyTargetInitialized) {
                        if (defaultVal) {
                            const autoTgt=(targets||[]).find(t=>String(t.id)===defaultVal);
                            if(autoTgt&&autoTgt.payment_methods&&autoTgt.payment_methods.length>0){
                                activeDailyPmFilter=[...autoTgt.payment_methods];
                                applyDailyPmFilterStyles();
                            }
                        }
                        dailyTargetInitialized=true;
                    }
                }

                // Target selecionado ➔ linha tracejada (adaptativa ou fixa)
                const selTargetId = targetSel ? parseInt(targetSel.value) : NaN;
                const selTarget = !isNaN(selTargetId) && selTargetId ? (targets||[]).find(t=>t.id===selTargetId) : null;
                const fixedDailyLimit = selTarget ? selTarget.monthly_amount / daysInMonth : null;

                const _nowD = new Date();
                const _isCurMonD = _nowD.getFullYear() === year && _nowD.getMonth() + 1 === mon;
                const _isPastMonD = year < _nowD.getFullYear() || (year === _nowD.getFullYear() && mon < _nowD.getMonth() + 1);
                const todayDay = _isCurMonD ? _nowD.getDate() : (_isPastMonD ? daysInMonth : 0);

                let tgtDisplayTotals = null;
                let targetLineData = null;
                let targetRawData = [];
                let labelLimit = fixedDailyLimit; // valor exibido no label do gráfico
                if (selTarget) {
                    const now = _nowD;
                    const isCurrentMonth = _isCurMonD;
                    const isPastMonth = _isPastMonD;

                    const tgtCatIds = selTarget.category_ids?.length ? new Set(selTarget.category_ids.map(Number)) : null;
                    const tgtPmIds = selTarget.payment_methods?.length ? new Set(selTarget.payment_methods) : null;

                    // Linha azul filtrada pelo target (original_date, inclui negativos/refunds)
                    const tgtDisplayDayTotals = {};
                    for (let d = 1; d <= daysInMonth; d++) tgtDisplayDayTotals[d] = 0;
                    for (const expense of expenses) {
                        if (tgtCatIds && !tgtCatIds.has(Number(expense.category_id))) continue;
                        if (tgtPmIds && !tgtPmIds.has(expense.payment_method_id)) continue;
                        const origStr = expense.original_date || expense.expense_date;
                        if (!origStr) continue;
                        const origDate = new Date(origStr + 'T00:00:00');
                        if (origDate.getFullYear() !== year || origDate.getMonth() + 1 !== mon) continue;
                        const day = origDate.getDate();
                        for (const split of expense.splits) {
                            if (split.user_id !== user.id) continue;
                            const splitDue = new Date(split.due_date + 'T00:00:00');
                            if (splitDue.getFullYear() !== year || splitDue.getMonth() + 1 !== mon) continue;
                            tgtDisplayDayTotals[day] += parseFloat(split.user_amount);
                        }
                    }
                    tgtDisplayTotals = days.map(d => tgtDisplayDayTotals[d]);

                    // Teto: separar parcelas (outros meses, due_date neste mês) de gastos (este mês)
                    let parcelas = 0;
                    const gastosDueDayTotals = {};
                    for (let d = 1; d <= daysInMonth; d++) gastosDueDayTotals[d] = 0;
                    for (const expense of curExp) {
                        if (tgtCatIds && !tgtCatIds.has(Number(expense.category_id))) continue;
                        if (tgtPmIds && !tgtPmIds.has(expense.payment_method_id)) continue;
                        const origStr = expense.original_date || expense.expense_date;
                        if (!origStr) continue;
                        const origDate = new Date(origStr + 'T00:00:00');
                        const isCurrentMonthExp = origDate.getFullYear() === year && origDate.getMonth() + 1 === mon;
                        for (const split of expense.splits) {
                            if (split.user_id !== user.id) continue;
                            const dd = new Date(split.due_date + 'T00:00:00');
                            if (dd.getFullYear() !== year || dd.getMonth() + 1 !== mon) continue;
                            const amt = parseFloat(split.user_amount);
                            if (isCurrentMonthExp) {
                                gastosDueDayTotals[dd.getDate()] += amt; // gasto do mês
                            } else {
                                parcelas += amt; // pré-comprometido de outro mês
                            }
                        }
                    }
                    const gastosDayArray = days.map(d => gastosDueDayTotals[d]);
                    const saldoInicial = selTarget.monthly_amount - parcelas;

                    // gastos para o algoritmo (inclui negativos = refunds aumentam o teto)
                    const gastos = days.map((d, idx) => {
                        const s = gastosDayArray[idx];
                        if (s !== 0) return s;
                        if (d <= todayDay) return 0;
                        return null;
                    });
                    let runningAcumulado = 0;
                    let saldoHoje = saldoInicial;
                    const denominadorFuturo = todayDay > 0 ? daysInMonth - todayDay + 1 : daysInMonth;
                    let futureCumulative = 0;
                    targetRawData = []; // saldo acumulado por dia — negativo = quanto estourou no total
                    targetLineData = gastos.map((gasto, i) => {
                        const d = days[i];
                        let raw;
                        if (d > todayDay) {
                            futureCumulative += gasto ?? 0;
                            raw = (saldoHoje - futureCumulative) / denominadorFuturo;
                            // Para dias futuros: saldo projetado total (não por dia)
                            targetRawData.push(saldoHoje - futureCumulative);
                        } else {
                            runningAcumulado += gasto ?? 0;
                            const dias_restantes = daysInMonth - i;
                            raw = dias_restantes > 0 ? (saldoInicial - runningAcumulado) / dias_restantes : 0;
                            if (d === todayDay) saldoHoje = saldoInicial - runningAcumulado;
                            // Para dias passados: saldo acumulado total (negativo = estouro total até esse dia)
                            targetRawData.push(saldoInicial - runningAcumulado);
                        }
                        return Math.max(raw, 0);
                    });
                    // labelLimit: saldoInicial menos todos os gastos do mês
                    const sumAllGastos = gastosDayArray.reduce((s, v) => s + v, 0);
                    const daysLeft = daysInMonth - todayDay + 1;
                    labelLimit = daysLeft > 0 ? Math.max((saldoInicial - sumAllGastos) / daysLeft, 0) : 0;
                }

                // Quando há target selecionado, usar totais filtrados pelo target para a linha azul
                const activeTotals = tgtDisplayTotals ?? totals;

                // ── MODO ACUMULADO ────────────────────────────────────────────────────────────
                if (dailyChartMode === 'acum') {
                    // Mesma lógica do Dia: parcelas pré-comprometidas no dia 1, gastos do mês por due_date
                    const _aCatIds = selTarget?.category_ids?.length ? new Set(selTarget.category_ids.map(Number)) : null;
                    const _aPmIds  = selTarget?.payment_methods?.length ? new Set(selTarget.payment_methods) : null;
                    let _parcelas = 0;
                    const _gastosDia = {};
                    const _catDia = {};         // d -> { catName -> { total, emoji } }
                    const _catParcelas = {};    // catName -> { total, emoji }
                    for (let d = 1; d <= daysInMonth; d++) { _gastosDia[d] = 0; _catDia[d] = {}; }
                    for (const expense of curExp) {
                        if (_aCatIds && !_aCatIds.has(Number(expense.category_id))) continue;
                        if (_aPmIds  && !_aPmIds.has(expense.payment_method_id)) continue;
                        const origStr = expense.original_date || expense.expense_date;
                        if (!origStr) continue;
                        const origDate = new Date(origStr + 'T00:00:00');
                        const isCurMonExp = origDate.getFullYear() === year && origDate.getMonth() + 1 === mon;
                        const cat = byId(categories, expense.category_id);
                        const catName = cat?.name || 'Outros';
                        const catEmoji = cat?.icon || '📁';
                        for (const split of expense.splits) {
                            if (split.user_id !== user.id) continue;
                            const dd = new Date(split.due_date + 'T00:00:00');
                            if (dd.getFullYear() !== year || dd.getMonth() + 1 !== mon) continue;
                            const amt = parseFloat(split.user_amount);
                            if (isCurMonExp) {
                                _gastosDia[dd.getDate()] += amt;
                                const dc = _catDia[dd.getDate()];
                                if (!dc[catName]) dc[catName] = { total: 0, emoji: catEmoji };
                                dc[catName].total += amt;
                            } else {
                                _parcelas += amt;
                                if (!_catParcelas[catName]) _catParcelas[catName] = { total: 0, emoji: catEmoji };
                                _catParcelas[catName].total += amt;
                            }
                        }
                    }
                    // Linha acumulada: todos os dias (futuro tracejado)
                    let runningSum = 0;
                    const accumTotals = days.map(d => {
                        runningSum += _gastosDia[d] ?? 0;
                        return _parcelas + runningSum;
                    });
                    const monthlyTarget = selTarget?.monthly_amount ?? null;
                    const targetHorizData = monthlyTarget != null ? days.map(() => monthlyTarget) : null;

                    const allVals = [...accumTotals, ...(targetHorizData || [])];
                    const yMax = allVals.length ? Math.ceil(Math.max(...allVals) * 1.08 / 10) * 10 : 100;

                    const accumColor = v => monthlyTarget != null && v > monthlyTarget ? '#ef4444' : '#1a73e8';
                    const accumDs = [{
                        data: accumTotals,
                        borderWidth: 2,
                        borderColor: '#1a73e8',
                        backgroundColor: 'transparent',
                        fill: false,
                        cubicInterpolationMode: 'monotone',
                        // Bolinhas só até hoje; dias futuros sem ponto (linha tracejada fala por si)
                        pointRadius: accumTotals.map((_, i) => days[i] <= todayDay ? 2.5 : 0),
                        pointHoverRadius: 4,
                        pointBackgroundColor: accumTotals.map((v, i) => days[i] <= todayDay ? accumColor(v) : 'transparent'),
                        pointBorderColor: accumTotals.map(v => accumColor(v)),
                        spanGaps: true,
                        segment: {
                            // Tracejado para dias futuros
                            borderDash: ctx => ctx.p1DataIndex >= todayDay ? [5, 4] : undefined,
                            // Vermelho só quando ambos os extremos estão acima do target
                            borderColor: monthlyTarget != null
                                ? ctx => (ctx.p0.parsed.y > monthlyTarget && ctx.p1.parsed.y > monthlyTarget) ? '#ef4444' : '#1a73e8'
                                : undefined,
                        },
                    }];
                    if (targetHorizData) {
                        accumDs.push({
                            data: targetHorizData,
                            borderColor: '#f59e0b',
                            borderWidth: 2,
                            borderDash: [6, 4],
                            pointRadius: 0,
                            pointHoverRadius: 0,
                            fill: false,
                            tension: 0,
                            spanGaps: true,
                        });
                    }

                    const ctxA = document.getElementById('dailyLineChart').getContext('2d');
                    dailyLineChart = upsertChart(dailyLineChart, ctxA, {
                        type: 'line',
                        data: { labels: days.map(String), datasets: accumDs },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            layout: { padding: { top: 18, bottom: 12 } },
                            interaction: { mode: 'index', intersect: false },
                            plugins: {
                                legend: { display: false },
                                tooltip: {
                                    filter: item => item.raw != null,
                                    callbacks: {
                                        title: items => `Dia ${items[0].label}`,
                                        label: () => null,
                                        afterBody: items => {
                                            const sp = items.find(i => i.datasetIndex === 0);
                                            if (!sp || sp.raw == null) return [];
                                            const over = monthlyTarget != null && sp.raw > monthlyTarget;
                                            const lines = [];
                                            lines.push(`${over ? '🔴' : '🔵'} Acumulado: R$ ${formatBRL(sp.raw)}`);
                                            if (monthlyTarget != null) {
                                                const diff = monthlyTarget - sp.raw;
                                                lines.push(diff >= 0 ? `✅ Folga: R$ ${formatBRL(diff)}` : `⚠️ Estouro: R$ ${formatBRL(-diff)}`);
                                            }
                                            // Breakdown por categoria acumulado até este dia
                                            const upToDay = days[sp.dataIndex];
                                            const catAccum = {};
                                            for (const [n, c] of Object.entries(_catParcelas)) {
                                                catAccum[n] = { total: c.total, emoji: c.emoji };
                                            }
                                            for (let d = 1; d <= upToDay; d++) {
                                                for (const [n, c] of Object.entries(_catDia[d] || {})) {
                                                    if (!catAccum[n]) catAccum[n] = { total: 0, emoji: c.emoji };
                                                    catAccum[n].total += c.total;
                                                }
                                            }
                                            const sorted = Object.entries(catAccum).sort((a, b) => b[1].total - a[1].total);
                                            const MAX_CATS = 7;
                                            if (sorted.length > 0) lines.push('──────────────');
                                            lines.push(...sorted.slice(0, MAX_CATS).map(([name, c]) => `${c.emoji} ${name}: R$ ${formatBRL(c.total)}`));
                                            if (sorted.length > MAX_CATS) lines.push(`… e mais ${sorted.length - MAX_CATS} categorias`);
                                            return lines;
                                        }
                                    }
                                }
                            },
                            scales: {
                                x: {
                                    grid: { color: gridColor, drawTicks: false },
                                    ticks: {
                                        color: textColor, font: { size: 11 }, maxRotation: 0,
                                        callback: (val, idx) => window.innerWidth < 640 && (idx + 1) % 2 === 0 ? '' : String(idx + 1)
                                    }
                                },
                                y: {
                                    min: 0,
                                    max: yMax,
                                    grid: { color: gridColor },
                                    ticks: {
                                        color: textColor, font: { size: 11 },
                                        callback: v => v === 0 ? '' : Math.round(v).toLocaleString('pt-BR')
                                    }
                                }
                            }
                        },
                        plugins: [weekBandsPlugin, budgetCoeffPlugin]
                    });
                    return;
                }
                // ── FIM MODO ACUMULADO ────────────────────────────────────────────────────────

                // Coeficiente de desvio líquido: C = (área_verde − área_vermelha) / área_target
                // Positivo = abaixo do target (criando folga), negativo = acima (estourando)
                let budgetCoeff = null;
                if (targetLineData !== null) {
                    const _now = new Date();
                    const _isCurMon = _now.getFullYear() === year && _now.getMonth() + 1 === mon;
                    const _isPastMon = year < _now.getFullYear() || (year === _now.getFullYear() && mon < _now.getMonth() + 1);
                    const _coeffToday = _isCurMon ? _now.getDate() : (_isPastMon ? daysInMonth : 0);
                    let _verde = 0, _vermelho = 0, _tgt = 0;
                    for (let i = 0; i < days.length; i++) {
                        if (days[i] > _coeffToday) break;
                        const sp = activeTotals[i] ?? 0;
                        const tg = targetLineData[i] ?? 0;
                        _verde += Math.max(0, tg - sp);
                        _vermelho += Math.max(0, sp - tg);
                        _tgt += tg;
                    }
                    if (_tgt > 0) budgetCoeff = (_verde - _vermelho) / _tgt;
                }

                // Determina min do eixo Y
                const _allChartVals = [...activeTotals, ...(targetLineData || []), ...nextMonthTotals.filter(v => v != null)].filter(v => v != null && isFinite(v));
                const _dataMin = _allChartVals.length ? Math.min(..._allChartVals) : 0;
                const yAxisMin = _dataMin >= 0 ? 0 : Math.floor(_dataMin / 10) * 10;

                // Índice do dataset de bolinhas do próximo mês (após azul + eventual target)
                const nextMonthDsIdx = targetLineData !== null ? 2 : 1;
                const nmColor = isDark ? '#90caf9' : '#64b5f6';

                const datasets = [{
                    data: activeTotals,
                    borderColor: '#1a73e8',
                    backgroundColor: isDark ? 'rgba(26,115,232,0.15)' : 'rgba(26,115,232,0.08)',
                    fill: targetLineData !== null ? {
                        target: 1,
                        above: isDark ? 'rgba(239,68,68,0.25)' : 'rgba(239,68,68,0.18)',
                        below: isDark ? 'rgba(34,197,94,0.25)' : 'rgba(34,197,94,0.18)'
                    } : true,
                    cubicInterpolationMode: 'monotone',
                    borderWidth: 2,
                    pointRadius: activeTotals.map(v => v !== 0 ? 2.5 : 0),
                    pointHoverRadius: activeTotals.map(v => v !== 0 ? 4 : 4),
                    pointHoverBackgroundColor: activeTotals.map(v => v !== 0 ? '#1a73e8' : 'transparent'),
                    pointHoverBorderColor: '#1a73e8',
                    pointHoverBorderWidth: 1.5,
                    pointBackgroundColor: '#1a73e8',
                    pointBorderColor: '#1a73e8',
                    spanGaps: true
                }];
                if (targetLineData !== null) {
                    const tetoColors = targetLineData.map(v => v <= 0 ? '#ef4444' : '#f59e0b');
                    datasets.push({
                        data: targetLineData,
                        borderColor: '#f59e0b',
                        borderWidth: 2,
                        borderDash: [6, 4],
                        pointRadius: 0,
                        pointHoverRadius: 4,
                        pointHoverBackgroundColor: 'transparent',
                        pointHoverBorderWidth: 1,
                        pointBackgroundColor: 'transparent',
                        pointBorderColor: tetoColors,
                        fill: false,
                        tension: 0,
                        spanGaps: true,
                        segment: {
                            borderColor: ctx => targetLineData[ctx.p0DataIndex] <= 0 ? '#ef4444' : '#f59e0b'
                        }
                    });
                }
                // Bolinhas vazadas (➡️ próximo mês)
                datasets.push({
                    data: nextMonthTotals,
                    showLine: false,
                    pointRadius: nextMonthTotals.map(v => v != null ? 2.5 : 0),
                    pointHoverRadius: nextMonthTotals.map(v => v != null ? 4 : 0),
                    pointBackgroundColor: 'transparent',
                    pointBorderColor: nmColor,
                    pointBorderWidth: 2,
                    pointHoverBackgroundColor: 'transparent',
                    pointHoverBorderColor: nmColor,
                    pointHoverBorderWidth: 2,
                    fill: false,
                    spanGaps: false
                });

                const ctx = document.getElementById('dailyLineChart').getContext('2d');
                dailyLineChart = upsertChart(dailyLineChart, ctx, {
                    type: 'line',
                    data: {
                        labels: days.map(String),
                        datasets
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        budgetCoeff: budgetCoeff,
                        layout: { padding: { top: 18, bottom: 12 } },
                        interaction: { mode: 'index', intersect: false },
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                filter: item => {
                                    if (item.datasetIndex === 0) return item.raw !== 0;
                                    if (targetLineData && item.datasetIndex === 1) return true;
                                    if (item.datasetIndex === nextMonthDsIdx) return item.raw != null;
                                    return false;
                                },
                                callbacks: {
                                    title: items => `Dia ${items[0].label}`,
                                    label: () => null,
                                    beforeBody: items => {
                                        const tetoItem = targetLineData ? items.find(i => i.datasetIndex === 1) : null;
                                        if (!tetoItem) return [];
                                        const spendItem = items.find(i => i.datasetIndex === 0 && i.raw > 0);
                                        const rawVal = targetRawData[tetoItem.dataIndex] ?? tetoItem.raw;
                                        const label = rawVal <= 0
                                            ? '🔴 Estourou'
                                            : `${selTarget.emoji || '🎯'} Target`;
                                        const displayVal = rawVal <= 0 ? Math.abs(rawVal) : tetoItem.raw;
                                        const lines = [`${label}: R$ ${formatBRL(displayVal)}`];
                                        if (spendItem) lines.push('──────────────');
                                        return lines;
                                    },
                                    afterBody: items => {
                                        const spendItem = items.find(i => i.datasetIndex === 0);
                                        const nextItem = items.find(i => i.datasetIndex === nextMonthDsIdx && i.raw != null);
                                        const lines = [];
                                        if (spendItem && spendItem.raw) {
                                            const d = parseInt(spendItem.label);
                                            const cats = dailyData[d]?.cats || {};
                                            const sorted = Object.entries(cats).sort((a, b) => b[1].total - a[1].total);
                                            lines.push(...sorted.map(([name, c]) => `${c.emoji} ${name}: R$ ${formatBRL(c.total)}`));
                                            if (sorted.length > 1) {
                                                lines.push('──────────────');
                                                lines.push(`Total: R$ ${formatBRL(dailyData[d].total)}`);
                                            }
                                        }
                                        if (nextItem) {
                                            if (lines.length) lines.push('──────────────');
                                            lines.push(`➡️ Próx. mês: R$ ${formatBRL(nextItem.raw)}`);
                                        }
                                        return lines;
                                    }
                                }
                            }
                        },
                        scales: {
                            x: {
                                grid: { color: gridColor, drawTicks: false },
                                ticks: {
                                    color: textColor, font: { size: 11 }, maxRotation: 0,
                                    callback: (val, idx) => window.innerWidth < 640 && (idx + 1) % 2 === 0 ? '' : String(idx + 1)
                                }
                            },
                            y: {
                                min: yAxisMin,
                                grid: { color: gridColor },
                                ticks: {
                                    color: textColor, font: { size: 11 },
                                    callback: v => v === 0 ? '' : Math.round(v).toLocaleString('pt-BR')
                                }
                            }
                        }
                    },
                    plugins: [weekBandsPlugin, budgetCoeffPlugin]
                });
            } catch (err) {
                console.error('Erro ao atualizar gráfico diário:', err);
            }
        }

        async function updateBarChart() {
            const checkboxes = document.querySelectorAll('.bar-chart-month:checked');
            const selectedMonths = Array.from(checkboxes).map(cb => cb.value);
            const expTypeChecked = barExpTypeFilter.length ? barExpTypeFilter : ['individual', 'compartilhada'];
            const showIndividual = expTypeChecked.includes('individual');
            const showShared = expTypeChecked.includes('compartilhada');

            if (selectedMonths.length === 0) return;

            const isDark = document.body.classList.contains('dark-mode');
            const textColor = isDark ? '#e8eaed' : '#5f6368';
            const gridColor = isDark ? '#3c4043' : '#e0e0e0';

            try {
                const isSharedExpense = (expense, year, mon) => {
                    const us = new Set(expense.splits
                        .filter(s => { const d = new Date(s.due_date + 'T00:00:00'); return d.getFullYear() === year && d.getMonth() + 1 === mon; })
                        .map(s => s.user_id));
                    return us.size > 1 || (us.size === 1 && !us.has(user.id));
                };

                const allExpenses = await Promise.all(selectedMonths.map(m => fetchMonthExpenses(m)));
                const expByMonth = Object.fromEntries(selectedMonths.map((m, i) => [m, allExpenses[i]]));

                const monthlyPersonal = {}, monthlyShared = {};
                for (const month of selectedMonths) {
                    const [year, mon] = month.split('-').map(Number);
                    monthlyPersonal[month] = 0; monthlyShared[month] = 0;
                    for (const expense of expByMonth[month]) {
                        if (selectedCatIds.length > 0 && !selectedCatIds.includes(expense.category_id)) continue;
                        const isShared = isSharedExpense(expense, year, mon);
                        const myAmt = expense.splits
                            .filter(s => { const d = new Date(s.due_date + 'T00:00:00'); return s.user_id === user.id && d.getFullYear() === year && d.getMonth() + 1 === mon; })
                            .reduce((sum, s) => sum + parseFloat(s.user_amount), 0);
                        if (isShared) monthlyShared[month] += myAmt;
                        else monthlyPersonal[month] += myAmt;
                    }
                }

                const months = selectedMonths.sort();
                const datasets = [];
                if (showIndividual) datasets.push({ label: 'Individuais', data: months.map(m => monthlyPersonal[m] || 0), backgroundColor: '#1a73e8', borderColor: '#1a73e8', borderWidth: 1, borderRadius: 0, borderSkipped: false });
                if (showShared)    datasets.push({ label: 'Compartilhadas', data: months.map(m => monthlyShared[m] || 0), backgroundColor: '#34a853', borderColor: '#34a853', borderWidth: 1, borderRadius: 0, borderSkipped: false });

                const monthTotals = months.map(m => (showIndividual ? (monthlyPersonal[m]||0) : 0) + (showShared ? (monthlyShared[m]||0) : 0));

                monthlyBarChart = upsertChart(monthlyBarChart, document.getElementById('monthlyBarChart').getContext('2d'), {
                    type: 'bar',
                    data: { labels: months, datasets },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        plugins: {
                            legend: { display: datasets.length > 1, position: 'top', labels: { color: textColor, font: { size: 14 } } },
                            tooltip: { callbacks: { label: ctx => { const t = monthTotals[ctx.dataIndex]||1; return `${ctx.dataset.label}: R$ ${formatBRL(ctx.parsed.y)} (${t>0?((ctx.parsed.y/t)*100).toFixed(1):0}%)`; } } }
                        },
                        animation: { onComplete: function() {
                            const ci = this; if (!ci.data.datasets.length) return;
                            const nBars = ci.data.labels.length;
                            for (let i = 0; i < nBars; i++) {
                                let topBar = null, visTotal = 0;
                                for (let d = ci.data.datasets.length - 1; d >= 0; d--) {
                                    const meta = ci.getDatasetMeta(d);
                                    if (meta.hidden) continue;
                                    if (!topBar && meta.data[i]) topBar = meta.data[i];
                                    visTotal += ci.data.datasets[d].data[i] || 0;
                                }
                                if (!topBar || visTotal <= 0) continue;
                                ci.ctx.fillStyle = isDark ? '#e8eaed' : '#5f6368';
                                ci.ctx.font = 'bold 10px Arial'; ci.ctx.textAlign = 'center';
                                const _fmtMon = v => window.innerWidth < 640 && v >= 1000 ? (v/1000).toFixed(1).replace('.',',')+'k' : Math.round(v).toLocaleString('pt-BR');
                                ci.ctx.fillText(_fmtMon(visTotal), topBar.x, topBar.y - 8);
                            }
                        }},
                        scales: {
                            y: { display: false, stacked: true, beginAtZero: true, suggestedMax: Math.max(...monthTotals, 1)*1.15 },
                            x: { stacked: true, ticks: { color: textColor, font: { size: 11 } }, grid: { color: gridColor, drawOnChartArea: false } }
                        }
                    }
                });
            } catch (err) {
                console.error('Erro ao atualizar gráfico de barras:', err);
            }
        }


        // ============================================================================
        // GRÁFICO: DESPESAS POR MÊS — POR MÉTODO DE PAGAMENTO
        // ============================================================================
        let pmBarChart=null;
        async function updatePmBarChart(){
            const selectedMonths=Array.from(document.querySelectorAll('.bar-chart-month:checked')).map(cb=>cb.value);
            if(!selectedMonths.length)return;
            const expTypeChecked=barExpTypeFilter.length?barExpTypeFilter:['individual','compartilhada'];
            const showIndividual=expTypeChecked.includes('individual');
            const showShared=expTypeChecked.includes('compartilhada');
            const isDark=document.body.classList.contains('dark-mode');
            const textColor=isDark?'#e8eaed':'#5f6368',gridColor=isDark?'#3c4043':'#e0e0e0';
            const myPmList = userPms(user.id);
            const isSharedExp=(ex,y,m)=>{const us=new Set(ex.splits.filter(s=>{const d=new Date(s.due_date+'T00:00:00');return d.getFullYear()===y&&d.getMonth()+1===m;}).map(s=>s.user_id));return us.size>1||(us.size===1&&!us.has(user.id));};
            try{
                const allExpenses=await Promise.all(selectedMonths.map(m=>fetchMonthExpenses(m)));
                const expByMonth=Object.fromEntries(selectedMonths.map((m,i)=>[m,allExpenses[i]]));
                const monthlyByPm={};
                for(const month of selectedMonths){
                    const [year,mon]=month.split('-').map(Number);
                    monthlyByPm[month]={};
                    myPmList.forEach(pm=>monthlyByPm[month][pm.id]=0);
                    for(const ex of expByMonth[month]){
                        if(selectedCatIds.length>0&&!selectedCatIds.includes(ex.category_id))continue;
                        const shared=isSharedExp(ex,year,mon);
                        if(shared&&!showShared)continue;
                        if(!shared&&!showIndividual)continue;
                        const balPmId=user.preferred_balance_method||null;
                        if(ex.paid_by_user_id===user.id){
                            const pmId=ex.payment_method_id;
                            if(!(pmId in monthlyByPm[month]))monthlyByPm[month][pmId]=0;
                            const seenInst=new Set();
                            for(const s of ex.splits){
                                const d=new Date(s.due_date+'T00:00:00');
                                if(d.getFullYear()!==year||d.getMonth()+1!==mon)continue;
                                if(!seenInst.has(s.installment_number)){seenInst.add(s.installment_number);monthlyByPm[month][pmId]+=parseFloat(s.installment_amount);}
                                if(s.user_id!==user.id&&balPmId){if(!(balPmId in monthlyByPm[month]))monthlyByPm[month][balPmId]=0;monthlyByPm[month][balPmId]-=parseFloat(s.user_amount);}
                            }
                        }else if(balPmId){
                            if(!(balPmId in monthlyByPm[month]))monthlyByPm[month][balPmId]=0;
                            for(const s of ex.splits){
                                if(s.user_id!==user.id)continue;
                                const d=new Date(s.due_date+'T00:00:00');
                                if(d.getFullYear()!==year||d.getMonth()+1!==mon)continue;
                                monthlyByPm[month][balPmId]+=parseFloat(s.user_amount);
                            }
                        }
                    }
                }
                const months=selectedMonths.slice().sort();
                const datasets=myPmList.filter(pm=>months.some(m=>(monthlyByPm[m]?.[pm.id]||0)>0))
                    .map(pm=>({label:pm.description,data:months.map(m=>monthlyByPm[m]?.[pm.id]||0),backgroundColor:pm.color||'#999',borderColor:pm.color||'#999',borderWidth:1,borderRadius:0,borderSkipped:false}));
                const monthTotals=months.map(m=>myPmList.reduce((s,pm)=>s+(monthlyByPm[m]?.[pm.id]||0),0));
                pmBarChart=upsertChart(pmBarChart,document.getElementById('pmBarChart').getContext('2d'),{
                    type:'bar',data:{labels:months,datasets},
                    options:{responsive:true,maintainAspectRatio:false,
                        plugins:{legend:{display:datasets.length>1,position:'top',labels:{color:textColor,font:{size:11}}},
                            tooltip:{callbacks:{label:ctx=>{const t=monthTotals[ctx.dataIndex]||1;return `${ctx.dataset.label}: R$ ${formatBRL(ctx.parsed.y)} (${t>0?((ctx.parsed.y/t)*100).toFixed(1):0}%)`;}}}},
                        animation:{onComplete:function(){const ci=this;if(!ci.data.datasets.length)return;const nBars=ci.data.labels.length;for(let i=0;i<nBars;i++){let topBar=null,visTotal=0;for(let d=ci.data.datasets.length-1;d>=0;d--){const meta=ci.getDatasetMeta(d);if(meta.hidden)continue;const val=ci.data.datasets[d].data[i]||0;visTotal+=val;if(val>0&&meta.data[i]&&(!topBar||meta.data[i].y<topBar.y))topBar=meta.data[i];}if(!topBar||visTotal<=0)continue;ci.ctx.fillStyle=isDark?'#e8eaed':'#5f6368';ci.ctx.font='bold 10px Arial';ci.ctx.textAlign='center';const _fmtPm=v=>window.innerWidth<640&&v>=1000?(v/1000).toFixed(1).replace('.',',')+'k':Math.round(v).toLocaleString('pt-BR');ci.ctx.fillText(_fmtPm(visTotal),topBar.x,topBar.y-8);}}},
                        scales:{y:{display:false,stacked:true,beginAtZero:true,suggestedMax:Math.max(...monthTotals,1)*1.15},x:{stacked:true,ticks:{color:textColor,font:{size:11}},grid:{color:gridColor,drawOnChartArea:false}}}
                    }
                });
            }catch(err){console.error('pmBarChart:',err);}
        }
                // ============================================================================
        // FIM DOS GRÁFICOS
        // ============================================================================

        // Atualiza o objeto user com dados frescos do servidor (inclui preferências)
        async function refreshUserFromServer() {
            try {
                const fresh = await api(`${API}/auth/me`);
                // Mescla mantendo campos que /me pode não retornar
                user = { ...user, ...fresh };
                localStorage.setItem('user', JSON.stringify(user));
            } catch(e) { /* silencioso, usa dados do localStorage */ }
        }

        if (token && localStorage.getItem('user')) {
            user = JSON.parse(localStorage.getItem('user'));
            showDashboard();
            // Atualiza preferências em background sem bloquear a UI
            refreshUserFromServer();
        }

        // ============================================================================
        // SISTEMA DE NOTIFICAÇÕES
        // ============================================================================

        // Estado das notificações
        let notificationSettings = {
            enabled: false,
            new_expense: true,
            edit_expense: false,
            delete_expense: false,
            reminders: true,
            time: '08:00'
        };

        // Carregar configurações salvas
