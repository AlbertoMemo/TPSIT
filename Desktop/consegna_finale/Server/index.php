<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

$conn = new mysqli("localhost", "root", "", "calcio_db");

if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Connessione database fallita"
    ]);
    exit;
}

$action = $_GET['action'] ?? "";
$method = $_SERVER['REQUEST_METHOD'];







if ($method == "GET" && $action == "get_teams") {

    $sql = "SELECT * FROM squadre ORDER BY idx ASC";
    $result = $conn->query($sql);

    $teams = [];

    while ($row = $result->fetch_assoc()) {
        $teams[] = [
            "name"      => $row["name"],
            "shortName" => $row["short_name"],
            "id"        => (int)$row["id"],
            "idx"       => (int)$row["idx"],
            "logo"      => $row["logo"]
        ];
    }

    echo json_encode([
        "status"   => "success",
        "response" => [
            "list" => $teams
        ]
    ]);

    exit;
}







if ($method == "GET" && $action == "get_players") {

    $team_id = intval($_GET['team_id'] ?? 0);

    $sql    = "SELECT * FROM membri WHERE team_id = $team_id";
    $result = $conn->query($sql);

    $keepers     = [];
    $defenders   = [];
    $midfielders = [];
    $attackers   = [];

    while ($row = $result->fetch_assoc()) {

        $player = [
            "id"               => (int)$row["id"],
            "name"             => $row["name"],
            "shirtNumber"      => $row["shirtNumber"] !== null ? (int)$row["shirtNumber"] : null,
            "ccode"            => $row["ccode"],
            "cname"            => $row["cname"],
            "role"             => [
                "key"      => $row["role_key"],
                "fallback" => $row["role_fallback"]
            ],
            "positionId"       => (int)$row["positionId"],
            "injury"           => null,
            "rating"           => $row["rating"] !== null ? (float)$row["rating"] : null,
            "goals"            => (int)$row["goals"],
            "penalties"        => (int)$row["penalties"],
            "assists"          => (int)$row["assists"],
            "rcards"           => (int)$row["rcards"],
            "ycards"           => (int)$row["ycards"],
            "excludeFromRanking" => false,
            "positionIds"      => $row["positionIds"],
            "positionIdsDesc"  => $row["positionIdsDesc"],
            "height"           => $row["height"] !== null ? (int)$row["height"] : null,
            "age"              => (int)$row["age"],
            "dateOfBirth"      => $row["dateOfBirth"],
            "transferValue"    => (int)$row["transferValue"]
        ];

        switch ($row["role_title"]) {
            case "keepers":
                $keepers[] = $player;
                break;
            case "defenders":
                $defenders[] = $player;
                break;
            case "midfielders":
                $midfielders[] = $player;
                break;
            case "attackers":
                $attackers[] = $player;
                break;
        }
    }

    $squad = [];

    if (count($keepers) > 0) {
        $squad[] = ["title" => "keepers", "members" => $keepers];
    }
    if (count($defenders) > 0) {
        $squad[] = ["title" => "defenders", "members" => $defenders];
    }
    if (count($midfielders) > 0) {
        $squad[] = ["title" => "midfielders", "members" => $midfielders];
    }
    if (count($attackers) > 0) {
        $squad[] = ["title" => "attackers", "members" => $attackers];
    }

    echo json_encode([
        "status"   => "success",
        "response" => [
            "squad"          => $squad,
            "isNationalTeam" => false
        ]
    ]);

    exit;
}








if ($method == "POST" && $action == "team") {

    $data = json_decode(file_get_contents("php://input"), true);

    $stmt = $conn->prepare("
        INSERT INTO squadre(id, name, short_name, logo, idx)
        VALUES (?, ?, ?, ?, ?)
    ");

    $stmt->bind_param(
        "isssi",
        $data["id"],
        $data["name"],
        $data["short_name"],
        $data["logo"],
        $data["idx"]
    );

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Squadra aggiunta"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }

    exit;
}








if ($method == "POST" && $action == "player") {
    $d = json_decode(file_get_contents("php://input"), true);

    $name         = $d["name"] ?? "";
    $age          = (int)($d["age"] ?? 0);
    $shirtNumber  = (int)($d["shirtNumber"] ?? 0);
    $goals        = (int)($d["goals"] ?? 0);
    $assists      = (int)($d["assists"] ?? 0);
    $role_title   = $d["role_title"] ?? "";
    $role_key     = $d["role_key"] ?? "";
    $role_fallback= $d["role_fallback"] ?? "";
    $team_id      = (int)($d["team_id"] ?? 0);

    $stmt = $conn->prepare("
        INSERT INTO membri(name, age, shirtNumber, goals, assists, role_title, role_key, role_fallback, team_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $stmt->bind_param(
        "siiiisssi",
        $name, $age, $shirtNumber, $goals, $assists,
        $role_title, $role_key, $role_fallback, $team_id
    );

    echo $stmt->execute()
        ? json_encode(["status" => "success", "message" => "Giocatore aggiunto"])
        : json_encode(["status" => "error", "message" => $stmt->error]);
    exit;
}







if ($method == "PUT" && $action == "player") {

    $data = json_decode(file_get_contents("php://input"), true);

    $stmt = $conn->prepare("
        UPDATE membri
        SET name = ?, age = ?, shirtNumber = ?, goals = ?, assists = ?
        WHERE id = ?
    ");

    $stmt->bind_param(
        "siiiii",
        $data["name"],
        $data["age"],
        $data["shirtNumber"],
        $data["goals"],
        $data["assists"],
        $data["id"]
    );

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Giocatore modificato"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }

    exit;
}








if ($method == "PATCH" && $action == "player") {

    $data = json_decode(file_get_contents("php://input"), true);

    $id     = $data["id"];
    $fields = [];

    if (isset($data["goals"]))   $fields[] = "goals = "   . (int)$data["goals"];
    if (isset($data["assists"])) $fields[] = "assists = " . (int)$data["assists"];
    if (isset($data["rating"]))  $fields[] = "rating = "  . (float)$data["rating"];

    if (count($fields) == 0) {
        echo json_encode(["status" => "error", "message" => "Nessun campo da modificare"]);
        exit;
    }

    $sql = "UPDATE membri SET " . implode(", ", $fields) . " WHERE id = $id";

    if ($conn->query($sql)) {
        echo json_encode(["status" => "success", "message" => "Modifica parziale completata"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }

    exit;
}








if ($method == "DELETE" && $action == "player") {

    $id   = intval($_GET["id"] ?? 0);
    $stmt = $conn->prepare("DELETE FROM membri WHERE id = ?");
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Giocatore eliminato"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }

    exit;
}








if ($method == "DELETE" && $action == "team") {

    $id   = intval($_GET["id"] ?? 0);
    $stmt = $conn->prepare("DELETE FROM squadre WHERE id = ?");
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Squadra eliminata"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }

    exit;
}








echo json_encode([
    "status"  => "error",
    "message" => "Endpoint non trovato"
]);

$conn->close();