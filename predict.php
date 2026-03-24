<?php
/**
 * predict.php — Disease Prediction Engine
 * Disease Prediction System | K J Somaiya School of Engineering
 *
 * Method : POST
 * Body   : symptoms[] — array of symptom IDs (integers)
 * Returns: JSON array of ranked diseases with match percentage
 *
 * Example request (form POST):
 *   symptoms[]=1&symptoms[]=5&symptoms[]=12
 *
 * Example response:
 * {
 *   "results": [
 *     {
 *       "disease_id": 2,
 *       "disease_name": "Influenza (Flu)",
 *       "description": "...",
 *       "recommendation": "...",
 *       "severity_level": "Medium",
 *       "match_count": 4,
 *       "total_symptoms": 10,
 *       "match_pct": 40.0
 *     },
 *     ...
 *   ]
 * }
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');

require_once 'db.php';

// ── Only accept POST ──────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'POST method required.']);
    exit;
}

// ── Validate input ────────────────────────────────────────────────
$rawIds = $_POST['symptoms'] ?? [];

if (!is_array($rawIds) || empty($rawIds)) {
    http_response_code(400);
    echo json_encode(['error' => 'No symptoms provided. Send symptoms[] via POST.']);
    exit;
}

// Sanitise: keep only positive integers
$symptomIds = array_values(array_filter(
    array_map('intval', $rawIds),
    fn($id) => $id > 0
));

if (empty($symptomIds)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid symptom IDs.']);
    exit;
}

// ── Minimum match threshold (25%) ─────────────────────────────────
define('MATCH_THRESHOLD', 25.0);

// ── Prediction query ──────────────────────────────────────────────
/*
   For each disease:
   - Count how many of the submitted symptom IDs appear in symptoms_diseases
   - Divide by the total number of symptoms that disease has
   - Multiply by 100 to get a percentage
   - Filter out diseases below the threshold
   - Sort best match first
   - Return top 6
*/
try {
    $pdo          = getConnection();
    $placeholders = implode(',', array_fill(0, count($symptomIds), '?'));

    $sql = "
        SELECT
            d.disease_id,
            d.disease_name,
            d.description,
            d.recommendation,
            d.severity_level,
            COUNT(sd.symptom_id) AS match_count,
            (
                SELECT COUNT(*)
                FROM symptoms_diseases
                WHERE disease_id = d.disease_id
            ) AS total_symptoms,
            ROUND(
                COUNT(sd.symptom_id) * 100.0
                / (
                    SELECT COUNT(*)
                    FROM symptoms_diseases
                    WHERE disease_id = d.disease_id
                ),
                1
            ) AS match_pct
        FROM diseases d
        JOIN symptoms_diseases sd
            ON d.disease_id = sd.disease_id
        WHERE sd.symptom_id IN ($placeholders)
        GROUP BY
            d.disease_id,
            d.disease_name,
            d.description,
            d.recommendation,
            d.severity_level
        HAVING match_pct >= ?
        ORDER BY match_pct DESC
        LIMIT 6
    ";

    $params = array_merge($symptomIds, [MATCH_THRESHOLD]);
    $stmt   = $pdo->prepare($sql);
    $stmt->execute($params);
    $results = $stmt->fetchAll();

    echo json_encode(['results' => $results]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Prediction failed: ' . $e->getMessage()]);
}
