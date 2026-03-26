<?php

$curl = curl_init();

curl_setopt_array($curl, [
	CURLOPT_URL => "https://free-api-live-football-data.p.rapidapi.com/football-get-player-detail?playerid=671529",
	CURLOPT_RETURNTRANSFER => true,
	CURLOPT_ENCODING => "",
	CURLOPT_MAXREDIRS => 10,
	CURLOPT_TIMEOUT => 30,
	CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
	CURLOPT_CUSTOMREQUEST => "GET",
	CURLOPT_HTTPHEADER => [
		"Content-Type: application/json",
		"x-rapidapi-host: free-api-live-football-data.p.rapidapi.com",
		"x-rapidapi-key: 60cd7e0a9bmsh6ae52d82785e57bp156f2cjsnb6fef24628fa"
	],
]);

$response = curl_exec($curl);
$err = curl_error($curl);

curl_close($curl);

if ($err) {
	echo "cURL Error #:" . $err;
} else {
	echo $response;
}

?>