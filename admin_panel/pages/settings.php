<?php
// ═══ Admin Settings ═══
?>

<!-- Notification Bar -->
<div class="section-card glass-card mb-20">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-bell"></i> شريط التنبيهات</h3>
    </div>
    <p class="text-muted mb-10" style="font-size:var(--text-sm)">هذا النص سيظهر فوراً كشريط إشعارات داخل التطبيق لجميع المستخدمين</p>
    <div class="form-group">
        <label class="form-label">نص الإشعار</label>
        <input type="text" class="form-control" id="notificationBar" placeholder="مثال: عروض خاصة! اشترك الآن واحصل على خصم 50%">
    </div>
    <div class="form-group">
        <label class="form-label">تفعيل شريط الإشعارات</label>
        <label class="toggle-switch">
            <input type="checkbox" id="notificationEnabled">
            <span class="toggle-slider"></span>
        </label>
    </div>
    <div style="display:flex;justify-content:flex-end">
        <button class="btn btn-primary btn-sm" onclick="saveNotificationBar()">
            <i class="fas fa-save"></i> حفظ الإشعار
        </button>
    </div>
</div>

<!-- Support Links -->
<div class="section-card glass-card mb-20">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-headset"></i> روابط الدعم الفني</h3>
    </div>
    <div class="grid-2">
        <div class="form-group">
            <label class="form-label"><i class="fab fa-telegram" style="color:#0088cc"></i> رابط التيليجرام</label>
            <input type="url" class="form-control" id="telegramLink" placeholder="https://t.me/your_channel" dir="ltr">
        </div>
        <div class="form-group">
            <label class="form-label"><i class="fab fa-whatsapp" style="color:#25d366"></i> رابط الواتساب</label>
            <input type="url" class="form-control" id="whatsappLink" placeholder="https://wa.me/966500000000" dir="ltr">
        </div>
    </div>
    <div style="display:flex;justify-content:flex-end">
        <button class="btn btn-primary btn-sm" onclick="saveSupportLinks()">
            <i class="fas fa-save"></i> حفظ الروابط
        </button>
    </div>
</div>

<!-- App Information -->
<div class="section-card glass-card mb-20">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-info-circle"></i> معلومات التطبيق</h3>
    </div>
    <div class="grid-2">
        <div class="form-group">
            <label class="form-label">اسم التطبيق</label>
            <input type="text" class="form-control" id="appNameSetting" placeholder="ForaTV">
        </div>
        <div class="form-group">
            <label class="form-label">وصف التطبيق</label>
            <input type="text" class="form-control" id="appDescSetting" placeholder="أفضل مشغل IPTV">
        </div>
    </div>
    <div style="display:flex;justify-content:flex-end">
        <button class="btn btn-primary btn-sm" onclick="saveAppInfo()">
            <i class="fas fa-save"></i> حفظ المعلومات
        </button>
    </div>
</div>

<!-- Change Admin Password -->
<div class="section-card glass-card">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-key"></i> تغيير كلمة المرور</h3>
    </div>
    <div class="form-group">
        <label class="form-label">كلمة المرور الحالية</label>
        <input type="password" class="form-control" id="currentPassword" placeholder="أدخل كلمة المرور الحالية">
    </div>
    <div class="grid-2">
        <div class="form-group">
            <label class="form-label">كلمة المرور الجديدة</label>
            <input type="password" class="form-control" id="newPassword" placeholder="كلمة مرور جديدة">
        </div>
        <div class="form-group">
            <label class="form-label">تأكيد كلمة المرور</label>
            <input type="password" class="form-control" id="confirmPassword" placeholder="أعد كتابة كلمة المرور">
        </div>
    </div>
    <div class="alert alert-warning" style="margin-top:10px">
        <i class="fas fa-exclamation-triangle"></i>
        <span>يتم حفظ كلمة المرور في ملف config.php على السيرفر</span>
    </div>
</div>
