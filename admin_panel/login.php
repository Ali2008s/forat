<?php
require_once 'config.php';

// If already logged in, redirect to dashboard
if (isLoggedIn()) {
    header('Location: index.php');
    exit;
}

// Handle login form submission
$error = '';
$shake = false;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';

    if ($username === ADMIN_USERNAME && $password === ADMIN_PASSWORD) {
        $_SESSION['admin_logged_in'] = true;
        $_SESSION['admin_username']  = $username;
        $_SESSION['login_time']      = time();
        header('Location: index.php');
        exit;
    } else {
        $error = 'اسم المستخدم أو كلمة المرور غير صحيحة';
        $shake = true;
    }
}
?>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title><?php echo APP_NAME; ?> - تسجيل الدخول</title>
    <meta name="description" content="لوحة تحكم ForaTV الإحترافية لإدارة نظام IPTV">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body class="login-page">

    <!-- ═══ Animated Background Orbs ═══ -->
    <div class="bg-animation">
        <div class="orb orb-1"></div>
        <div class="orb orb-2"></div>
        <div class="orb orb-3"></div>
        <div class="orb orb-4"></div>
    </div>

    <!-- ═══ Floating Particles ═══ -->
    <div class="particles" id="particles"></div>

    <!-- ═══ Login Container ═══ -->
    <div class="login-container">
        <div class="login-card glass-card <?php echo $shake ? 'shake' : ''; ?>">
            
            <!-- Logo Section -->
            <div class="login-logo">
                <div class="logo-ring">
                    <div class="logo-icon">
                        <i class="fas fa-satellite-dish"></i>
                    </div>
                </div>
                <h1 class="logo-title"><?php echo APP_NAME; ?></h1>
                <p class="login-subtitle">لوحة التحكم الإحترافية</p>
                <div class="title-line"></div>
            </div>

            <!-- Error Alert -->
            <?php if ($error): ?>
            <div class="alert alert-danger fade-in">
                <i class="fas fa-exclamation-triangle"></i>
                <span><?php echo e($error); ?></span>
            </div>
            <?php endif; ?>

            <!-- Login Form -->
            <form method="POST" class="login-form" id="loginForm" autocomplete="off">
                <div class="input-group">
                    <div class="input-icon">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <input 
                        type="text" 
                        name="username" 
                        id="username"
                        placeholder="اسم المستخدم" 
                        value="<?php echo e($_POST['username'] ?? ''); ?>"
                        required 
                        autofocus
                    >
                    <div class="input-line"></div>
                </div>

                <div class="input-group">
                    <div class="input-icon">
                        <i class="fas fa-lock"></i>
                    </div>
                    <input 
                        type="password" 
                        name="password" 
                        id="password"
                        placeholder="كلمة المرور" 
                        required
                    >
                    <button type="button" class="toggle-password" onclick="togglePassword(this)">
                        <i class="fas fa-eye"></i>
                    </button>
                    <div class="input-line"></div>
                </div>

                <button type="submit" class="btn btn-primary btn-login" id="loginBtn">
                    <span class="btn-content">
                        <span class="btn-text">تسجيل الدخول</span>
                        <i class="fas fa-arrow-left btn-arrow"></i>
                    </span>
                    <span class="btn-loader" style="display:none;">
                        <i class="fas fa-circle-notch fa-spin"></i>
                        <span>جاري التحقق...</span>
                    </span>
                </button>
            </form>

            <!-- Footer -->
            <div class="login-footer">
                <div class="footer-badge">
                    <i class="fas fa-shield-alt"></i>
                    <span>نظام محمي بالكامل</span>
                </div>
                <p class="version-text">v<?php echo PANEL_VERSION; ?></p>
            </div>
        </div>
    </div>

    <script>
    // Toggle password visibility
    function togglePassword(btn) {
        const input = btn.parentElement.querySelector('input');
        const icon = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    }

    // Form submit animation
    document.getElementById('loginForm').addEventListener('submit', function() {
        const btn = document.getElementById('loginBtn');
        btn.querySelector('.btn-content').style.display = 'none';
        btn.querySelector('.btn-loader').style.display = 'flex';
        btn.disabled = true;
        btn.classList.add('loading');
    });

    // Create floating particles
    function createParticles() {
        const container = document.getElementById('particles');
        for (let i = 0; i < 30; i++) {
            const particle = document.createElement('div');
            particle.className = 'particle';
            particle.style.left = Math.random() * 100 + '%';
            particle.style.top = Math.random() * 100 + '%';
            particle.style.animationDelay = Math.random() * 6 + 's';
            particle.style.animationDuration = (Math.random() * 3 + 3) + 's';
            particle.style.width = particle.style.height = (Math.random() * 4 + 1) + 'px';
            container.appendChild(particle);
        }
    }
    createParticles();

    // Input focus animation
    document.querySelectorAll('.input-group input').forEach(input => {
        input.addEventListener('focus', () => input.parentElement.classList.add('focused'));
        input.addEventListener('blur', () => {
            if (!input.value) input.parentElement.classList.remove('focused');
        });
    });
    </script>
</body>
</html>
