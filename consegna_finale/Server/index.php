<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

/* ==========================================
   CONFIG
========================================== */

$API_KEY = "60cd7e0a9bmsh6ae52d82785e57bp156f2cjsnb6fef24628fa";
$HOST = "free-api-live-football-data.p.rapidapi.com";

/* ==========================================
   DATABASE
========================================== */

$conn = new mysqli("localhost", "root", "", "calcio_db");

if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Connessione database fallita"
    ]);
    exit;
}

$conn->set_charset("utf8");

/* ==========================================
   ACTION
========================================== */

$action = $_GET['action'] ?? "";

/* ==========================================
   CURL FUNCTION
========================================== */

function callApi($url, $apiKey, $host)
{
    $curl = curl_init();

    curl_setopt_array($curl, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_HTTPHEADER => [
            "Content-Type: application/json",
            "x-rapidapi-host: $host",
            "x-rapidapi-key: $apiKey"
        ]
    ]);

    $response = curl_exec($curl);
    $error = curl_error($curl);

    curl_close($curl);

    if ($error) {
        return [
            "status" => "error",
            "message" => $error
        ];
    }

    return json_decode($response, true);
}

/* ==========================================
   GET TEAMS (Bundesliga)
========================================== */

if ($action == "get_teams") {

    $data = callApi(
        "https://$HOST/football-get-list-all-team?leagueid=207",
        $API_KEY,
        $HOST
    );

    echo json_encode($data);
    exit;
}

/* ==========================================
   GET PLAYERS
========================================== */

elseif ($action == "get_players") {

    $team_id = intval($_GET['team_id'] ?? 0);

    $data = callApi(
        "https://$HOST/football-get-list-player?teamid=$team_id",
        $API_KEY,
        $HOST
    );

    echo json_encode($data);
    exit;
}

/* ==========================================
   TEAM LOGO
========================================== */

elseif ($action == "get_team_logo") {

    $team_id = intval($_GET['team_id'] ?? 0);

    $data = callApi(
        "https://$HOST/football-team-logo?teamid=$team_id",
        $API_KEY,
        $HOST
    );

    echo json_encode($data);
    exit;
}

/* ==========================================
   PLAYER PHOTO
========================================== */

elseif ($action == "get_player_photo") {

    $player_id = intval($_GET['player_id'] ?? 0);

    $data = callApi(
        "https://$HOST/football-get-player-logo?playerid=$player_id",
        $API_KEY,
        $HOST
    );

    echo json_encode($data);
    exit;
}

/* ==========================================
   ADD FAVORITE TEAM
========================================== */

elseif ($action == "add_team") {

    $team_id = intval($_POST['team_id'] ?? 0);
    $nome    = $_POST['nome_squadra'] ?? "";

    $check = $conn->prepare("SELECT id FROM squadre_preferite WHERE team_id=?");
    $check->bind_param("i", $team_id);
    $check->execute();
    $res = $check->get_result();

    if ($res->num_rows > 0) {
        echo json_encode([
            "status" => "exists"
        ]);
        exit;
    }

    $stmt = $conn->prepare("
        INSERT INTO squadre_preferite (team_id, nome_squadra)
        VALUES (?, ?)
    ");

    $stmt->bind_param("is", $team_id, $nome);

    echo json_encode([
        "status" => $stmt->execute() ? "ok" : "error"
    ]);

    exit;
}

/* ==========================================
   REMOVE FAVORITE TEAM
========================================== */

elseif ($action == "remove_team") {

    $team_id = intval($_POST['team_id'] ?? 0);

    $stmt = $conn->prepare("
        DELETE FROM squadre_preferite
        WHERE team_id=?
    ");

    $stmt->bind_param("i", $team_id);
    $stmt->execute();

    echo json_encode([
        "status" => "removed"
    ]);

    exit;
}

/* ==========================================
   GET FAVORITE TEAMS
========================================== */

elseif ($action == "get_favorite_teams") {

    $res = $conn->query("
        SELECT *
        FROM squadre_preferite
        ORDER BY nome_squadra ASC
    ");

    $data = [];

    while ($row = $res->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
    exit;
}

/* ==========================================
   ADD FAVORITE PLAYER
========================================== */

elseif ($action == "add_player") {

    $player_id = intval($_POST['player_id'] ?? 0);
    $nome      = $_POST['nome'] ?? "";
    $cognome   = $_POST['cognome'] ?? "";
    $numero    = intval($_POST['numero'] ?? 0);
    $squadra   = intval($_POST['squadra_id'] ?? 0);

    $check = $conn->prepare("
        SELECT id
        FROM giocatori_preferiti
        WHERE player_id=?
    ");

    $check->bind_param("i", $player_id);
    $check->execute();

    $res = $check->get_result();

    if ($res->num_rows > 0) {
        echo json_encode(["status" => "exists"]);
        exit;
    }

    $stmt = $conn->prepare("
        INSERT INTO giocatori_preferiti
        (player_id, nome, cognome, numero_maglia, squadra_id)
        VALUES (?, ?, ?, ?, ?)
    ");

    $stmt->bind_param(
        "issii",
        $player_id,
        $nome,
        $cognome,
        $numero,
        $squadra
    );

    echo json_encode([
        "status" => $stmt->execute() ? "ok" : "error"
    ]);

    exit;
}

/* REMOVE PLAYER */
elseif ($action == "remove_player") {

    $player_id = intval($_POST['player_id'] ?? 0);

    $stmt = $conn->prepare("
        DELETE FROM giocatori_preferiti
        WHERE player_id=?
    ");

    $stmt->bind_param("i", $player_id);
    $stmt->execute();

    echo json_encode(["status" => "removed"]);
    exit;
}

/* GET FAVORITE PLAYERS */
elseif ($action == "get_favorite_players") {

    $res = $conn->query("
        SELECT *
        FROM giocatori_preferiti
        ORDER BY nome ASC
    ");

    $data = [];

    while ($row = $res->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
    exit;
}

/* ==========================================
   DEFAULT
========================================== */

echo json_encode([
    "status" => "error",
    "message" => "Azione non valida"
]);

?>
