<?php
require 'db.php';

$pdo = getConnection();

$email = $_POST['email'];
$password = $_POST['password'];

$stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
$stmt->execute([$email]);
$user = $stmt->fetch();

if ($user) {
    if ($user['password'] == $password) {
        header("Location: disease_prediction.html");
        exit;
    } else {
        echo "Wrong password!";
    }
} else {
    echo "User not found!";
}
?>