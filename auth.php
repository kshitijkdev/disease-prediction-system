<?php
/**
 * auth.php — Authentication Handler (Login, Register, Logout)
 * Disease Prediction System | K J Somaiya School of Engineering
 *
 * Actions (POST):
 *   action=login    → validates credentials, sets cookie, returns JSON
 *   action=register → creates new user, sets cookie, returns JSON
 *   action=logout   → clears cookie, returns JSON
 *   action=check    → checks if cookie session is valid, returns JSON
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once 'db.php';

// ── COOKIE CONFIG ────────────────────────────────────────────────
define('COOKIE_NAME',     'dp_session');
define('COOKIE_DURATION', 60 * 60 * 24 * 7); // 7 days in seconds
define('COOKIE_PATH',     '/');

// ── ROUTER ───────────────────────────────────────────────────────
$action = $_POST['action'] ?? $_GET['action'] ?? '';

match ($action) {
    'login'    => handleLogin(),
    'register' => handleRegister(),
    'logout'   => handleLogout(),
    'check'    => handleCheck(),
    default    => jsonResponse(['success' => false, 'error' => 'Unknown action.'], 400),
};

// ════════════════════════════════════════════════════════════════
//  LOGIN
// ════════════════════════════════════════════════════════════════
function handleLogin(): void {
    $email    = trim($_POST['email']    ?? '');
    $password =      $_POST['password'] ?? '';

    if (!$email || !$password) {
        jsonResponse(['success' => false, 'error' => 'Email and password are required.'], 400);
        return;
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        jsonResponse(['success' => false, 'error' => 'Invalid email format.'], 400);
        return;
    }

    $pdo  = getConnection();
    $stmt = $pdo->prepare('SELECT user_id, full_name, email, password FROM users WHERE email = ?');
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    // Verify password using password_hash/password_verify
    if (!$user || !password_verify($password, $user['password'])) {
        jsonResponse(['success' => false, 'error' => 'Incorrect email or password.'], 401);
        return;
    }

    // Generate a secure session token
    $token = bin2hex(random_bytes(32));

    // Store token in DB
    $pdo->prepare(
        'INSERT INTO sessions (user_id, token, expires_at)
         VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 7 DAY))'
    )->execute([$user['user_id'], $token]);

    // Set cookie
    setCookieSecure($token);

    jsonResponse([
        'success' => true,
        'message' => 'Login successful.',
        'user'    => [
            'name'  => $user['full_name'],
            'email' => $user['email'],
        ],
    ]);
}

// ════════════════════════════════════════════════════════════════
//  REGISTER
// ════════════════════════════════════════════════════════════════
function handleRegister(): void {
    $name     = trim($_POST['name']     ?? '');
    $email    = trim($_POST['email']    ?? '');
    $password =      $_POST['password'] ?? '';

    if (!$name || !$email || !$password) {
        jsonResponse(['success' => false, 'error' => 'All fields are required.'], 400);
        return;
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        jsonResponse(['success' => false, 'error' => 'Invalid email format.'], 400);
        return;
    }

    if (strlen($password) < 8) {
        jsonResponse(['success' => false, 'error' => 'Password must be at least 8 characters.'], 400);
        return;
    }

    $pdo = getConnection();

    // Check if email already exists
    $check = $pdo->prepare('SELECT user_id FROM users WHERE email = ?');
    $check->execute([$email]);
    if ($check->fetch()) {
        jsonResponse(['success' => false, 'error' => 'An account with this email already exists.'], 409);
        return;
    }

    // Hash password and insert user
    $hashed = password_hash($password, PASSWORD_BCRYPT);
    $pdo->prepare(
        'INSERT INTO users (full_name, email, password) VALUES (?, ?, ?)'
    )->execute([$name, $email, $hashed]);

    $userId = $pdo->lastInsertId();

    // Generate session token and set cookie
    $token = bin2hex(random_bytes(32));
    $pdo->prepare(
        'INSERT INTO sessions (user_id, token, expires_at)
         VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 7 DAY))'
    )->execute([$userId, $token]);

    setCookieSecure($token);

    jsonResponse([
        'success' => true,
        'message' => 'Account created successfully.',
        'user'    => ['name' => $name, 'email' => $email],
    ]);
}

// ════════════════════════════════════════════════════════════════
//  LOGOUT
// ════════════════════════════════════════════════════════════════
function handleLogout(): void {
    $token = $_COOKIE[COOKIE_NAME] ?? '';

    if ($token) {
        // Delete session from DB
        $pdo = getConnection();
        $pdo->prepare('DELETE FROM sessions WHERE token = ?')->execute([$token]);
    }

    // Expire the cookie
    setcookie(COOKIE_NAME, '', time() - 3600, COOKIE_PATH);

    jsonResponse(['success' => true, 'message' => 'Logged out successfully.']);
}

// ════════════════════════════════════════════════════════════════
//  CHECK SESSION (called on page load)
// ════════════════════════════════════════════════════════════════
function handleCheck(): void {
    $token = $_COOKIE[COOKIE_NAME] ?? '';

    if (!$token) {
        jsonResponse(['success' => false, 'error' => 'No session cookie found.']);
        return;
    }

    $pdo  = getConnection();
    $stmt = $pdo->prepare(
        'SELECT u.full_name, u.email
         FROM sessions s
         JOIN users u ON s.user_id = u.user_id
         WHERE s.token = ? AND s.expires_at > NOW()'
    );
    $stmt->execute([$token]);
    $user = $stmt->fetch();

    if (!$user) {
        // Cookie exists but session expired or invalid — clear it
        setcookie(COOKIE_NAME, '', time() - 3600, COOKIE_PATH);
        jsonResponse(['success' => false, 'error' => 'Session expired. Please log in again.']);
        return;
    }

    // Refresh cookie expiry
    setCookieSecure($token);

    jsonResponse([
        'success' => true,
        'user'    => ['name' => $user['full_name'], 'email' => $user['email']],
    ]);
}

// ════════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════════
function setCookieSecure(string $token): void {
    setcookie(
        COOKIE_NAME,
        $token,
        [
            'expires'  => time() + COOKIE_DURATION,
            'path'     => COOKIE_PATH,
            'httponly' => true,   // JS cannot read it (XSS protection)
            'samesite' => 'Lax',  // CSRF protection
            // 'secure' => true,  // Uncomment when using HTTPS
        ]
    );
}

function jsonResponse(array $data, int $code = 200): void {
    http_response_code($code);
    echo json_encode($data);
    exit;
}
