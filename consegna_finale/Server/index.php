<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// ======================
// CONFIG RAPIDAPI
// ======================
$API_KEY = trim("60cd7e0a9bmsh6ae52d82785e57bp156f2cjsnb6fef24628fa");
$HOST = "free-api-live-football-data.p.rapidapi.com";

// ======================
// DB CONNECTION
// ======================
$conn = new mysqli("localhost", "root", "", "calcio_db");

if ($conn->connect_error) {
    echo json_encode(["error" => "DB connection failed"]);
    exit;
}

// ======================
// ACTION
// ======================
$action = $_GET['action'] ?? "";

// ======================
// CURL FUNCTION
// ======================
function callApi($url, $apiKey, $host) {

    $curl = curl_init();

    curl_setopt_array($curl, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_HTTPHEADER => [
            "x-rapidapi-host: $host",
            "x-rapidapi-key: " . trim($apiKey)
        ],
    ]);

    $response = curl_exec($curl);
    $error = curl_error($curl);

    curl_close($curl);

    if ($error) {
        return ["error" => $error];
    }

    return json_decode($response, true);
}

// ======================
// GET TEAMS
// ======================
if ($action == "get_teams") {

    $data = callApi(
        "https://$HOST/football-get-list-all-team?leagueid=87",
        $API_KEY,
        $HOST
    );

    echo json_encode($data);
    exit;
}

// ======================
// GET PLAYERS
// ======================
elseif ($action == "get_players") {

    $team_id = $_GET['team_id'] ?? 0;

    $data = callApi(
        "https://$HOST/football-get-list-player?teamid=$team_id",
        $API_KEY,
        $HOST
    );

    echo json_encode($data);
    exit;
}

// ======================
// ADD PLAYER FAVORITE
// ======================
elseif ($action == "add_player") {

    $nome = $_POST['nome'] ?? "";
    $cognome = $_POST['cognome'] ?? "";
    $numero = $_POST['numero'] ?? 0;
    $squadra = $_POST['squadra_id'] ?? 0;

    $stmt = $conn->prepare("
        INSERT INTO calciatori_preferiti (nome, cognome, numero_maglia, squadra)
        VALUES (?, ?, ?, ?)
    ");

    $stmt->bind_param("ssii", $nome, $cognome, $numero, $squadra);

    echo $stmt->execute()
        ? json_encode(["status" => "ok"])
        : json_encode(["status" => "error"]);

    exit;
}

// ======================
// ADD TEAM FAVORITE
// ======================
elseif ($action == "add_team") {

    $nome = $_POST['nome_squadra'] ?? "";

    $stmt = $conn->prepare("
        INSERT INTO squadre_preferite (nome_squadra)
        VALUES (?)
    ");

    $stmt->bind_param("s", $nome);

    echo $stmt->execute()
        ? json_encode(["status" => "ok"])
        : json_encode(["status" => "error"]);

    exit;
}

// ======================
// GET FAVORITE PLAYERS
// ======================
elseif ($action == "get_favorite_players") {

    $res = $conn->query("SELECT * FROM calciatori_preferiti");

    $data = [];
    while ($row = $res->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
    exit;
}

// ======================
// GET FAVORITE TEAMS
// ======================
elseif ($action == "get_favorite_teams") {

    $res = $conn->query("SELECT * FROM squadre_preferite");

    $data = [];
    while ($row = $res->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
    exit;
}

// ======================
// REMOVE PLAYER
// ======================
elseif ($action == "remove_player") {

    $id = $_POST['id'] ?? 0;

    $stmt = $conn->prepare("DELETE FROM calciatori_preferiti WHERE id=?");
    $stmt->bind_param("i", $id);
    $stmt->execute();

    echo json_encode(["status" => "removed"]);
    exit;
}

// ======================
// REMOVE TEAM
// ======================
elseif ($action == "remove_team") {

    $id = $_POST['id'] ?? 0;

    $stmt = $conn->prepare("DELETE FROM squadre_preferite WHERE id=?");
    $stmt->bind_param("i", $id);
    $stmt->execute();

    echo json_encode(["status" => "removed"]);
    exit;
}

// ======================
// DEFAULT
// ======================
echo json_encode(["error" => "Invalid action"]);
?>