# am085 Todo List

Un'app Flutter per la gestione di una lista di cose da fare, con salvataggio persistente tramite database locale SQLite (sqflite).

---

## Funzionalità

- Visualizzazione lista di todo salvati
- Aggiunta di un nuovo todo tramite dialog
- Modifica dello stato (completato/non completato)
- Eliminazione di un todo
- Salvataggio automatico su database locale

---

## Interazioni

- Tocca un elemento todo per segnarlo come completato/non completato
- Tieni premuto su un elemento todo per eliminarlo
- Clicca il pulsante + in basso a destra per aggiungere un nuovo todo

---

## Come usare l'app

### Avvio
All'avvio dell'app:
- Viene inizializzato il database
- Vengono caricati tutti i todo salvati

### Aggiungere un nuovo todo
1. Premi il pulsante + in basso a destra
2. Inserisci il testo nel dialog
3. Premi "Add"
4. Il todo viene salvato nel database e mostrato in lista

### Segnare come completato
- Tocca un elemento della lista
- Il testo viene barrato
- Il todo viene aggiornato nel database
- I todo completati vengono spostati in cima alla lista

### Eliminare un todo
- Tieni premuto su un elemento
- Il todo viene rimosso dalla lista e dal database

---

## Struttura del progetto

- `main.dart`  
  Punto di ingresso dell'app.  
  Contiene:
  - MyApp
  - MyHomePage
  - Gestione dello stato
  - Dialog per inserimento nuovo todo

- `model.dart`  
  Contiene la classe `Todo` con:
  - id (chiave primaria)
  - name (testo)
  - checked (stato completato)

- `helper.dart`  
  Gestione del database SQLite:
  - Creazione database
  - Creazione tabella
  - Operazioni CRUD (insert, update, delete, get)

- `widgets.dart`  
  Contiene il widget `TodoItem` per la visualizzazione di ogni elemento della lista.

---

## Dettagli Tecnici

- Framework: Flutter
- Linguaggio: Dart
- Database: SQLite tramite sqflite
- Persistenza: file `todos.db`
- Layout: ListView.builder
- Gestione stato: StatefulWidget con setState
- Operazioni supportate: CRUD completo

---

## Tabella Database

```sql
CREATE TABLE todos (
  id INTEGER NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  checked INTEGER NOT NULL
);
