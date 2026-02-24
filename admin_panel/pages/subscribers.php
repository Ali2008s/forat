<?php
// ═══ Subscriber Management Page ═══
?>

<div class="section-card glass-card">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-users"></i> قائمة المشتركين</h3>
        <div class="section-actions">
            <div class="search-bar">
                <i class="fas fa-search"></i>
                <input type="text" id="subscriberSearch" placeholder="بحث بالاسم أو اسم المستخدم..." oninput="filterSubscribers()">
            </div>
            <select class="form-control" id="subscriberFilter" onchange="filterSubscribers()" style="width:auto;padding:8px 40px 8px 16px">
                <option value="all">الكل</option>
                <option value="active">نشط</option>
                <option value="blocked">محظور</option>
                <option value="expired">منتهي</option>
            </select>
            <button class="btn btn-primary btn-sm" onclick="openSubscriberModal()">
                <i class="fas fa-user-plus"></i> إضافة مشترك
            </button>
        </div>
    </div>

    <div class="table-wrapper">
        <table class="data-table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>اسم العميل</th>
                    <th>اسم المستخدم</th>
                    <th>كلمة المرور</th>
                    <th>السيرفر</th>
                    <th>الحالة</th>
                    <th>تاريخ الانتهاء</th>
                    <th>الإجراءات</th>
                </tr>
            </thead>
            <tbody id="subscribersTableBody">
                <tr>
                    <td colspan="8">
                        <div class="loading-overlay">
                            <div class="spinner">
                                <i class="fas fa-circle-notch fa-spin"></i>
                                <span>جاري تحميل المشتركين...</span>
                            </div>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <div id="subscriberCount" class="mt-10 text-muted" style="font-size:var(--text-xs)"></div>
</div>

<!-- Add/Edit Subscriber Modal -->
<div class="modal-overlay" id="subscriberModal" style="display:none;">
    <div class="modal glass-card">
        <div class="modal-header">
            <h3><i class="fas fa-user text-accent"></i> <span id="subscriberModalTitle">إضافة مشترك جديد</span></h3>
            <button class="modal-close" onclick="closeSubscriberModal()"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="subscriberEditId">
            <div class="form-group">
                <label class="form-label">اسم العميل الحقيقي</label>
                <input type="text" class="form-control" id="subClientName" placeholder="مثال: أحمد محمد">
            </div>
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">اسم المستخدم (Xtream)</label>
                    <input type="text" class="form-control" id="subUsername" placeholder="username" dir="ltr">
                </div>
                <div class="form-group">
                    <label class="form-label">كلمة المرور (Xtream)</label>
                    <input type="text" class="form-control" id="subPassword" placeholder="password" dir="ltr">
                </div>
            </div>
            <div class="grid-2">
                <div class="form-group">
                    <label class="form-label">السيرفر</label>
                    <select class="form-control" id="subServer">
                        <option value="">اختر السيرفر...</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">تاريخ الانتهاء</label>
                    <input type="date" class="form-control" id="subExpiry" dir="ltr">
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">الحالة</label>
                <select class="form-control" id="subStatus">
                    <option value="active">نشط</option>
                    <option value="blocked">محظور</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">ملاحظات (اختياري)</label>
                <textarea class="form-control" id="subNotes" placeholder="أي ملاحظات إضافية..." rows="2"></textarea>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-ghost" onclick="closeSubscriberModal()">إلغاء</button>
            <button class="btn btn-primary" onclick="saveSubscriber()" id="saveSubscriberBtn">
                <i class="fas fa-check"></i> حفظ المشترك
            </button>
        </div>
    </div>
</div>
