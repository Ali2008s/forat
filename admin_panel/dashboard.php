<?php
// ═══════════════════════════════════════════════════════════════
//  ForaTV - Main Dashboard Layout
//  Requires authentication - includes sidebar, topbar, and content
// ═══════════════════════════════════════════════════════════════

require_once 'config.php';
requireAuth();

$activePage = getActivePage();
$navItems = getNavItems();
?>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title><?php echo APP_NAME; ?> - لوحة التحكم</title>
    <meta name="description" content="لوحة تحكم ForaTV الإحترافية لإدارة نظام IPTV">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body class="dashboard-page">

    <!-- ═══ Background Animation ═══ -->
    <div class="bg-animation">
        <div class="orb orb-1"></div>
        <div class="orb orb-2"></div>
    </div>

    <!-- ═══ Sidebar Overlay (Mobile) ═══ -->
    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

    <!-- ═══ Sidebar ═══ -->
    <aside class="sidebar" id="sidebar">
        <!-- Sidebar Header / Logo -->
        <div class="sidebar-header">
            <div class="sidebar-logo">
                <div class="sidebar-logo-icon">
                    <i class="fas fa-satellite-dish"></i>
                </div>
                <div class="sidebar-logo-text">
                    <h2><?php echo APP_NAME; ?></h2>
                    <span class="sidebar-badge">Control Panel</span>
                </div>
            </div>
            <button class="sidebar-close" id="sidebarClose" onclick="toggleSidebar()">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <!-- Navigation Links -->
        <nav class="sidebar-nav">
            <div class="nav-section-title">القائمة الرئيسية</div>
            <?php foreach ($navItems as $item): ?>
            <a href="?page=<?php echo $item['page']; ?>" 
               class="nav-link <?php echo isActive($item['page']); ?>"
               id="nav-<?php echo $item['page']; ?>">
                <div class="nav-link-icon">
                    <i class="<?php echo $item['icon']; ?>"></i>
                </div>
                <span class="nav-link-text"><?php echo $item['label']; ?></span>
                <?php if (isActive($item['page'])): ?>
                <div class="nav-active-indicator"></div>
                <?php endif; ?>
            </a>
            <?php endforeach; ?>
        </nav>

        <!-- Sidebar Footer -->
        <div class="sidebar-footer">
            <div class="admin-info-card glass-card-mini">
                <div class="admin-avatar">
                    <i class="fas fa-user-crown"></i>
                </div>
                <div class="admin-details">
                    <span class="admin-name"><?php echo e($_SESSION['admin_username'] ?? 'Admin'); ?></span>
                    <span class="admin-role">مدير النظام</span>
                </div>
            </div>
            <a href="logout.php" class="btn-logout" id="logoutBtn">
                <i class="fas fa-sign-out-alt"></i>
                <span>تسجيل الخروج</span>
            </a>
        </div>
    </aside>

    <!-- ═══ Main Content Area ═══ -->
    <main class="main-content" id="mainContent">
        
        <!-- Top Bar -->
        <header class="topbar glass-card-mini">
            <div class="topbar-right">
                <button class="menu-toggle" id="menuToggle" onclick="toggleSidebar()">
                    <i class="fas fa-bars"></i>
                </button>
                <div class="page-title-area">
                    <?php
                    $pageTitles = [
                        'home'        => ['icon' => 'fas fa-chart-pie',       'title' => 'لوحة الإحصائيات'],
                        'servers'     => ['icon' => 'fas fa-server',          'title' => 'إدارة السيرفرات'],
                        'subscribers' => ['icon' => 'fas fa-users',           'title' => 'إدارة المشتركين'],
                        'updates'     => ['icon' => 'fas fa-cloud-upload-alt','title' => 'مركز التحديثات'],
                        'app_control' => ['icon' => 'fas fa-sliders-h',      'title' => 'حالة التطبيق'],
                        'settings'    => ['icon' => 'fas fa-cog',            'title' => 'الإعدادات'],
                    ];
                    $pt = $pageTitles[$activePage] ?? $pageTitles['home'];
                    ?>
                    <i class="<?php echo $pt['icon']; ?> page-title-icon"></i>
                    <h1 class="page-title"><?php echo $pt['title']; ?></h1>
                </div>
            </div>
            <div class="topbar-left">
                <!-- Connection Status -->
                <div class="connection-status" id="connectionStatus">
                    <div class="status-dot offline"></div>
                    <span class="status-text">غير متصل</span>
                </div>
                <!-- Current Time -->
                <div class="topbar-time" id="topbarTime">
                    <i class="fas fa-clock"></i>
                    <span></span>
                </div>
            </div>
        </header>

        <!-- Page Content -->
        <div class="content-area" id="contentArea">
            <?php
            $pageFile = __DIR__ . '/pages/' . $activePage . '.php';
            if (file_exists($pageFile)) {
                include $pageFile;
            } else {
                echo '<div class="glass-card text-center"><h2>الصفحة غير موجودة</h2></div>';
            }
            ?>
        </div>
    </main>

    <!-- ═══ Toast Notification Container ═══ -->
    <div class="toast-container" id="toastContainer"></div>

    <!-- ═══ Confirm Modal ═══ -->
    <div class="modal-overlay" id="confirmModal" style="display:none;">
        <div class="modal glass-card modal-sm">
            <div class="modal-header">
                <h3 id="confirmTitle">تأكيد العملية</h3>
            </div>
            <div class="modal-body">
                <p id="confirmMessage">هل أنت متأكد من هذا الإجراء؟</p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-ghost" onclick="closeConfirmModal()">إلغاء</button>
                <button class="btn btn-danger" id="confirmAction">تأكيد</button>
            </div>
        </div>
    </div>

    <!-- ═══ Firebase SDK ═══ -->
    <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>

    <!-- Firebase Config Initialization -->
    <script>
        const FIREBASE_CONFIG = <?php echo getFirebaseConfigJSON(); ?>;
        const ACTIVE_PAGE = '<?php echo $activePage; ?>';
    </script>

    <!-- Main Application Script -->
    <script src="assets/js/app.js"></script>

    <!-- Sidebar Toggle Script -->
    <script>
    function toggleSidebar() {
        document.getElementById('sidebar').classList.toggle('open');
        document.getElementById('sidebarOverlay').classList.toggle('active');
        document.body.classList.toggle('sidebar-open');
    }

    // Update clock
    function updateClock() {
        const now = new Date();
        const time = now.toLocaleTimeString('ar-SA', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
        const el = document.querySelector('#topbarTime span');
        if (el) el.textContent = time;
    }
    setInterval(updateClock, 1000);
    updateClock();
    </script>
</body>
</html>
