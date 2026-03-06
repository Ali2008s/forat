<?php
// ═══ OTA Update Center ═══
?>

<!-- Current Update Info -->
<div class="update-current glass-card" id="currentUpdateCard">
    <div class="update-version-badge">
        <span class="ver-label">الإصدار</span>
        <span class="ver-number" id="currentVersion">--</span>
    </div>
    <div class="update-details">
        <div class="update-header">
            <div>
                <h3>الإصدار الحالي للتطبيق</h3>
                <p id="currentUpdateNotes">جاري تحميل بيانات التحديث...</p>
            </div>
            <button class="btn btn-ghost text-danger btn-sm" onclick="cancelUpdate()" title="إلغاء التحديث" id="cancelUpdateBtn" style="display:none">
                <i class="fas fa-trash-alt"></i> حذف التحديث
            </button>
        </div>
        <div class="update-meta">
            <span id="currentUpdateType"><i class="fas fa-info-circle"></i> --</span>
            <span id="currentUpdateDate"><i class="fas fa-calendar"></i> --</span>
        </div>
    </div>
</div>

<!-- Send New Update -->
<div class="section-card glass-card">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-cloud-upload-alt"></i> إرسال تحديث جديد</h3>
    </div>

    <div class="grid-2">
        <div class="form-group">
            <label class="form-label">رقم الإصدار الجديد</label>
            <input type="text" class="form-control" id="updateVersion" placeholder="مثال: 2.1.0" dir="ltr">
        </div>
        <div class="form-group">
            <label class="form-label">نوع التحديث</label>
            <select class="form-control" id="updateType">
                <option value="optional">اختياري (يمكن التخطي)</option>
                <option value="forced">إجباري (يغلق التطبيق حتى التحديث)</option>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label class="form-label">رابط ملف التحديث (APK Link)</label>
        <input type="url" class="form-control" id="updateApkLink" placeholder="https://example.com/app-v2.1.0.apk" dir="ltr">
    </div>

    <div class="form-group">
        <label class="form-label">ملاحظات التحديث (Patch Notes)</label>
        <textarea class="form-control" id="updateNotes" placeholder="ما الجديد في هذا الإصدار؟&#10;- ميزة جديدة 1&#10;- إصلاح خطأ 2&#10;- تحسين الأداء" rows="4"></textarea>
    </div>

    <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:10px">
        <button class="btn btn-ghost" onclick="clearUpdateForm()">
            <i class="fas fa-eraser"></i> مسح الحقول
        </button>
        <button class="btn btn-primary" onclick="pushUpdate()" id="pushUpdateBtn">
            <i class="fas fa-paper-plane"></i> إرسال التحديث
        </button>
    </div>
</div>

<!-- Update History -->
<div class="section-card glass-card mt-20">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-history"></i> سجل التحديثات</h3>
    </div>
    <div id="updateHistory">
        <div class="loading-overlay">
            <div class="spinner">
                <i class="fas fa-circle-notch fa-spin"></i>
                <span>جاري تحميل السجل...</span>
            </div>
        </div>
    </div>
</div>
