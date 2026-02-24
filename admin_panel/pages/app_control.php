<?php
// ═══ App Status Control ═══
?>

<!-- App Status Overview -->
<div class="stats-grid" style="margin-bottom:25px">
    <div class="stat-card glass-card" id="appStatusCard">
        <div class="stat-card-top">
            <div class="stat-icon" style="background:var(--success-bg);color:var(--success)">
                <i class="fas fa-power-off"></i>
            </div>
        </div>
        <div class="stat-number" id="appStatusText" style="font-size:var(--text-xl)">جاري الفحص...</div>
        <div class="stat-label">حالة التطبيق الحالية</div>
    </div>
</div>

<!-- Maintenance Mode -->
<div class="section-card glass-card control-card mb-20">
    <div class="control-info">
        <div class="control-icon" style="background:var(--warning-bg);color:var(--warning)">
            <i class="fas fa-wrench"></i>
        </div>
        <div class="control-text">
            <h4>وضع الصيانة</h4>
            <p>عند التفعيل، سيظهر للمستخدمين شاشة "التطبيق تحت الصيانة" ولن يتمكنوا من استخدام التطبيق مؤقتاً</p>
        </div>
    </div>
    <label class="toggle-switch">
        <input type="checkbox" id="maintenanceToggle" onchange="toggleMaintenance()">
        <span class="toggle-slider"></span>
    </label>
</div>

<!-- App Kill Switch -->
<div class="section-card glass-card control-card mb-20">
    <div class="control-info">
        <div class="control-icon" style="background:var(--danger-bg);color:var(--danger)">
            <i class="fas fa-skull-crossbones"></i>
        </div>
        <div class="control-text">
            <h4>إيقاف التطبيق نهائياً</h4>
            <p>⚠️ تحذير: هذا الخيار سيوقف التطبيق بالكامل عن العمل لجميع المستخدمين. استخدم في الحالات الطارئة فقط!</p>
        </div>
    </div>
    <label class="toggle-switch">
        <input type="checkbox" id="appKillToggle" onchange="toggleAppKill()">
        <span class="toggle-slider"></span>
    </label>
</div>

<!-- Custom Maintenance Message -->
<div class="section-card glass-card">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-comment-alt"></i> رسالة الصيانة المخصصة</h3>
    </div>
    <div class="form-group">
        <label class="form-label">الرسالة التي ستظهر للمستخدمين أثناء الصيانة</label>
        <textarea class="form-control" id="maintenanceMessage" placeholder="نعتذر! التطبيق تحت الصيانة حالياً. سنعود قريباً إن شاء الله." rows="3"></textarea>
    </div>
    <div style="display:flex;justify-content:flex-end;margin-top:10px">
        <button class="btn btn-primary btn-sm" onclick="saveMaintenanceMessage()">
            <i class="fas fa-save"></i> حفظ الرسالة
        </button>
    </div>
</div>
