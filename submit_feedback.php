<?php
$conn = new mysqli("localhost", "root", "", "disease_predictor");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$name = $_POST['name'];
$email = $_POST['email'];
$rating = $_POST['rating'];
$message = $_POST['message'];

$sql = "INSERT INTO feedback (name, email, rating, message)
        VALUES ('$name', '$email', '$rating', '$message')";

if ($conn->query($sql) === TRUE) {
    echo "Feedback submitted successfully!";
} else {
    echo "Error: " . $conn->error;
}

$conn->close();
?>