<?php
// ═══ Server Management Page ═══
?>

<div class="section-card glass-card">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-server"></i> قائمة السيرفرات</h3>
        <div class="section-actions">
            <button class="btn btn-primary btn-sm" onclick="openServerModal()">
                <i class="fas fa-plus"></i> إضافة سيرفر جديد
            </button>
        </div>
    </div>

    <div class="table-wrapper">
        <table class="data-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>اسم السيرفر</th>
                    <th>رابط الهوست (Host)</th>
                    <th>المنفذ (Port)</th>
                    <th>الحالة</th>
                    <th>تاريخ الإضافة</th>
                    <th>الإجراءات</th>
                </tr>
            </thead>
            <tbody id="serversTableBody">
                <tr>
                    <td colspan="7">
                        <div class="loading-overlay">
                            <div class="spinner">
                                <i class="fas fa-circle-notch fa-spin"></i>
                                <span>جاري تحميل السيرفرات...</span>
                            </div>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Add/Edit Server Modal -->
<div class="modal-overlay" id="serverModal" style="display:none;">
    <div class="modal glass-card">
        <div class="modal-header">
            <h3><i class="fas fa-server text-accent"></i> <span id="serverModalTitle">إضافة سيرفر جديد</span></h3>
            <button class="modal-close" onclick="closeServerModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="serverEditId">
            <div class="form-group">
                <label class="form-label">اسم السيرفر</label>
                <input type="text" class="form-control" id="serverName" placeholder="مثال: السيرفر الرئيسي">
            </div>
            <div class="form-group">
                <label class="form-label">رابط الهوست (Host URL)</label>
                <input type="text" class="form-control" id="serverHost" placeholder="مثال: http://example.com:8080" dir="ltr">
            </div>
            <div class="form-group">
                <label class="form-label">المنفذ (Port) - اختياري</label>
                <input type="text" class="form-control" id="serverPort" placeholder="مثال: 8080" dir="ltr">
            </div>
            <div class="form-group">
                <label class="form-label">الحالة</label>
                <select class="form-control" id="serverStatus">
                    <option value="active">نشط</option>
                    <option value="inactive">غير نشط</option>
                    <option value="maintenance">صيانة</option>
                </select>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-ghost" onclick="closeServerModal()">إلغاء</button>
            <button class="btn btn-primary" onclick="saveServer()" id="saveServerBtn">
                <i class="fas fa-check"></i> حفظ السيرفر
            </button>
        </div>
    </div>
</div>
