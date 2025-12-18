# Chatroom

## Comunicazione tramite Socket TCP

- Il server apre una porta TCP (4567) e resta in ascolto.
- Ogni client (console o Flutter) si connette tramite `Socket.connect()`.
- I messaggi vengono inviati e ricevuti come stringhe testuali terminate da newline.

## Gestione delle connessioni

- Ad ogni nuova connessione il server crea un `ClientInfo`.
- Il primo messaggio inviato dal client è lo **username**.
- Quando un client si collega o si disconnette, il server invia una notifica a tutti.

## Broadcast dei messaggi

- Ogni messaggio ricevuto viene inoltrato a tutti i client attivi.
- Il server gestisce eventuali errori o socket chiusi eliminando automaticamente i client inattivi.

## Componenti principali

### Server (`server.dart`)

- Riceve connessioni multiple.
- Legge e inoltra i messaggi.
- Gestisce login/logout automatici.
- Mantiene una lista dei client online.

### Client Console (`client_mobile.dart`)

- Consente di collegarsi inserendo host e username.
- Mostra i messaggi in tempo reale.
- Permette l’invio di testo e il comando `/quit`.

### Client Flutter (`client.dart`)

- Interfaccia grafica basata su Material3.
- Pagina di connessione (host/porta/username).
- Pagina chat con lista messaggi e campo di inserimento.
- Usa uno stream per ricevere dati e aggiorna la UI in tempo reale.

## Funzioni chiave

- `Socket.connect()`: connessione al server.
- `socket.writeln()`: invio messaggi.
- Stream + `LineSplitter()`: ricezione eventi in tempo reale.
- Lista `_messages`: memoria locale dei messaggi nella UI Flutter.

## Interfaccia grafica Flutter

- Lista messaggi aggiornata dinamicamente.
- Barra di input inferiore per invio dei messaggi.
- Gestione semplice e immediata per l’utente.
