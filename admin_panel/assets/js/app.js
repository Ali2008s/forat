/**
 * ═══════════════════════════════════════════════════════════════
 *  ForaTV Admin Panel - Main Application Script
 *  Firebase Firestore Integration + Real-time Listeners
 * ═══════════════════════════════════════════════════════════════
 */

// ─── Firebase Initialization ────────────────────────────────────
let db;
let serversData = [];
let subscribersData = [];

try {
    firebase.initializeApp(FIREBASE_CONFIG);
    db = firebase.firestore();
    updateConnectionStatus(true);
    console.log('✅ Firebase initialized successfully');
} catch (e) {
    console.error('❌ Firebase init failed:', e);
    updateConnectionStatus(false);
}

// ─── Connection Status ──────────────────────────────────────────
function updateConnectionStatus(online) {
    const el = document.getElementById('connectionStatus');
    if (!el) return;
    const dot = el.querySelector('.status-dot');
    const text = el.querySelector('.status-text');
    if (online) {
        dot.className = 'status-dot online';
        text.textContent = 'متصل';
    } else {
        dot.className = 'status-dot offline';
        text.textContent = 'غير متصل';
    }
}

// ─── Toast Notification System ──────────────────────────────────
function showToast(type, title, message) {
    const container = document.getElementById('toastContainer');
    if (!container) return;
    const icons = { success: 'fa-check-circle', error: 'fa-times-circle', warning: 'fa-exclamation-triangle', info: 'fa-info-circle' };
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <i class="fas ${icons[type] || icons.info} toast-icon"></i>
        <div class="toast-content">
            <div class="toast-title">${title}</div>
            <div class="toast-message">${message}</div>
        </div>
        <button class="toast-close" onclick="this.parentElement.remove()"><i class="fas fa-times"></i></button>
    `;
    container.appendChild(toast);
    setTimeout(() => { toast.classList.add('removing'); setTimeout(() => toast.remove(), 400); }, 4000);
}

// ─── Confirm Modal ──────────────────────────────────────────────
let confirmCallback = null;
function showConfirm(title, message, callback) {
    document.getElementById('confirmTitle').textContent = title;
    document.getElementById('confirmMessage').textContent = message;
    document.getElementById('confirmModal').style.display = 'flex';
    confirmCallback = callback;
    document.getElementById('confirmAction').onclick = () => {
        const cb = confirmCallback;
        closeConfirmModal();
        if (cb) cb();
    };
}
function closeConfirmModal() {
    document.getElementById('confirmModal').style.display = 'none';
    confirmCallback = null;
}

// ═══════════════════════════════════════════════════════════════
//  PAGE: HOME (Dashboard)
// ═══════════════════════════════════════════════════════════════

function initHomePage() {
    if (!db) return;
    // Listen to servers
    db.collection('servers').onSnapshot(snap => {
        const count = snap.size;
        animateNumber('statServers', count);
        const el = document.getElementById('serverStatusBadge');
        if (el) el.textContent = count > 0 ? 'متصل' : 'لا يوجد';
        serversData = [];
        snap.forEach(doc => serversData.push({ id: doc.id, ...doc.data() }));
    });
    // Listen to subscribers
    db.collection('subscribers').onSnapshot(snap => {
        let active = 0, blocked = 0, total = snap.size;
        subscribersData = [];
        snap.forEach(doc => {
            const d = doc.data();
            subscribersData.push({ id: doc.id, ...d });
            if (d.status === 'active') active++; else blocked++;
        });
        animateNumber('statSubscribers', total);
        animateNumber('statActive', active);
        animateNumber('statBlocked', blocked);
        const el = document.getElementById('subStatusBadge');
        if (el) el.textContent = `${active} نشط`;
        renderRecentSubscribers();
    });
    // Listen to app config
    db.collection('app_config').doc('app_status').onSnapshot(doc => {
        if (!doc.exists) return;
        const d = doc.data();
        const appEl = document.getElementById('sysAppStatus');
        if (appEl) {
            if (d.app_killed) appEl.innerHTML = '<span class="badge badge-danger"><i class="fas fa-times-circle"></i> متوقف</span>';
            else if (d.maintenance_mode) appEl.innerHTML = '<span class="badge badge-warning"><i class="fas fa-wrench"></i> صيانة</span>';
            else appEl.innerHTML = '<span class="badge badge-success"><i class="fas fa-check-circle"></i> يعمل</span>';
        }
        const maintEl = document.getElementById('sysMaintenanceStatus');
        if (maintEl) maintEl.innerHTML = d.maintenance_mode ? '<span class="badge badge-warning">مفعل</span>' : '<span class="badge badge-success">معطل</span>';
        const notifEl = document.getElementById('sysNotificationBar');
        if (notifEl) notifEl.textContent = d.notification_bar || '--';
    });
    db.collection('app_config').doc('update_info').onSnapshot(doc => {
        if (!doc.exists) return;
        const d = doc.data();
        const verEl = document.getElementById('sysAppVersion');
        if (verEl) verEl.textContent = d.version || '--';
    });
    // Firebase connection confirmed
    const fbEl = document.getElementById('sysFirebaseStatus');
    if (fbEl) fbEl.innerHTML = '<span class="badge badge-success"><i class="fas fa-check-circle"></i> متصل</span>';
}

function renderRecentSubscribers() {
    const tbody = document.getElementById('recentSubscribers');
    if (!tbody) return;
    const recent = [...subscribersData].sort((a, b) => {
        const ta = a.created_at ? (a.created_at.seconds || 0) : 0;
        const tb = b.created_at ? (b.created_at.seconds || 0) : 0;
        return tb - ta;
    }).slice(0, 5);
    if (recent.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5"><div class="empty-state"><div class="empty-state-icon"><i class="fas fa-users"></i></div><h3>لا يوجد مشتركين</h3></div></td></tr>';
        return;
    }
    tbody.innerHTML = recent.map((s, i) => {
        const server = serversData.find(sv => sv.id === s.server_id);
        const statusBadge = s.status === 'active' ? '<span class="badge badge-success">نشط</span>' : '<span class="badge badge-danger">محظور</span>';
        const date = s.created_at ? new Date(s.created_at.seconds * 1000).toLocaleDateString('ar-SA') : '--';
        return `<tr><td>${s.client_name || '--'}</td><td dir="ltr">${s.username || '--'}</td><td>${server ? server.name : '--'}</td><td>${statusBadge}</td><td>${date}</td></tr>`;
    }).join('');
}

function animateNumber(id, target) {
    const el = document.getElementById(id);
    if (!el) return;
    const current = parseInt(el.textContent) || 0;
    if (current === target) return;
    const duration = 600;
    const step = (target - current) / (duration / 16);
    let val = current;
    const timer = setInterval(() => {
        val += step;
        if ((step > 0 && val >= target) || (step < 0 && val <= target)) { val = target; clearInterval(timer); }
        el.textContent = Math.round(val);
    }, 16);
}

// ═══════════════════════════════════════════════════════════════
//  PAGE: SERVERS
// ═══════════════════════════════════════════════════════════════

function initServersPage() {
    if (!db) return;
    db.collection('servers').orderBy('created_at', 'desc').onSnapshot(snap => {
        serversData = [];
        snap.forEach(doc => serversData.push({ id: doc.id, ...doc.data() }));
        renderServersTable();
    });
}

function renderServersTable() {
    const tbody = document.getElementById('serversTableBody');
    if (!tbody) return;
    if (serversData.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7"><div class="empty-state"><div class="empty-state-icon"><i class="fas fa-server"></i></div><h3>لا يوجد سيرفرات</h3><p>اضغط "إضافة سيرفر جديد" للبدء</p></div></td></tr>';
        return;
    }
    tbody.innerHTML = serversData.map((s, i) => {
        const statusMap = { active: '<span class="badge badge-success">نشط</span>', inactive: '<span class="badge badge-danger">غير نشط</span>', maintenance: '<span class="badge badge-warning">صيانة</span>' };
        const date = s.created_at ? new Date(s.created_at.seconds * 1000).toLocaleDateString('ar-SA') : '--';
        return `<tr>
            <td>${i + 1}</td>
            <td><strong>${s.name || '--'}</strong></td>
            <td dir="ltr" style="font-family:monospace;font-size:12px">${s.host || '--'}</td>
            <td dir="ltr">${s.port || '--'}</td>
            <td>${statusMap[s.status] || statusMap.inactive}</td>
            <td>${date}</td>
            <td><div class="table-actions">
                <button class="btn btn-ghost btn-icon btn-sm" onclick="editServer('${s.id}')" title="تعديل"><i class="fas fa-edit"></i></button>
                <button class="btn btn-ghost btn-icon btn-sm text-danger" onclick="deleteServer('${s.id}','${s.name}')" title="حذف"><i class="fas fa-trash"></i></button>
            </div></td>
        </tr>`;
    }).join('');
}

function openServerModal(editId) {
    document.getElementById('serverModal').style.display = 'flex';
    if (!editId) {
        document.getElementById('serverModalTitle').textContent = 'إضافة سيرفر جديد';
        document.getElementById('serverEditId').value = '';
        document.getElementById('serverName').value = '';
        document.getElementById('serverHost').value = '';
        document.getElementById('serverPort').value = '';
        document.getElementById('serverStatus').value = 'active';
    }
}
function closeServerModal() { document.getElementById('serverModal').style.display = 'none'; }

function editServer(id) {
    const s = serversData.find(x => x.id === id);
    if (!s) return;
    openServerModal(id);
    document.getElementById('serverModalTitle').textContent = 'تعديل السيرفر';
    document.getElementById('serverEditId').value = id;
    document.getElementById('serverName').value = s.name || '';
    document.getElementById('serverHost').value = s.host || '';
    document.getElementById('serverPort').value = s.port || '';
    document.getElementById('serverStatus').value = s.status || 'active';
}

async function saveServer() {
    const id = document.getElementById('serverEditId').value;
    const data = {
        name: document.getElementById('serverName').value.trim(),
        host: document.getElementById('serverHost').value.trim(),
        port: document.getElementById('serverPort').value.trim(),
        status: document.getElementById('serverStatus').value,
    };
    if (!data.name || !data.host) { showToast('error', 'خطأ', 'يرجى ملء اسم السيرفر ورابط الهوست'); return; }
    const btn = document.getElementById('saveServerBtn');
    btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> جاري الحفظ...';
    try {
        if (id) { await db.collection('servers').doc(id).update(data); showToast('success', 'تم التحديث', 'تم تعديل السيرفر بنجاح'); }
        else { data.created_at = firebase.firestore.FieldValue.serverTimestamp(); await db.collection('servers').add(data); showToast('success', 'تمت الإضافة', 'تم إضافة السيرفر بنجاح'); }
        closeServerModal();
    } catch (e) { showToast('error', 'خطأ', e.message); }
    btn.disabled = false; btn.innerHTML = '<i class="fas fa-check"></i> حفظ السيرفر';
}

function deleteServer(id, name) {
    showConfirm('حذف السيرفر', `هل أنت متأكد من حذف السيرفر "${name}"؟`, async () => {
        try { await db.collection('servers').doc(id).delete(); showToast('success', 'تم الحذف', 'تم حذف السيرفر بنجاح'); }
        catch (e) { showToast('error', 'خطأ', e.message); }
    });
}

// ═══════════════════════════════════════════════════════════════
//  PAGE: SUBSCRIBERS
// ═══════════════════════════════════════════════════════════════

function initSubscribersPage() {
    if (!db) return;
    db.collection('servers').onSnapshot(snap => {
        serversData = [];
        snap.forEach(doc => serversData.push({ id: doc.id, ...doc.data() }));
        populateServerSelect();
    });
    db.collection('subscribers').orderBy('created_at', 'desc').onSnapshot(snap => {
        subscribersData = [];
        snap.forEach(doc => subscribersData.push({ id: doc.id, ...doc.data() }));
        renderSubscribersTable();
    });
}

function populateServerSelect() {
    const sel = document.getElementById('subServer');
    if (!sel) return;
    sel.innerHTML = '<option value="">اختر السيرفر...</option>' + serversData.map(s => `<option value="${s.id}">${s.name}</option>`).join('');
}

function renderSubscribersTable(filtered) {
    const data = filtered || subscribersData;
    const tbody = document.getElementById('subscribersTableBody');
    if (!tbody) return;
    const countEl = document.getElementById('subscriberCount');
    if (countEl) countEl.textContent = `إجمالي: ${data.length} مشترك`;
    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state"><div class="empty-state-icon"><i class="fas fa-users"></i></div><h3>لا يوجد مشتركين</h3></div></td></tr>';
        return;
    }
    tbody.innerHTML = data.map((s, i) => {
        const server = serversData.find(sv => sv.id === s.server_id);
        const statusBadge = s.status === 'active' ? '<span class="badge badge-success">نشط</span>' : '<span class="badge badge-danger">محظور</span>';
        const expiry = s.expiry_date || '--';
        const isExpired = s.expiry_date && new Date(s.expiry_date) < new Date();
        const expiryDisplay = isExpired ? `<span class="text-danger">${expiry} (منتهي)</span>` : expiry;
        const toggleIcon = s.status === 'active' ? 'fa-ban' : 'fa-check-circle';
        const toggleColor = s.status === 'active' ? 'text-warning' : 'text-success';
        const toggleTitle = s.status === 'active' ? 'حظر' : 'تفعيل';
        return `<tr>
            <td>${i + 1}</td>
            <td><strong>${s.client_name || '--'}</strong></td>
            <td dir="ltr" style="font-family:monospace">${s.username || '--'}</td>
            <td dir="ltr" style="font-family:monospace">${s.password || '--'}</td>
            <td>${server ? server.name : '--'}</td>
            <td>${statusBadge}</td>
            <td>${expiryDisplay}</td>
            <td><div class="table-actions">
                <button class="btn btn-ghost btn-icon btn-sm ${toggleColor}" onclick="toggleSubscriber('${s.id}','${s.status}')" title="${toggleTitle}"><i class="fas ${toggleIcon}"></i></button>
                <button class="btn btn-ghost btn-icon btn-sm" onclick="editSubscriber('${s.id}')" title="تعديل"><i class="fas fa-edit"></i></button>
                <button class="btn btn-ghost btn-icon btn-sm text-danger" onclick="deleteSubscriber('${s.id}','${s.client_name}')" title="حذف"><i class="fas fa-trash"></i></button>
            </div></td>
        </tr>`;
    }).join('');
}

function filterSubscribers() {
    const search = (document.getElementById('subscriberSearch')?.value || '').toLowerCase();
    const filter = document.getElementById('subscriberFilter')?.value || 'all';
    let filtered = subscribersData;
    if (search) filtered = filtered.filter(s => (s.client_name || '').toLowerCase().includes(search) || (s.username || '').toLowerCase().includes(search));
    if (filter === 'active') filtered = filtered.filter(s => s.status === 'active');
    else if (filter === 'blocked') filtered = filtered.filter(s => s.status === 'blocked');
    else if (filter === 'expired') filtered = filtered.filter(s => s.expiry_date && new Date(s.expiry_date) < new Date());
    renderSubscribersTable(filtered);
}

function openSubscriberModal() {
    document.getElementById('subscriberModal').style.display = 'flex';
    document.getElementById('subscriberModalTitle').textContent = 'إضافة مشترك جديد';
    document.getElementById('subscriberEditId').value = '';
    ['subClientName', 'subUsername', 'subPassword', 'subExpiry', 'subNotes'].forEach(id => document.getElementById(id).value = '');
    document.getElementById('subServer').value = '';
    document.getElementById('subStatus').value = 'active';
    populateServerSelect();
}
function closeSubscriberModal() { document.getElementById('subscriberModal').style.display = 'none'; }

function editSubscriber(id) {
    const s = subscribersData.find(x => x.id === id);
    if (!s) return;
    document.getElementById('subscriberModal').style.display = 'flex';
    document.getElementById('subscriberModalTitle').textContent = 'تعديل المشترك';
    document.getElementById('subscriberEditId').value = id;
    document.getElementById('subClientName').value = s.client_name || '';
    document.getElementById('subUsername').value = s.username || '';
    document.getElementById('subPassword').value = s.password || '';
    document.getElementById('subServer').value = s.server_id || '';
    document.getElementById('subExpiry').value = s.expiry_date || '';
    document.getElementById('subStatus').value = s.status || 'active';
    document.getElementById('subNotes').value = s.notes || '';
    populateServerSelect();
    if (s.server_id) document.getElementById('subServer').value = s.server_id;
}

async function saveSubscriber() {
    const id = document.getElementById('subscriberEditId').value;
    const data = {
        client_name: document.getElementById('subClientName').value.trim(),
        username: document.getElementById('subUsername').value.trim(),
        password: document.getElementById('subPassword').value.trim(),
        server_id: document.getElementById('subServer').value,
        expiry_date: document.getElementById('subExpiry').value,
        status: document.getElementById('subStatus').value,
        notes: document.getElementById('subNotes').value.trim(),
    };
    if (!data.client_name || !data.username || !data.password) { showToast('error', 'خطأ', 'يرجى ملء الاسم واسم المستخدم وكلمة المرور'); return; }
    const btn = document.getElementById('saveSubscriberBtn');
    btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> جاري الحفظ...';
    try {
        if (id) { await db.collection('subscribers').doc(id).update(data); showToast('success', 'تم التحديث', 'تم تعديل بيانات المشترك'); }
        else { data.created_at = firebase.firestore.FieldValue.serverTimestamp(); await db.collection('subscribers').add(data); showToast('success', 'تمت الإضافة', 'تم إضافة المشترك بنجاح'); }
        closeSubscriberModal();
    } catch (e) { showToast('error', 'خطأ', e.message); }
    btn.disabled = false; btn.innerHTML = '<i class="fas fa-check"></i> حفظ المشترك';
}

async function toggleSubscriber(id, currentStatus) {
    const newStatus = currentStatus === 'active' ? 'blocked' : 'active';
    const msg = newStatus === 'blocked' ? 'هل تريد حظر هذا المشترك؟' : 'هل تريد تفعيل هذا المشترك؟';
    showConfirm('تغيير حالة المشترك', msg, async () => {
        try { await db.collection('subscribers').doc(id).update({ status: newStatus }); showToast('success', 'تم', newStatus === 'blocked' ? 'تم حظر المشترك' : 'تم تفعيل المشترك'); }
        catch (e) { showToast('error', 'خطأ', e.message); }
    });
}

function deleteSubscriber(id, name) {
    showConfirm('حذف المشترك', `هل أنت متأكد من حذف المشترك "${name}"؟`, async () => {
        try { await db.collection('subscribers').doc(id).delete(); showToast('success', 'تم الحذف', 'تم حذف المشترك'); }
        catch (e) { showToast('error', 'خطأ', e.message); }
    });
}

// ═══════════════════════════════════════════════════════════════
//  PAGE: UPDATES
// ═══════════════════════════════════════════════════════════════

function initUpdatesPage() {
    if (!db) return;
    db.collection('app_config').doc('update_info').onSnapshot(doc => {
        if (!doc.exists) { setDefaultUpdateUI(); return; }
        const d = doc.data();
        const verEl = document.getElementById('currentVersion');
        if (verEl) verEl.textContent = d.version || '--';
        const notesEl = document.getElementById('currentUpdateNotes');
        if (notesEl) notesEl.textContent = d.notes || 'لا توجد ملاحظات';
        const typeEl = document.getElementById('currentUpdateType');
        if (typeEl) typeEl.innerHTML = d.force_update ? '<i class="fas fa-lock"></i> إجباري' : '<i class="fas fa-unlock"></i> اختياري';
        const dateEl = document.getElementById('currentUpdateDate');
        if (dateEl && d.updated_at) dateEl.innerHTML = '<i class="fas fa-calendar"></i> ' + new Date(d.updated_at.seconds * 1000).toLocaleDateString('ar-SA');
    });
    // Load update history
    db.collection('update_history').orderBy('pushed_at', 'desc').limit(10).onSnapshot(snap => {
        const container = document.getElementById('updateHistory');
        if (!container) return;
        if (snap.empty) { container.innerHTML = '<div class="empty-state"><div class="empty-state-icon"><i class="fas fa-history"></i></div><h3>لا يوجد سجل تحديثات</h3></div>'; return; }
        container.innerHTML = '';
        snap.forEach(doc => {
            const d = doc.data();
            const date = d.pushed_at ? new Date(d.pushed_at.seconds * 1000).toLocaleDateString('ar-SA') : '--';
            const typeLabel = d.force_update ? '<span class="badge badge-danger">إجباري</span>' : '<span class="badge badge-info">اختياري</span>';
            container.innerHTML += `<div class="info-row"><span class="info-label"><i class="fas fa-code-branch"></i> v${d.version || '--'} ${typeLabel}</span><span class="info-value">${date}</span></div>`;
        });
    });
}

function setDefaultUpdateUI() {
    const el = document.getElementById('currentVersion'); if (el) el.textContent = '--';
    const n = document.getElementById('currentUpdateNotes'); if (n) n.textContent = 'لم يتم إرسال أي تحديث بعد';
}

async function pushUpdate() {
    const version = document.getElementById('updateVersion').value.trim();
    const apk = document.getElementById('updateApkLink').value.trim();
    const notes = document.getElementById('updateNotes').value.trim();
    const type = document.getElementById('updateType').value;
    if (!version) { showToast('error', 'خطأ', 'يرجى إدخال رقم الإصدار'); return; }
    if (!apk) { showToast('error', 'خطأ', 'يرجى إدخال رابط ملف التحديث'); return; }
    const btn = document.getElementById('pushUpdateBtn');
    btn.disabled = true; btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> جاري الإرسال...';
    try {
        const data = { version, apk_link: apk, notes, force_update: type === 'forced', updated_at: firebase.firestore.FieldValue.serverTimestamp() };
        await db.collection('app_config').doc('update_info').set(data, { merge: true });
        await db.collection('update_history').add({ ...data, pushed_at: firebase.firestore.FieldValue.serverTimestamp() });
        showToast('success', 'تم الإرسال', `تم إرسال التحديث v${version} بنجاح`);
        clearUpdateForm();
    } catch (e) { showToast('error', 'خطأ', e.message); }
    btn.disabled = false; btn.innerHTML = '<i class="fas fa-paper-plane"></i> إرسال التحديث';
}

function clearUpdateForm() {
    ['updateVersion', 'updateApkLink', 'updateNotes'].forEach(id => document.getElementById(id).value = '');
    document.getElementById('updateType').value = 'optional';
}

// ═══════════════════════════════════════════════════════════════
//  PAGE: APP CONTROL
// ═══════════════════════════════════════════════════════════════

function initAppControlPage() {
    if (!db) return;
    db.collection('app_config').doc('app_status').onSnapshot(doc => {
        const d = doc.exists ? doc.data() : {};
        const maintToggle = document.getElementById('maintenanceToggle');
        const killToggle = document.getElementById('appKillToggle');
        const msgEl = document.getElementById('maintenanceMessage');
        const statusText = document.getElementById('appStatusText');
        const statusCard = document.getElementById('appStatusCard');

        if (maintToggle) maintToggle.checked = d.maintenance_mode || false;
        if (killToggle) killToggle.checked = d.app_killed || false;
        if (msgEl) msgEl.value = d.maintenance_message || '';

        if (statusText && statusCard) {
            const icon = statusCard.querySelector('.stat-icon');
            if (d.app_killed) {
                statusText.textContent = 'متوقف عن العمل';
                statusText.style.color = 'var(--danger)';
                if (icon) { icon.style.background = 'var(--danger-bg)'; icon.style.color = 'var(--danger)'; }
            } else if (d.maintenance_mode) {
                statusText.textContent = 'تحت الصيانة';
                statusText.style.color = 'var(--warning)';
                if (icon) { icon.style.background = 'var(--warning-bg)'; icon.style.color = 'var(--warning)'; }
            } else {
                statusText.textContent = 'يعمل بشكل طبيعي';
                statusText.style.color = 'var(--success)';
                if (icon) { icon.style.background = 'var(--success-bg)'; icon.style.color = 'var(--success)'; }
            }
        }
    });
}

async function toggleMaintenance() {
    const checked = document.getElementById('maintenanceToggle').checked;
    try {
        await db.collection('app_config').doc('app_status').set({ maintenance_mode: checked }, { merge: true });
        showToast(checked ? 'warning' : 'success', checked ? 'وضع الصيانة' : 'تم الإلغاء', checked ? 'تم تفعيل وضع الصيانة' : 'تم إلغاء وضع الصيانة');
    } catch (e) { showToast('error', 'خطأ', e.message); }
}

async function toggleAppKill() {
    const checked = document.getElementById('appKillToggle').checked;
    if (checked) {
        // Revert the toggle visually immediately. If confirmed, the Firestore listener will check it again.
        document.getElementById('appKillToggle').checked = false;
        showConfirm('⚠️ تحذير خطير', 'هل أنت متأكد من إيقاف التطبيق نهائياً لجميع المستخدمين؟', async () => {
            try {
                await db.collection('app_config').doc('app_status').set({ app_killed: true }, { merge: true });
                showToast('error', 'تم الإيقاف', 'تم إيقاف التطبيق نهائياً');
            } catch (e) { showToast('error', 'خطأ', e.message); }
        });
    } else {
        try {
            await db.collection('app_config').doc('app_status').set({ app_killed: false }, { merge: true });
            showToast('success', 'تم التشغيل', 'تم إعادة تشغيل التطبيق');
        } catch (e) { showToast('error', 'خطأ', e.message); }
    }
}

async function saveMaintenanceMessage() {
    const msg = document.getElementById('maintenanceMessage').value.trim();
    try {
        await db.collection('app_config').doc('app_status').set({ maintenance_message: msg }, { merge: true });
        showToast('success', 'تم الحفظ', 'تم حفظ رسالة الصيانة');
    } catch (e) { showToast('error', 'خطأ', e.message); }
}

// ═══════════════════════════════════════════════════════════════
//  PAGE: SETTINGS
// ═══════════════════════════════════════════════════════════════

function initSettingsPage() {
    if (!db) return;
    db.collection('app_config').doc('settings').onSnapshot(doc => {
        if (!doc.exists) return;
        const d = doc.data();
        const notifEl = document.getElementById('notificationBar');
        const notifEnabled = document.getElementById('notificationEnabled');
        const teleEl = document.getElementById('telegramLink');
        const waEl = document.getElementById('whatsappLink');
        const appName = document.getElementById('appNameSetting');
        const appDesc = document.getElementById('appDescSetting');
        if (notifEl) notifEl.value = d.notification_bar || '';
        if (notifEnabled) notifEnabled.checked = d.notification_enabled || false;
        if (teleEl) teleEl.value = d.telegram_link || '';
        if (waEl) waEl.value = d.whatsapp_link || '';
        if (appName) appName.value = d.app_name || '';
        if (appDesc) appDesc.value = d.app_description || '';
    });
}

async function saveNotificationBar() {
    try {
        await db.collection('app_config').doc('settings').set({
            notification_bar: document.getElementById('notificationBar').value.trim(),
            notification_enabled: document.getElementById('notificationEnabled').checked,
        }, { merge: true });
        // Also update in app_status for dashboard view
        await db.collection('app_config').doc('app_status').set({
            notification_bar: document.getElementById('notificationBar').value.trim(),
        }, { merge: true });
        showToast('success', 'تم الحفظ', 'تم تحديث شريط الإشعارات');
    } catch (e) { showToast('error', 'خطأ', e.message); }
}

async function saveSupportLinks() {
    try {
        await db.collection('app_config').doc('settings').set({
            telegram_link: document.getElementById('telegramLink').value.trim(),
            whatsapp_link: document.getElementById('whatsappLink').value.trim(),
        }, { merge: true });
        showToast('success', 'تم الحفظ', 'تم تحديث روابط الدعم');
    } catch (e) { showToast('error', 'خطأ', e.message); }
}

async function saveAppInfo() {
    try {
        await db.collection('app_config').doc('settings').set({
            app_name: document.getElementById('appNameSetting').value.trim(),
            app_description: document.getElementById('appDescSetting').value.trim(),
        }, { merge: true });
        showToast('success', 'تم الحفظ', 'تم تحديث معلومات التطبيق');
    } catch (e) { showToast('error', 'خطأ', e.message); }
}

// ═══════════════════════════════════════════════════════════════
//  INITIALIZATION - Route to correct page initializer
// ═══════════════════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', () => {
    const pageInitializers = {
        home: initHomePage,
        servers: initServersPage,
        subscribers: initSubscribersPage,
        updates: initUpdatesPage,
        app_control: initAppControlPage,
        settings: initSettingsPage,
    };
    const init = pageInitializers[ACTIVE_PAGE];
    if (init) init();
});
