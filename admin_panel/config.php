<?php
// ═══════════════════════════════════════════════════════════════
//  ForaTV - Advanced Admin Panel Configuration
//  Version: 2.0.0 | Firebase Cloud Integration
// ═══════════════════════════════════════════════════════════════

session_start();

// ─── Admin Credentials ─────────────────────────────────────────
define('ADMIN_USERNAME', 'admin');
define('ADMIN_PASSWORD', 'Fora@2026');

// ─── App Info ───────────────────────────────────────────────────
define('APP_NAME', 'ForaTV');
define('PANEL_VERSION', '2.0.0');
define('PANEL_TITLE', 'ForaTV Control Panel');

// ─── Firebase Configuration (passed to JavaScript SDK) ─────────
$firebaseConfig = [
    'apiKey'            => 'AIzaSyCATn7lwg2x5kxEkfrGpW4UbRlc7KpHEDg',
    'authDomain'        => 'upload-92830.firebaseapp.com',
    'projectId'         => 'upload-92830',
    'storageBucket'     => 'upload-92830.appspot.com',
    'messagingSenderId' => '100060804942',
    'appId'             => '1:100060804942:web:3b7e88d9261d4cb6a4901f',
    'measurementId'     => 'G-1ZGTVPHKL1',
];

// ─── Firestore Collections ─────────────────────────────────────
define('COL_SERVERS',     'servers');
define('COL_SUBSCRIBERS', 'subscribers');
define('COL_CONFIG',      'app_config');
define('DOC_APP_STATUS',  'app_status');
define('DOC_UPDATE_INFO', 'update_info');
define('DOC_SETTINGS',    'settings');

// ─── Helper Functions ───────────────────────────────────────────

/**
 * Check if admin is currently logged in
 */
function isLoggedIn(): bool {
    return isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true;
}

/**
 * Require authentication - redirect to login if not authenticated
 */
function requireAuth(): void {
    if (!isLoggedIn()) {
        header('Location: login.php');
        exit;
    }
}

/**
 * Get the current active page from URL parameter
 */
function getActivePage(): string {
    $page = $_GET['page'] ?? 'home';
    $allowed = ['home', 'servers', 'subscribers', 'updates', 'app_control', 'settings'];
    return in_array($page, $allowed) ? $page : 'home';
}

/**
 * Check if given page is the active page (for sidebar highlighting)
 */
function isActive(string $page): string {
    return getActivePage() === $page ? 'active' : '';
}

/**
 * Get Firebase config as JSON for JavaScript
 */
function getFirebaseConfigJSON(): string {
    global $firebaseConfig;
    return json_encode($firebaseConfig);
}

/**
 * Sanitize output for HTML
 */
function e(string $str): string {
    return htmlspecialchars($str, ENT_QUOTES, 'UTF-8');
}

/**
 * Get sidebar navigation items
 */
function getNavItems(): array {
    return [
        ['page' => 'home',        'icon' => 'fas fa-chart-pie',      'label' => 'لوحة الإحصائيات'],
        ['page' => 'servers',     'icon' => 'fas fa-server',         'label' => 'إدارة السيرفرات'],
        ['page' => 'subscribers', 'icon' => 'fas fa-users',          'label' => 'إدارة المشتركين'],
        ['page' => 'updates',     'icon' => 'fas fa-cloud-upload-alt','label' => 'مركز التحديثات'],
        ['page' => 'app_control', 'icon' => 'fas fa-sliders-h',     'label' => 'حالة التطبيق'],
        ['page' => 'settings',   'icon' => 'fas fa-cog',            'label' => 'الإعدادات'],
    ];
}
