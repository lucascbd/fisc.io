    (function() {
        const fab = document.getElementById('fabNewExpense');
        if (!fab) return;
        
        let isDragging = false;
        let holdTimer = null;
        let startX, startY, startLeft, startBottom;
        let hasMoved = false;
        let lastTouchEnd = 0;
        
        // Carregar posição salva
        const savedPos = localStorage.getItem('fabPosition');
        if (savedPos) {
            try {
                const pos = JSON.parse(savedPos);
                fab.style.right = 'auto';
                fab.style.left = pos.left + 'px';
                fab.style.bottom = pos.bottom + 'px';
            } catch(e) {}
        }
        
        // Touch Start
        fab.addEventListener('touchstart', function(e) {
            const touch = e.touches[0];
            startX = touch.clientX;
            startY = touch.clientY;
            
            const rect = fab.getBoundingClientRect();
            startLeft = rect.left;
            startBottom = window.innerHeight - rect.bottom;
            
            hasMoved = false;
            
            // Após 300ms, entra em modo drag
            holdTimer = setTimeout(() => {
                isDragging = true;
                fab.style.transform = 'scale(1.15)';
                fab.style.boxShadow = '0 6px 20px rgba(26, 115, 232, 0.6)';
                // Vibrar se disponível
                if (navigator.vibrate) navigator.vibrate(50);
            }, 300);
        }, {passive: true});
        
        // Touch Move
        fab.addEventListener('touchmove', function(e) {
            const touch = e.touches[0];
            const dx = touch.clientX - startX;
            const dy = touch.clientY - startY;
            
            // Se moveu antes de 300ms e não está em drag mode, cancela timer
            if (!isDragging) {
                if (Math.abs(dx) > 10 || Math.abs(dy) > 10) {
                    clearTimeout(holdTimer);
                }
                return;
            }
            
            e.preventDefault();
            hasMoved = true;
            
            let newLeft = startLeft + dx;
            let newBottom = startBottom - dy;
            
            // Limites da tela (com margem de 10px)
            const maxLeft = window.innerWidth - 70;
            const maxBottom = window.innerHeight - 70;
            newLeft = Math.max(10, Math.min(maxLeft, newLeft));
            newBottom = Math.max(10, Math.min(maxBottom, newBottom));
            
            fab.style.right = 'auto';
            fab.style.left = newLeft + 'px';
            fab.style.bottom = newBottom + 'px';
        }, {passive: false});
        
        // Touch End
        fab.addEventListener('touchend', function(e) {
            clearTimeout(holdTimer);
            
            if (isDragging && hasMoved) {
                // Salvar posição
                const rect = fab.getBoundingClientRect();
                localStorage.setItem('fabPosition', JSON.stringify({
                    left: rect.left,
                    bottom: window.innerHeight - rect.bottom
                }));
            }
            
            // Reset visual
            fab.style.transform = 'scale(1)';
            fab.style.boxShadow = '0 4px 12px rgba(26, 115, 232, 0.4)';
            
            // Se não estava arrastando ou não moveu, é um tap - abrir modal
            // Delay para evitar conflito com botões do modal na mesma posição
            if (!isDragging || !hasMoved) {
                setTimeout(() => {
                    showExpenseModal();
                }, 50);
            }
            
            isDragging = false;
            hasMoved = false;
            lastTouchEnd = Date.now();
        });
        
        // Touch Cancel
        fab.addEventListener('touchcancel', function() {
            clearTimeout(holdTimer);
            isDragging = false;
            hasMoved = false;
            fab.style.transform = 'scale(1)';
            fab.style.boxShadow = '0 4px 12px rgba(26, 115, 232, 0.4)';
        });
        
        // Clique no desktop
        fab.addEventListener('click', function(e) {
            // Ignorar click que vem logo após touch (ghost click)
            if (Date.now() - lastTouchEnd < 300) return;
            showExpenseModal();
        });
        

        // ====================================================================
        // AUDIT MODAL
        // ====================================================================
        window._auditFile     = null;
        window._auditPmId     = null;
        window._auditData     = null;
        window._myUserId      = window._myUserId || null;
        window._auditColDate  = null;
        window._auditColDesc  = null;
        window._auditColAmount= null;
        window._auditNegate   = false;
        window._auditMonth    = new Date().toISOString().slice(0, 7);

        window.openAuditModal = function openAuditModal() {
            const savedScroll = window.pageYOffset || 0;
            document.body.style.top = `-${savedScroll}px`;
            document.body.classList.add('modal-open');
            window._auditFile = null;
            window._auditPmId = null;

            const isDark   = document.body.classList.contains('dark-mode');
            const bg       = isDark ? '#1e1e1e' : '#fff';
            const txt      = isDark ? '#e8eaed' : '#202124';
            const border   = isDark ? '#3c4043' : '#e0e0e0';
            const sub      = isDark ? '#9aa0a6' : '#5f6368';
            const cardBg   = isDark ? '#2d2d2d' : '#f8f9fa';

            const pmHtml = (paymentMethods || []).filter(pm => pm.user_id === window._myUserId).map(pm => {
                const img = pm.icon_path
                    ? `<img src="${pm.icon_path}" style="width:26px;height:26px;object-fit:contain;">`
                    : `<span style="width:26px;height:26px;display:inline-flex;align-items:center;justify-content:center;border-radius:50%;background:${pm.color||'#999'};font-size:12px;">💳</span>`;
                return `<label class="flex flex-col items-center gap-1 cursor-pointer tgt-pm-label" onclick="event.stopPropagation();selectAuditPm(${pm.id})">
                    <div class="pm-option" id="audit_pm_${pm.id}" data-pm-id="${pm.id}"
                         style="width:44px;height:44px;border-radius:12px;border:2px solid transparent;display:flex;align-items:center;justify-content:center;background:${isDark?'#3c4043':'#f8f9fa'};box-shadow:none;transition:.15s;">
                        ${img}
                    </div>
                    <span class="text-xs" style="max-width:48px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${pm.description}</span>
                </label>`;
            }).join('');

            document.getElementById('modalContainer').innerHTML = `
            <div id="auditOverlay" class="modal-overlay fixed inset-0 z-50 flex items-start justify-center pt-4 pb-4"
                 style="background:rgba(0,0,0,0.5);overflow-y:auto;">
              <div style="background:${bg};color:${txt};width:100%;max-width:680px;border-radius:28px;
                          overflow:hidden;margin:0 12px;box-shadow:0 4px 8px 3px rgba(60,64,67,0.15),0 1px 3px rgba(60,64,67,0.3);">

                <!-- Header -->
                <div style="background:#e8f0fe;padding:1.25rem 1.5rem;
                            border-radius:28px 28px 0 0;display:flex;align-items:center;gap:12px;">
                  <div style="width:40px;height:40px;background:#d2e3fc;
                              border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                    <span style="font-size:1.1rem;">🔍</span>
                  </div>
                  <h2 style="flex:1;font-size:1.1rem;font-weight:500;color:#202124;">Auditar extrato</h2>
                  <button onclick="closeModal()"
                    style="width:40px;height:40px;border-radius:50%;display:flex;align-items:center;
                           justify-content:center;background:transparent;border:none;cursor:pointer;">
                    <span style="font-size:1.5rem;color:${sub};">✕</span>
                  </button>
                </div>

                <!-- Step 1: Upload -->
                <div id="auditStep1" style="padding:20px;">
                  <div id="auditDropZone"
                    onclick="document.getElementById('auditFileInput').click()"
                    ondragover="event.preventDefault();this.style.borderColor='#1a73e8';"
                    ondragleave="this.style.borderColor='${border}';"
                    ondrop="auditHandleDrop(event)"
                    style="border:2px dashed ${border};border-radius:12px;padding:28px 20px;
                           text-align:center;cursor:pointer;transition:.15s;margin-bottom:20px;">
                    <div style="font-size:2.2rem;margin-bottom:6px;">📂</div>
                    <div style="font-size:0.9rem;font-weight:500;color:${txt};margin-bottom:3px;">
                      Clique ou arraste o arquivo</div>
                    <div style="font-size:0.78rem;color:${sub};">.csv (cartão) · .ofx (conta corrente) · .xlsx (cartão)</div>
                    <div id="auditFileName" style="margin-top:8px;font-size:0.85rem;
                                                   color:#1a73e8;font-weight:500;"></div>
                  </div>
                  <input type="file" id="auditFileInput" accept=".csv,.ofx,.xlsx"
                         style="display:none;" onchange="auditFileSelected(this)">

                  <!-- CSV column mapping (shown only for .csv files) -->
                  <div id="auditCsvMapping" style="display:none;margin-bottom:20px;
                       border:1px solid ${border};border-radius:10px;padding:14px;">
                    <div style="font-size:0.82rem;font-weight:600;color:${txt};margin-bottom:12px;">
                      📋 Colunas do CSV</div>
                    <div style="display:grid;gap:10px;">
                      <div style="display:grid;grid-template-columns:100px 1fr;align-items:center;gap:8px;">
                        <label style="font-size:0.8rem;color:${sub};">Data</label>
                        <select id="auditColDate" onchange="window._auditColDate=this.value"
                          style="padding:6px 8px;border:1px solid ${border};border-radius:6px;
                                 background:${cardBg};color:${txt};font-size:0.82rem;"></select>
                      </div>
                      <div style="display:grid;grid-template-columns:100px 1fr;align-items:center;gap:8px;">
                        <label style="font-size:0.8rem;color:${sub};">Descrição</label>
                        <select id="auditColDesc" onchange="window._auditColDesc=this.value"
                          style="padding:6px 8px;border:1px solid ${border};border-radius:6px;
                                 background:${cardBg};color:${txt};font-size:0.82rem;"></select>
                      </div>
                      <div style="display:grid;grid-template-columns:100px 1fr;align-items:center;gap:8px;">
                        <label style="font-size:0.8rem;color:${sub};">Valor</label>
                        <select id="auditColAmount" onchange="window._auditColAmount=this.value"
                          style="padding:6px 8px;border:1px solid ${border};border-radius:6px;
                                 background:${cardBg};color:${txt};font-size:0.82rem;"></select>
                      </div>
                      <div style="display:flex;align-items:center;gap:8px;padding-top:2px;">
                        <input type="checkbox" id="auditNegate"
                               onchange="window._auditNegate=this.checked" style="cursor:pointer;">
                        <label for="auditNegate" style="font-size:0.8rem;color:${sub};cursor:pointer;">
                          Inverter sinal (despesas estão como negativo no arquivo)</label>
                      </div>
                    </div>
                  </div>

                  <div style="margin-bottom:20px;">
                    <div style="font-size:0.82rem;font-weight:500;color:${sub};margin-bottom:10px;">
                      Método de pagamento do arquivo:</div>
                    <div style="display:flex;gap:8px;flex-wrap:wrap;" id="auditPmRow">
                      ${pmHtml || `<span style="font-size:0.82rem;color:${sub};">
                                   Nenhum método cadastrado</span>`}
                    </div>
                  </div>

                  <div style="margin-bottom:20px;">
                    <div style="font-size:0.82rem;font-weight:500;color:${sub};margin-bottom:10px;">
                      Mês de referência:</div>
                    <div class="ms-wrap" style="width:100%;">
                      <button type="button" class="ms-btn" onclick="stepMonth('auditMonthSelect',1);window._auditMonth=document.getElementById('auditMonthSelect').value;_auditCheckReady()">❮</button>
                      <select id="auditMonthSelect" class="ms-select"
                        onchange="window._auditMonth=this.value;_auditCheckReady()"
                        style="flex:1;text-align:center;"></select>
                      <button type="button" class="ms-btn" onclick="stepMonth('auditMonthSelect',-1);window._auditMonth=document.getElementById('auditMonthSelect').value;_auditCheckReady()">❯</button>
                    </div>
                  </div>

                  <button id="auditRunBtn" onclick="runAudit()" disabled
                    style="width:100%;padding:12px;border:none;border-radius:10px;
                           font-size:0.95rem;font-weight:600;cursor:not-allowed;
                           background:#ccc;color:#fff;transition:.15s;">
                    Analisar arquivo
                  </button>
                  <button id="auditExportBtn" onclick="runAuditExport()" disabled
                    style="width:100%;margin-top:10px;padding:11px;border:1px solid #ccc;
                           border-radius:10px;font-size:0.9rem;font-weight:500;cursor:not-allowed;
                           background:transparent;color:#ccc;transition:.15s;">
                    📊 Exportar Excel do mês
                  </button>
                </div>

                <!-- Step 2: Loading -->
                <div id="auditStep2" style="display:none;padding:48px 20px;text-align:center;">
                  <div style="font-size:2.5rem;margin-bottom:12px;">⏳</div>
                  <div style="font-size:0.9rem;color:${sub};">
                    Analisando e comparando com a base...</div>
                </div>

                <!-- Step 3: Results -->
                <div id="auditStep3" style="display:none;">
                  <div id="auditStats"
                    style="padding:10px 20px;background:${cardBg};border-bottom:1px solid ${border};
                           font-size:0.78rem;display:flex;gap:14px;flex-wrap:wrap;color:${sub};"></div>

                  <!-- Tabs -->
                  <div style="display:flex;border-bottom:1px solid ${border};">
                    <button id="auditTabBtnMatched" onclick="showAuditTab('matched')"
                      style="flex:1;padding:11px 4px;border:none;background:none;cursor:pointer;
                             font-size:0.8rem;font-weight:600;color:#34a853;
                             border-bottom:3px solid #34a853;">
                      ✅ Matched <span id="auditCntMatched"></span>
                    </button>
                    <button id="auditTabBtnAmbiguous" onclick="showAuditTab('ambiguous')"
                      style="flex:1;padding:11px 4px;border:none;background:none;cursor:pointer;
                             font-size:0.8rem;font-weight:600;color:${sub};
                             border-bottom:3px solid transparent;">
                      ⚠️ Ambíguo <span id="auditCntAmbiguous"></span>
                    </button>
                    <button id="auditTabBtnUnmatched" onclick="showAuditTab('unmatched')"
                      style="flex:1;padding:11px 4px;border:none;background:none;cursor:pointer;
                             font-size:0.8rem;font-weight:600;color:${sub};
                             border-bottom:3px solid transparent;">
                      ❌ Não encontrado <span id="auditCntUnmatched"></span>
                    </button>
                    <button id="auditTabBtnSurplus" onclick="showAuditTab('surplus')"
                      style="flex:1;padding:11px 4px;border:none;background:none;cursor:pointer;
                             font-size:0.8rem;font-weight:600;color:${sub};
                             border-bottom:3px solid transparent;">
                      🔵 Excedente <span id="auditCntSurplus"></span>
                    </button>
                  </div>

                  <div id="auditTabContent"
                    style="max-height:62vh;overflow-y:auto;"></div>

                  <div style="padding:10px 20px;border-top:1px solid ${border};text-align:center;">
                    <button onclick="auditReset()"
                      style="background:none;border:1px solid ${border};border-radius:8px;
                             padding:7px 20px;font-size:0.82rem;cursor:pointer;color:${sub};">
                      Voltar
                    </button>
                  </div>
                </div>

              </div>
            </div>`;

            // Populate month stepper from /expenses/months, default to current month
            const currentMonthVal = new Date().toISOString().slice(0, 7);
            api(`${API}/expenses/months`).then(data => {
                const sel = document.getElementById('auditMonthSelect');
                if (!sel) return;
                const mlist = Array.isArray(data) ? data : [];
                // If current month not in list, prepend it
                if (!mlist.find(m => m.value === currentMonthVal)) {
                    const d = new Date(currentMonthVal + '-01');
                    const label = d.toLocaleDateString('pt-BR', { month: 'short', year: 'numeric' });
                    mlist.push({ value: currentMonthVal, label });
                    mlist.sort((a, b) => a.value.localeCompare(b.value));
                }
                sel.innerHTML = mlist.map(m => `<option value="${m.value}">${m.label}</option>`).join('');
                const target = window._auditMonth || currentMonthVal;
                sel.value = mlist.find(m => m.value === target) ? target
                    : (mlist.length ? mlist[mlist.length - 1].value : currentMonthVal);
                window._auditMonth = sel.value;
                _auditCheckReady();
            }).catch(() => {
                // Fallback: plain month input
                const sel = document.getElementById('auditMonthSelect');
                if (sel) {
                    sel.innerHTML = `<option value="${currentMonthVal}">${currentMonthVal}</option>`;
                    sel.value = currentMonthVal;
                    window._auditMonth = currentMonthVal;
                }
            });
        }

        window.selectAuditPm = function selectAuditPm(pmId) {
            pmId = parseInt(pmId);
            window._auditPmId = pmId;
            const isDark = document.body.classList.contains('dark-mode');
            const selBg  = isDark ? '#8ab4f8' : '#e8f0fe';
            const selBdr = isDark ? '#8ab4f8' : '#1a73e8';
            const defBg  = isDark ? '#3c4043' : '#f8f9fa';
            document.querySelectorAll('[id^="audit_pm_"]').forEach(el => {
                const active = parseInt(el.dataset.pmId) === pmId;
                el.classList.toggle('selected', active);
                el.style.background = active ? selBg : defBg;
                el.style.borderColor = active ? selBdr : 'transparent';
                el.style.boxShadow = active && isDark ? '0 0 0 2px rgba(138,180,248,0.3)' : 'none';
            });
            _auditCheckReady();
        }

        window.auditFileSelected = function auditFileSelected(input) {
            const file = input.files[0];
            if (!file) return;
            window._auditFile = file;
            document.getElementById('auditFileName').textContent = `📄 ${file.name}`;
            document.getElementById('auditDropZone').style.borderColor = '#1a73e8';
            const fname = file.name.toLowerCase();
            const isCsv = fname.endsWith('.csv');
            const mapDiv = document.getElementById('auditCsvMapping');
            if (mapDiv) mapDiv.style.display = isCsv ? 'block' : 'none';
            if (isCsv) {
                const reader = new FileReader();
                reader.onload = e => {
                    const firstLine = (e.target.result || '').split('\n')[0];
                    const sep = firstLine.includes(';') ? ';' : ',';
                    const headers = firstLine.split(sep).map(h => h.trim().replace(/^"|"$/g, ''));
                    _auditPopulateCsvCols(headers);
                };
                reader.readAsText(file, 'utf-8');
            }
            _auditCheckReady();
        }

        function _auditPopulateCsvCols(headers) {
            const stripAcc = s => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();
            const opts = headers.map(h => `<option value="${h}">${h}</option>`).join('');
            ['auditColDate','auditColDesc','auditColAmount'].forEach(id => {
                const el = document.getElementById(id);
                if (el) el.innerHTML = opts;
            });
            const trySelect = (elId, keywords) => {
                const el = document.getElementById(elId);
                if (!el) return;
                const match = headers.find(h => keywords.some(k => stripAcc(h).includes(k)));
                if (match) el.value = match;
            };
            trySelect('auditColDate',   ['data','date','dt']);
            trySelect('auditColDesc',   ['lancamento','descricao','historico','desc','nome','memorial']);
            trySelect('auditColAmount', ['valor','value','amount','vl','vlr','montante']);
            // Sync to window vars
            const d = document.getElementById('auditColDate');
            const s = document.getElementById('auditColDesc');
            const a = document.getElementById('auditColAmount');
            window._auditColDate   = d ? d.value : null;
            window._auditColDesc   = s ? s.value : null;
            window._auditColAmount = a ? a.value : null;
        }

        window.auditHandleDrop = function auditHandleDrop(event) {
            event.preventDefault();
            const file = event.dataTransfer.files[0];
            if (!file) return;
            window._auditFile = file;
            document.getElementById('auditFileName').textContent = `📄 ${file.name}`;
            document.getElementById('auditDropZone').style.borderColor = '#1a73e8';
            try {
                const dt = new DataTransfer();
                dt.items.add(file);
                document.getElementById('auditFileInput').files = dt.files;
            } catch(e) {}
            // Trigger same CSV-detection logic as file input
            const fname = file.name.toLowerCase();
            const isCsv = fname.endsWith('.csv');
            const mapDiv = document.getElementById('auditCsvMapping');
            if (mapDiv) mapDiv.style.display = isCsv ? 'block' : 'none';
            if (isCsv) {
                const reader = new FileReader();
                reader.onload = e => {
                    const firstLine = (e.target.result || '').split('\n')[0];
                    const sep = firstLine.includes(';') ? ';' : ',';
                    const headers = firstLine.split(sep).map(h => h.trim().replace(/^"|"$/g, ''));
                    _auditPopulateCsvCols(headers);
                };
                reader.readAsText(file, 'utf-8');
            }
            _auditCheckReady();
        }

        function _auditCheckReady() {
            const month = document.getElementById('auditMonthSelect')?.value || window._auditMonth;

            const runBtn = document.getElementById('auditRunBtn');
            if (runBtn) {
                const ok = !!(window._auditFile && window._auditPmId && month);
                runBtn.disabled      = !ok;
                runBtn.style.background = ok ? '#1a73e8' : '#ccc';
                runBtn.style.cursor     = ok ? 'pointer'  : 'not-allowed';
            }

            const expBtn = document.getElementById('auditExportBtn');
            if (expBtn) {
                const ok = !!(window._auditPmId && month);
                expBtn.disabled           = !ok;
                expBtn.style.borderColor  = ok ? '#1a73e8' : '#ccc';
                expBtn.style.color        = ok ? '#1a73e8' : '#ccc';
                expBtn.style.cursor       = ok ? 'pointer'  : 'not-allowed';
            }
        }

        window.runAudit = async function runAudit() {
            if (!window._auditFile || !window._auditPmId) return;
            document.getElementById('auditStep1').style.display = 'none';
            document.getElementById('auditStep2').style.display = 'block';
            try {
                const fd = new FormData();
                fd.append('file', window._auditFile);
                fd.append('payment_method_id', window._auditPmId);
                // CSV column mapping (read live from selects in case user changed them)
                if (window._auditFile.name.toLowerCase().endsWith('.csv')) {
                    const dEl = document.getElementById('auditColDate');
                    const sEl = document.getElementById('auditColDesc');
                    const aEl = document.getElementById('auditColAmount');
                    const nEl = document.getElementById('auditNegate');
                    if (dEl && dEl.value) fd.append('col_date',   dEl.value);
                    if (sEl && sEl.value) fd.append('col_desc',   sEl.value);
                    if (aEl && aEl.value) fd.append('col_amount', aEl.value);
                    fd.append('negate_amount', (nEl && nEl.checked) ? 'true' : 'false');
                }
                const mEl = document.getElementById('auditMonthSelect');
                const mVal = (mEl && mEl.value) || window._auditMonth;
                if (mVal) fd.append('audit_month', mVal);
                const token = localStorage.getItem('token');
                const res = await fetch(`${API}/audit/analyze`, {
                    method: 'POST',
                    headers: { 'Authorization': `Bearer ${token}` },
                    body: fd
                });
                if (!res.ok) {
                    const err = await res.json().catch(() => ({}));
                    throw new Error(err.detail || `Erro ${res.status}`);
                }
                window._auditData = await res.json();

                document.getElementById('auditStep2').style.display = 'none';
                document.getElementById('auditStep3').style.display = 'block';

                const s = window._auditData.stats;
                document.getElementById('auditStats').innerHTML =
                    `<span>📄 Lidos: <b>${s.parsed ?? s.total}</b></span>` +
                    `<span style="color:#34a853;">✅ ${s.matched} matched</span>` +
                    `<span style="color:#f9ab00;">⚠️ ${s.ambiguous} ambíguo</span>` +
                    `<span style="color:#ea4335;">❌ ${s.unmatched} não encontrado</span>` +
                    (s.surplus ? `<span style="color:#1a73e8;">🔵 ${s.surplus} excedente</span>` : '') +
                    (s.micro ? `<span style="color:#9aa0a6;">🔧 ${s.micro} micro-ajustes</span>` : '') +
                    (s.silent ? `<span style="color:#9aa0a6;">🔇 ${s.silent} filtrados</span>` : '');

                _auditUpdateCounts();

                // Open most actionable tab first
                if (s.ambiguous > 0)       showAuditTab('ambiguous');
                else if (s.unmatched > 0)  showAuditTab('unmatched');
                else if (s.surplus > 0)    showAuditTab('surplus');
                else                        showAuditTab('matched');

            } catch(e) {
                document.getElementById('auditStep2').style.display = 'none';
                document.getElementById('auditStep1').style.display = 'block';
                alert(e.message || 'Erro ao processar arquivo');
            }
        }

        window.runAuditExport = async function runAuditExport() {
            if (!window._auditPmId) return;
            const mEl  = document.getElementById('auditMonthSelect');
            const month = (mEl && mEl.value) || window._auditMonth;
            if (!month) return;

            const btn = document.getElementById('auditExportBtn');
            const origText = btn ? btn.textContent : '';
            if (btn) { btn.textContent = '⏳ Gerando...'; btn.disabled = true; }

            try {
                const token = localStorage.getItem('token');
                const res   = await fetch(
                    `${API}/audit/export?payment_method_id=${window._auditPmId}&audit_month=${month}`,
                    { headers: { 'Authorization': `Bearer ${token}` } }
                );
                if (!res.ok) {
                    const err = await res.json().catch(() => ({}));
                    throw new Error(err.detail || `Erro ${res.status}`);
                }
                const blob = await res.blob();
                const url  = URL.createObjectURL(blob);
                const a    = document.createElement('a');
                const cd   = res.headers.get('Content-Disposition') || '';
                const fnMatch = cd.match(/filename="([^"]+)"/);
                a.download = fnMatch ? fnMatch[1] : `despesas_${month}.xlsx`;
                a.href = url;
                a.click();
                URL.revokeObjectURL(url);
            } catch(e) {
                alert(e.message || 'Erro ao exportar');
            } finally {
                if (btn) { btn.textContent = origText; btn.disabled = false; }
            }
        }

        function _auditUpdateCounts() {
            if (!window._auditData) return;
            const s = window._auditData.stats;
            const micro = (window._auditData.micro_adjustments || []).length;
            document.getElementById('auditCntMatched').textContent   = `(${s.matched})`;
            document.getElementById('auditCntAmbiguous').textContent = `(${s.ambiguous})`;
            document.getElementById('auditCntUnmatched').textContent =
                `(${s.unmatched + (micro > 0 ? 1 : 0)})`;
            const surplusEl = document.getElementById('auditCntSurplus');
            if (surplusEl) surplusEl.textContent = `(${s.surplus ?? (window._auditData.surplus || []).length})`;
        }

        window.showAuditTab = function showAuditTab(tab) {
            const isDark = document.body.classList.contains('dark-mode');
            const sub    = isDark ? '#9aa0a6' : '#5f6368';
            const colors = { matched:'#34a853', ambiguous:'#f9ab00', unmatched:'#ea4335', surplus:'#1a73e8' };
            ['matched','ambiguous','unmatched','surplus'].forEach(t => {
                const btn = document.getElementById(
                    `auditTabBtn${t.charAt(0).toUpperCase()+t.slice(1)}`);
                if (!btn) return;
                const active = t === tab;
                btn.style.color        = active ? colors[t] : sub;
                btn.style.borderBottom = active ? `3px solid ${colors[t]}` : '3px solid transparent';
            });
            const d = window._auditData;
            const el = document.getElementById('auditTabContent');
            if (tab === 'matched')    el.innerHTML = _auditRenderMatched(d.matched);
            if (tab === 'ambiguous')  el.innerHTML = _auditRenderAmbiguous(d.ambiguous);
            if (tab === 'unmatched')  el.innerHTML = _auditRenderUnmatched(d.unmatched, d.micro_adjustments);
            if (tab === 'surplus')    el.innerHTML = _auditRenderSurplus(d.surplus || []);
        }

        // ── Helpers ──────────────────────────────────────────────────────────
        function _afmt(amount) {
            const abs = Math.abs(amount).toFixed(2).replace('.', ',');
            return amount < 0
                ? `R$ ${abs} <span style="color:#34a853;font-size:0.75rem;">(entrada)</span>`
                : `R$ ${abs}`;
        }
        function _adate(iso) {
            const [y,m,d] = iso.split('-');
            return `${d}/${m}/${y.slice(2)}`;
        }

        // ── Tab: Matched ─────────────────────────────────────────────────────
        function _auditRenderMatched(items) {
            if (!items.length)
                return `<div style="padding:32px;text-align:center;color:#9aa0a6;">
                         Nenhum lançamento com match automático</div>`;
            const isDark = document.body.classList.contains('dark-mode');
            const border = isDark ? '#3c4043' : '#f0f0f0';
            const sub    = isDark ? '#9aa0a6' : '#5f6368';
            return items.map(item => {
                const parc = item.file.parcel_num
                    ? ` <span style="color:${sub};font-size:0.73rem;">
                          ${item.file.parcel_num}/${item.file.parcel_total}</span>` : '';
                return `
                <div style="padding:11px 20px;border-bottom:1px solid ${border};
                            display:flex;gap:10px;align-items:center;">
                  <div style="flex:1;min-width:0;">
                    <div style="font-size:0.85rem;font-weight:500;">
                      <span style="color:${sub};font-size:0.73rem;">${_adate(item.file.date)}</span>
                      <span style="margin-left:6px;">${item.file.description}</span>${parc}
                    </div>
                    <div style="font-size:0.75rem;color:${sub};margin-top:2px;">
                      ➔ ${item.expense?.description || '?'} · ${item.reason}
                    </div>
                  </div>
                  <div style="font-size:0.88rem;font-weight:600;white-space:nowrap;">
                    ${_afmt(item.file.amount)}</div>
                  <span style="font-size:1rem;">✅</span>
                </div>`;
            }).join('');
        }

        // ── Tab: Surplus (in app, not in file) ──────────────────────────────
        function _auditRenderSurplus(items) {
            if (!items.length)
                return `<div style="padding:32px;text-align:center;color:#9aa0a6;">
                         🎉 Nenhuma despesa excedente encontrada</div>`;
            const isDark = document.body.classList.contains('dark-mode');
            const border = isDark ? '#3c4043' : '#f0f0f0';
            const sub    = isDark ? '#9aa0a6' : '#5f6368';
            const txt    = isDark ? '#e8eaed' : '#202124';
            const hdr    = isDark ? '#2a3a5c' : '#e8f0fe';

            return `<div style="padding:10px 20px 6px;background:${hdr};font-size:0.78rem;color:${isDark?'#8ab4f8':'#1a73e8'};">
                      ℹ️ Estas despesas estão no app para o mês selecionado, mas não apareceram na fatura enviada.
                    </div>` +
            items.map((exp, idx) => {
                const isParc = exp.installments > 1;
                const parcLabel = isParc
                    ? `<span style="font-size:0.72rem;color:${sub};margin-left:5px;">(${exp.installments}x)</span>` : '';
                return `
                <div id="surplus_${idx}" style="padding:11px 20px;border-bottom:1px solid ${border};
                            display:flex;gap:10px;align-items:center;">
                  <div style="flex:1;min-width:0;">
                    <div style="font-size:0.85rem;font-weight:500;color:${txt};">
                      ${exp.description}${parcLabel}
                    </div>
                    <div style="font-size:0.73rem;color:${sub};margin-top:2px;">
                      ${_adate(exp.expense_date)}
                    </div>
                  </div>
                  <div style="display:flex;align-items:center;gap:8px;flex-shrink:0;">
                    <span style="font-size:0.88rem;font-weight:600;white-space:nowrap;">
                      R$ ${(exp.display_amount ?? exp.total_amount).toFixed(2).replace('.',',')}
                    </span>
                    <button onclick="_auditSurplusIgnore(${idx})"
                      style="background:none;border:1px solid ${border};border-radius:6px;
                             padding:2px 8px;font-size:0.73rem;cursor:pointer;color:${sub};">
                      Ignorar</button>
                    <button onclick="editExpense(${exp.id});closeModal()"
                      style="background:none;border:1px solid ${border};border-radius:6px;
                             padding:2px 8px;font-size:0.73rem;cursor:pointer;color:${sub};">
                      Editar</button>
                  </div>
                </div>`;
            }).join('');
        }

        window._auditSurplusIgnore = function _auditSurplusIgnore(idx) {
            const el = document.getElementById(`surplus_${idx}`);
            if (el) el.style.display = 'none';
        }

        // ── Tab: Ambiguous ───────────────────────────────────────────────────
        function _auditRenderAmbiguous(items) {
            if (!items.length)
                return `<div style="padding:32px;text-align:center;color:#9aa0a6;">
                         Sem itens ambíguos</div>`;
            const isDark = document.body.classList.contains('dark-mode');
            const border = isDark ? '#3c4043' : '#e0e0e0';
            const sub    = isDark ? '#9aa0a6' : '#5f6368';
            const txt    = isDark ? '#e8eaed' : '#202124';
            const rbg    = isDark ? '#3c4043' : '#fff';

            return items.map((item, idx) => {
                const parc = item.file.parcel_num
                    ? `<span style="font-size:0.73rem;color:${sub};margin-left:4px;">
                         ${item.file.parcel_num}/${item.file.parcel_total}</span>` : '';
                const opts = item.candidates.map(c => `
                    <label style="display:flex;align-items:center;gap:8px;padding:6px 8px;
                                  border-radius:8px;cursor:pointer;margin-bottom:4px;
                                  background:${rbg};border:1px solid ${border};">
                      <input type="radio" name="ambig_${idx}" value="${c.expense.id}"
                             style="accent-color:#1a73e8;flex-shrink:0;">
                      <div style="flex:1;font-size:0.8rem;">
                        <span style="font-weight:500;">${c.expense.description}</span>
                        <span style="color:${sub};margin-left:5px;">${_adate(c.expense.expense_date)}</span>
                        <span style="color:${sub};margin-left:5px;">
                          R$ ${(c.expense.display_amount ?? c.expense.total_amount).toFixed(2).replace('.',',')}${c.expense.installments > 1 ? ` <span style="color:${sub};font-size:0.7rem;">(parc.)</span>` : ''}</span>
                      </div>
                      <span style="font-size:0.73rem;font-weight:600;
                                   color:${c.similarity>=0.7?'#34a853':'#f9ab00'};">
                        ${(c.similarity*100).toFixed(0)}%</span>
                    </label>`).join('') +
                    `<label style="display:flex;align-items:center;gap:8px;padding:6px 8px;
                                   border-radius:8px;cursor:pointer;background:${rbg};
                                   border:1px solid ${border};">
                       <input type="radio" name="ambig_${idx}" value="none"
                              style="accent-color:#ea4335;flex-shrink:0;">
                       <span style="font-size:0.8rem;color:${sub};">
                         Nenhum desses ➔ mover para ❌</span>
                     </label>`;

                return `
                <div style="padding:14px 20px;border-bottom:1px solid ${border};">
                  <div style="display:flex;justify-content:space-between;
                              align-items:flex-start;margin-bottom:10px;">
                    <div>
                      <span style="font-size:0.73rem;color:${sub};">${_adate(item.file.date)}</span>
                      <span style="font-size:0.9rem;font-weight:600;color:${txt};margin-left:7px;">
                        ${item.file.description}</span>${parc}
                    </div>
                    <span style="font-size:0.88rem;font-weight:600;white-space:nowrap;margin-left:12px;">
                      ${_afmt(item.file.amount)}</span>
                  </div>
                  <div style="margin-bottom:10px;">${opts}</div>
                  <button onclick="_auditConfirmAmbig(${idx})"
                    style="background:#1a73e8;color:#fff;border:none;border-radius:8px;
                           padding:7px 16px;font-size:0.82rem;font-weight:500;cursor:pointer;">
                    Confirmar
                  </button>
                </div>`;
            }).join('');
        }

        window._auditConfirmAmbig = function _auditConfirmAmbig(idx) {
            const sel = document.querySelector(`input[name="ambig_${idx}"]:checked`);
            if (!sel) { alert('Selecione uma opção'); return; }
            const item = window._auditData.ambiguous[idx];
            if (sel.value === 'none') {
                window._auditData.unmatched.push({ file: item.file });
                window._auditData.stats.unmatched++;
            } else {
                const cand = item.candidates.find(c => c.expense.id === parseInt(sel.value));
                window._auditData.matched.push({
                    file: item.file, expense: cand.expense,
                    reason: `confirmado (${(cand.similarity*100).toFixed(0)}%)`
                });
                window._auditData.stats.matched++;
            }
            window._auditData.ambiguous.splice(idx, 1);
            window._auditData.stats.ambiguous--;
            _auditUpdateCounts();
            if (window._auditData.ambiguous.length === 0) showAuditTab('unmatched');
            else showAuditTab('ambiguous');
        }

        // ── Tab: Unmatched ───────────────────────────────────────────────────
        function _auditRenderUnmatched(items, micro) {
            const isDark  = document.body.classList.contains('dark-mode');
            const border  = isDark ? '#3c4043' : '#e0e0e0';
            const sub     = isDark ? '#9aa0a6' : '#5f6368';
            const txt     = isDark ? '#e8eaed' : '#202124';
            const selBg   = isDark ? '#3c4043' : '#fff';

            const catOpts  = (categories || []).filter(c => c.is_active !== false)
                .map(c => `<option value="${c.id}">${c.icon||''} ${c.name}</option>`).join('');
            const profOpts = (profiles || []).map(p =>
                `<option value="${p.id}">${p.emoji||'⚖️'} ${p.name}</option>`).join('');
            const userOpts = (users || []).filter(u => u.is_active !== false)
                .map(u => `<option value="${u.id}" ${u.id===window._myUserId?'selected':''}>${u.name}</option>`).join('');

            if (!items.length && (!micro || !micro.length))
                return `<div style="padding:32px;text-align:center;color:#9aa0a6;">
                         🎉 Todos os lançamentos foram encontrados!</div>`;

            const selStyle = `flex:1;min-width:100px;padding:5px 8px;border:1px solid ${border};
                              border-radius:8px;font-size:0.8rem;background:${selBg};color:${txt};`;

            // ── Bulk-apply bar ────────────────────────────────────────────────
            const bulkBar = items.length < 2 ? '' : `
            <div id="auditBulkBar" style="padding:12px 20px;background:${isDark?'#2d3748':'#f0f7ff'};
                 border-bottom:2px solid ${isDark?'#4a5568':'#c3dafe'};">
              <div style="font-size:0.78rem;font-weight:600;color:${isDark?'#8ab4f8':'#1a73e8'};
                           margin-bottom:8px;">⚡ Aplicar a todos (${items.length} itens)</div>
              <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center;">
                <select id="bulk_cat" onchange="_auditBulkCheck()"
                  style="${selStyle}">
                  <option value="">Categoria...</option>${catOpts}</select>
                <select id="bulk_prof" onchange="_auditBulkCheck()"
                  style="${selStyle}">
                  <option value="">Perfil...</option>${profOpts}</select>
                <select id="bulk_user" onchange="_auditBulkCheck()"
                  style="${selStyle}">
                  <option value="">Quem pagou...</option>${userOpts}</select>
                <button id="auditAddAllBtn" onclick="_auditAddAll()" disabled
                  style="background:#ccc;color:#fff;border:none;border-radius:8px;
                         padding:6px 14px;font-size:0.8rem;font-weight:600;
                         cursor:not-allowed;white-space:nowrap;transition:.15s;">
                  Adicionar todos</button>
              </div>
            </div>`;

            const itemsHtml = items.map((item, idx) => {
                const parc = item.file.parcel_num
                    ? `<span style="font-size:0.73rem;color:${sub};margin-left:4px;">
                         ${item.file.parcel_num}/${item.file.parcel_total}</span>` : '';
                return `
                <div id="unmatch_${idx}" style="padding:13px 20px;border-bottom:1px solid ${border};">
                  <div style="display:flex;justify-content:space-between;align-items:center;
                              margin-bottom:9px;">
                    <div style="flex:1;min-width:0;overflow:hidden;">
                      <span style="font-size:0.73rem;color:${sub};">${_adate(item.file.date)}</span>
                      <span style="font-size:0.88rem;font-weight:600;color:${txt};margin-left:6px;">
                        ${item.file.description}</span>${parc}
                    </div>
                    <div style="display:flex;align-items:center;gap:7px;flex-shrink:0;margin-left:10px;">
                      <span style="font-size:0.88rem;font-weight:600;">${_afmt(item.file.amount)}</span>
                      <button onclick="_auditIgnore(${idx})"
                        style="background:none;border:1px solid ${border};border-radius:6px;
                               padding:2px 8px;font-size:0.73rem;cursor:pointer;color:${sub};">
                        Ignorar</button>
                    </div>
                  </div>
                  <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center;">
                    <select id="uc_${idx}" style="${selStyle}">
                      <option value="">Categoria...</option>${catOpts}</select>
                    <select id="up_${idx}" style="${selStyle}">
                      <option value="">Perfil...</option>${profOpts}</select>
                    <select id="uu_${idx}" style="${selStyle}">
                      ${userOpts}</select>
                    <button onclick="_auditAdd(${idx})"
                      style="background:#1a73e8;color:#fff;border:none;border-radius:8px;
                             padding:6px 14px;font-size:0.8rem;font-weight:500;
                             cursor:pointer;white-space:nowrap;">
                      + Adicionar</button>
                  </div>
                </div>`;
            }).join('');

            // Micro-adjustments block
            let microHtml = '';
            if (micro && micro.length) {
                const total   = micro.reduce((s,m) => s + m.amount, 0);
                const details = micro.map(m =>
                    `${m.description} ${m.amount.toFixed(2).replace('.',',')}`
                ).join(' · ');
                microHtml = `
                <div id="auditMicroBlock"
                  style="padding:13px 20px;border-bottom:1px solid ${border};
                         background:${isDark?'#2a2a2a':'#fffde7'};">
                  <div style="display:flex;justify-content:space-between;
                              align-items:flex-start;gap:10px;margin-bottom:9px;">
                    <div style="flex:1;min-width:0;">
                      <span style="font-size:0.85rem;font-weight:600;color:${txt};">
                        🔧 Micro-ajustes (${micro.length} itens)</span>
                      <div style="font-size:0.73rem;color:${sub};margin-top:3px;
                                  overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                        ${details}</div>
                    </div>
                    <span style="font-size:0.85rem;font-weight:600;white-space:nowrap;">
                      R$ ${Math.abs(total).toFixed(2).replace('.',',')}</span>
                  </div>
                  <div style="display:flex;gap:6px;flex-wrap:wrap;align-items:center;">
                    <select id="microCat" style="${selStyle}">
                      <option value="">Categoria...</option>${catOpts}</select>
                    <select id="microProf" style="${selStyle}">
                      <option value="">Perfil...</option>${profOpts}</select>
                    <select id="microUser" style="${selStyle}">${userOpts}</select>
                    <button onclick="_auditAddMicro()"
                      style="background:#f9ab00;color:#fff;border:none;border-radius:8px;
                             padding:6px 14px;font-size:0.8rem;font-weight:500;cursor:pointer;">
                      + Adicionar</button>
                    <button onclick="document.getElementById('auditMicroBlock').remove()"
                      style="background:none;border:1px solid ${border};border-radius:8px;
                             padding:6px 10px;font-size:0.8rem;cursor:pointer;color:${sub};">
                      Ignorar todos</button>
                  </div>
                </div>`;
            }

            return bulkBar + microHtml + itemsHtml;
        }

        window._auditIgnore = function _auditIgnore(idx) {
            const el = document.getElementById(`unmatch_${idx}`);
            if (el) el.style.display = 'none';
        }

        window._auditBulkCheck = function _auditBulkCheck() {
            const ok = document.getElementById('bulk_cat')?.value &&
                       document.getElementById('bulk_prof')?.value &&
                       document.getElementById('bulk_user')?.value;
            const btn = document.getElementById('auditAddAllBtn');
            if (!btn) return;
            btn.disabled = !ok;
            btn.style.background = ok ? '#1a73e8' : '#ccc';
            btn.style.cursor     = ok ? 'pointer'  : 'not-allowed';
        }

        window._auditAddAll = async function _auditAddAll() {
            const catId  = parseInt(document.getElementById('bulk_cat')?.value);
            const profId = parseInt(document.getElementById('bulk_prof')?.value);
            const userId = parseInt(document.getElementById('bulk_user')?.value);
            if (!catId || !profId || !userId) return;

            // Collect visible (non-ignored) items
            const pending = window._auditData.unmatched
                .map((item, idx) => ({ item, idx }))
                .filter(({ idx }) => {
                    const el = document.getElementById(`unmatch_${idx}`);
                    return el && el.style.display !== 'none';
                });

            if (!pending.length) return;
            if (!confirm(`Adicionar ${pending.length} lançamento(s) com os valores selecionados?`)) return;

            const btn = document.getElementById('auditAddAllBtn');
            if (btn) { btn.disabled = true; btn.textContent = 'Adicionando...'; btn.style.cursor = 'not-allowed'; }

            let ok = 0, fail = 0;
            for (const { item, idx } of pending) {
                const f      = item.file;
                const isParc = !!(f.parcel_num && f.parcel_total);
                const inst   = isParc ? f.parcel_total : 1;
                const rawAmt = isParc ? f.amount * f.parcel_total : f.amount;
                const total  = Math.abs(rawAmt).toFixed(2);
                const notes  = isParc
                    ? `Importado via auditoria - parcela ${f.parcel_num}/${f.parcel_total}` : 'Importado via auditoria';
                try {
                    const token = localStorage.getItem('token');
                    const res = await fetch(`${API}/expenses`, {
                        method: 'POST',
                        headers: { 'Content-Type':'application/json', 'Authorization':`Bearer ${token}` },
                        body: JSON.stringify({
                            description:      f.description,
                            total_amount:     f.amount < 0 ? -parseFloat(total) : parseFloat(total),
                            category_id:      catId,
                            split_profile_id: profId,
                            paid_by_user_id:  userId,
                            expense_date:     f.date,
                            installments:     inst,
                            payment_method_id: window._auditPmId,
                            notes
                        })
                    });
                    if (!res.ok) throw new Error();
                    const el = document.getElementById(`unmatch_${idx}`);
                    if (el) el.innerHTML = `<div style="padding:6px 0;color:#34a853;font-size:0.83rem;">
                        ✅ ${f.description} — adicionado!</div>`;
                    ok++;
                } catch { fail++; }
            }
            invalidateCache();
            const bar = document.getElementById('auditBulkBar');
            if (bar) bar.innerHTML = `<div style="padding:4px 0;font-size:0.83rem;color:#34a853;font-weight:600;">
                ✅ ${ok} adicionado(s)${fail ? ` · ⚠️ ${fail} erro(s)` : ''}</div>`;
        }

        window._auditAdd = async function _auditAdd(idx) {
            const catId  = parseInt(document.getElementById(`uc_${idx}`)?.value);
            const profId = parseInt(document.getElementById(`up_${idx}`)?.value);
            const userId = parseInt(document.getElementById(`uu_${idx}`)?.value);
            if (!catId)  { alert('Selecione uma categoria'); return; }
            if (!profId) { alert('Selecione um perfil'); return; }
            if (!userId) { alert('Selecione o pagador'); return; }

            const f       = window._auditData.unmatched[idx].file;
            const isParc  = !!(f.parcel_num && f.parcel_total);
            const inst    = isParc ? f.parcel_total : 1;
            // Preserve sign: OFX income entries have negative amount
            const rawAmt  = isParc ? f.amount * f.parcel_total : f.amount;
            const total   = Math.abs(rawAmt).toFixed(2);
            const isIncome = f.amount < 0;
            const notes   = isParc
                ? `Importado via auditoria - parcela ${f.parcel_num}/${f.parcel_total}` : 'Importado via auditoria';
            const expenseDate = f.date;

            try {
                const token = localStorage.getItem('token');
                const res = await fetch(`${API}/expenses`, {
                    method: 'POST',
                    headers: { 'Content-Type':'application/json',
                               'Authorization': `Bearer ${token}` },
                    body: JSON.stringify({
                        description:      f.description,
                        total_amount:     isIncome ? -parseFloat(total) : parseFloat(total),
                        category_id:      catId,
                        split_profile_id: profId,
                        paid_by_user_id:  userId,
                        expense_date:     expenseDate,
                        installments:     inst,
                        payment_method_id: window._auditPmId,
                        notes
                    })
                });
                if (!res.ok) throw new Error((await res.json().catch(()=>({}))).detail || 'Erro');
                const el = document.getElementById(`unmatch_${idx}`);
                if (el) el.innerHTML = `<div style="padding:6px 0;color:#34a853;font-size:0.83rem;">
                    ✅ ${f.description} — adicionado!</div>`;
                invalidateCache();
            } catch(e) { alert(e.message || 'Erro ao adicionar'); }
        }

        window._auditAddMicro = async function _auditAddMicro() {
            const catId  = parseInt(document.getElementById('microCat')?.value);
            const profId = parseInt(document.getElementById('microProf')?.value);
            const userId = parseInt(document.getElementById('microUser')?.value);
            if (!catId)  { alert('Selecione uma categoria'); return; }
            if (!profId) { alert('Selecione um perfil'); return; }

            const micro = window._auditData.micro_adjustments;
            const total = Math.abs(micro.reduce((s,m) => s + m.amount, 0)).toFixed(2);
            const first = micro[0]?.date || new Date().toISOString().slice(0,10);

            try {
                const token = localStorage.getItem('token');
                const res = await fetch(`${API}/expenses`, {
                    method: 'POST',
                    headers: { 'Content-Type':'application/json',
                               'Authorization': `Bearer ${token}` },
                    body: JSON.stringify({
                        description:      `Ajustes de extrato (${micro.length} itens)`,
                        total_amount:     parseFloat(total),
                        category_id:      catId,
                        split_profile_id: profId,
                        paid_by_user_id:  userId,
                        expense_date:     first,
                        installments:     1,
                        payment_method_id: window._auditPmId,
                    })
                });
                if (!res.ok) throw new Error((await res.json().catch(()=>({}))).detail || 'Erro');
                const el = document.getElementById('auditMicroBlock');
                if (el) el.innerHTML = `<div style="padding:6px 0;color:#34a853;font-size:0.83rem;">
                    ✅ Micro-ajustes adicionados!</div>`;
                invalidateCache();
            } catch(e) { alert(e.message || 'Erro'); }
        }

        window.auditReset = function auditReset() {
            window._auditFile = null;
            window._auditPmId = null;
            window._auditData = null;
            openAuditModal();
        }

        console.log('✅ FAB draggable ativado');
    })();
