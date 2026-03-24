<?php
/**
 * get_symptoms.php — Fetch All Symptoms
 * Disease Prediction System | K J Somaiya School of Engineering
 *
 * Method : GET
 * Returns: JSON array of symptoms grouped by category
 *
 * Example response:
 * {
 *   "symptoms": [
 *     { "symptom_id": 1, "symptom_name": "Fever", "category": "General" },
 *     ...
 *   ]
 * }
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once 'db.php';

try {
    $pdo  = getConnection();
    $stmt = $pdo->query(
        'SELECT symptom_id, symptom_name, category
         FROM symptoms
         ORDER BY category, symptom_name'
    );
    $symptoms = $stmt->fetchAll();
    echo json_encode(['symptoms' => $symptoms]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to fetch symptoms: ' . $e->getMessage()]);
}
