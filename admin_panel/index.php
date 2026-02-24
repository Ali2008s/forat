<?php
// ═══════════════════════════════════════════════════════════════
//  ForaTV - Main Router
//  Redirects to login or dashboard based on authentication state
// ═══════════════════════════════════════════════════════════════

require_once 'config.php';

if (isLoggedIn()) {
    // Authenticated → show dashboard
    include 'dashboard.php';
} else {
    // Not authenticated → redirect to login
    header('Location: login.php');
    exit;
}
