<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') exit;

$API_KEY = "60cd7e0a9bmsh6ae52d82785e57bp156f2cjsnb6fef24628fa";
$HOST    = "free-api-live-football-data.p.rapidapi.com";

$action = $_GET['action'] ?? "";

function callApi($url, $apiKey, $host) {
    $curl = curl_init();
    curl_setopt_array($curl, [
        CURLOPT_URL            => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT        => 30,
        CURLOPT_HTTPHEADER     => [
            "Content-Type: application/json",
            "x-rapidapi-host: $host",
            "x-rapidapi-key: $apiKey"
        ]
    ]);
    $response = curl_exec($curl);
    $error    = curl_error($curl);
    curl_close($curl);
    if ($error) return ["status" => "error", "message" => $error];
    return json_decode($response, true);
}

if ($action == "get_teams") {
    echo json_encode(callApi("https://$HOST/football-get-list-all-team?leagueid=207", $API_KEY, $HOST));
    exit;
}

if ($action == "get_players") {
    $team_id = intval($_GET['team_id'] ?? 0);
    echo json_encode(callApi("https://$HOST/football-get-list-player?teamid=$team_id", $API_KEY, $HOST));
    exit;
}

echo json_encode(["status" => "error", "message" => "Azione non valida"]);
