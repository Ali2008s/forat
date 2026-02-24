<?php
// ═══ Dashboard Home - Smart Statistics ═══
?>

<!-- Stats Cards -->
<div class="stats-grid" id="statsGrid">
    <div class="stat-card glass-card accent">
        <div class="stat-card-top">
            <div class="stat-icon"><i class="fas fa-server"></i></div>
            <span class="badge badge-accent" id="serverStatusBadge">--</span>
        </div>
        <div class="stat-number" id="statServers">0</div>
        <div class="stat-label">السيرفرات النشطة</div>
    </div>

    <div class="stat-card glass-card cyan">
        <div class="stat-card-top">
            <div class="stat-icon"><i class="fas fa-users"></i></div>
            <span class="badge badge-info" id="subStatusBadge">--</span>
        </div>
        <div class="stat-number" id="statSubscribers">0</div>
        <div class="stat-label">إجمالي المشتركين</div>
    </div>

    <div class="stat-card glass-card success">
        <div class="stat-card-top">
            <div class="stat-icon"><i class="fas fa-user-check"></i></div>
        </div>
        <div class="stat-number" id="statActive">0</div>
        <div class="stat-label">المشتركين النشطين</div>
    </div>

    <div class="stat-card glass-card warning">
        <div class="stat-card-top">
            <div class="stat-icon"><i class="fas fa-user-slash"></i></div>
        </div>
        <div class="stat-number" id="statBlocked">0</div>
        <div class="stat-label">المحظورين</div>
    </div>
</div>

<!-- System Status + Quick Actions Row -->
<div class="grid-2">
    <!-- System Status -->
    <div class="section-card glass-card">
        <div class="section-header">
            <h3 class="section-title"><i class="fas fa-heartbeat"></i> حالة النظام</h3>
        </div>
        <div class="info-row">
            <span class="info-label"><i class="fas fa-mobile-alt"></i> حالة التطبيق</span>
            <span class="info-value" id="sysAppStatus">
                <span class="badge badge-success"><i class="fas fa-check-circle"></i> يعمل</span>
            </span>
        </div>
        <div class="info-row">
            <span class="info-label"><i class="fas fa-wrench"></i> وضع الصيانة</span>
            <span class="info-value" id="sysMaintenanceStatus">
                <span class="badge badge-success">معطل</span>
            </span>
        </div>
        <div class="info-row">
            <span class="info-label"><i class="fas fa-code-branch"></i> إصدار التطبيق</span>
            <span class="info-value" id="sysAppVersion">--</span>
        </div>
        <div class="info-row">
            <span class="info-label"><i class="fas fa-cloud"></i> اتصال Firebase</span>
            <span class="info-value" id="sysFirebaseStatus">
                <span class="badge badge-warning"><i class="fas fa-spinner fa-spin"></i> جاري الفحص</span>
            </span>
        </div>
        <div class="info-row">
            <span class="info-label"><i class="fas fa-bell"></i> شريط الإشعارات</span>
            <span class="info-value" id="sysNotificationBar" style="max-width:200px;text-align:left;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">--</span>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="section-card glass-card">
        <div class="section-header">
            <h3 class="section-title"><i class="fas fa-bolt"></i> إجراءات سريعة</h3>
        </div>
        <div class="quick-actions">
            <a href="?page=servers" class="quick-action-card glass-card">
                <div class="quick-action-icon" style="background:rgba(99,102,241,0.15);color:var(--accent-primary)">
                    <i class="fas fa-plus"></i>
                </div>
                <span class="quick-action-text">إضافة سيرفر</span>
            </a>
            <a href="?page=subscribers" class="quick-action-card glass-card">
                <div class="quick-action-icon" style="background:rgba(6,182,212,0.15);color:var(--cyan)">
                    <i class="fas fa-user-plus"></i>
                </div>
                <span class="quick-action-text">إضافة مشترك</span>
            </a>
            <a href="?page=updates" class="quick-action-card glass-card">
                <div class="quick-action-icon" style="background:var(--success-bg);color:var(--success)">
                    <i class="fas fa-cloud-upload-alt"></i>
                </div>
                <span class="quick-action-text">إرسال تحديث</span>
            </a>
            <a href="?page=app_control" class="quick-action-card glass-card">
                <div class="quick-action-icon" style="background:var(--warning-bg);color:var(--warning)">
                    <i class="fas fa-power-off"></i>
                </div>
                <span class="quick-action-text">التحكم بالتطبيق</span>
            </a>
        </div>
    </div>
</div>

<!-- Recent Subscribers -->
<div class="section-card glass-card mt-20">
    <div class="section-header">
        <h3 class="section-title"><i class="fas fa-clock"></i> آخر المشتركين المضافين</h3>
        <a href="?page=subscribers" class="btn btn-ghost btn-sm">
            <i class="fas fa-arrow-left"></i> عرض الكل
        </a>
    </div>
    <div class="table-wrapper">
        <table class="data-table">
            <thead>
                <tr>
                    <th>اسم العميل</th>
                    <th>اسم المستخدم</th>
                    <th>السيرفر</th>
                    <th>الحالة</th>
                    <th>تاريخ الإضافة</th>
                </tr>
            </thead>
            <tbody id="recentSubscribers">
                <tr>
                    <td colspan="5">
                        <div class="loading-overlay">
                            <div class="spinner">
                                <i class="fas fa-circle-notch fa-spin"></i>
                                <span>جاري التحميل...</span>
                            </div>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
