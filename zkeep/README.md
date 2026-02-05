# am043 Todo List

Un'app Flutter per liste di cose da fare ispirata a Google Keep, con organizzazione basata su card.

## Funzionalità

- **Organizzazione a card**: Crea più card di todo, ognuna con la propria lista di attività
- **Interazioni semplici**:
  - Tocca un elemento todo per segnarlo come completato/non completato
  - Tieni premuto su un elemento todo per eliminarlo
  - Clicca il pulsante X per eliminare un'intera card
- **UI pulita**: Design minimalista con layout a griglia per visualizzare facilmente più card

## Come Usare l'App

1. **Crea una nuova card**: Clicca il pulsante di azione fluttuante (+) in basso a destra
2. **Aggiungi todo a una card**: Clicca il pulsante "add todo" all'interno di qualsiasi card
3. **Segna come completato**: Tocca qualsiasi elemento todo per cambiare lo stato di completamento
4. **Elimina un todo**: Tieni premuto su qualsiasi elemento todo
5. **Elimina una card**: Clicca il pulsante X nell'angolo in alto a destra di qualsiasi card

## Struttura del Progetto

-main.dart       # Punto di ingresso dell'app e home page
-model.dart      # Modelli di dati (TodoCard e Todo)
-notifier.dart   # Gestione dello stato con ChangeNotifier
-widgets.dart    # Componenti UI (TodoCardWidget e TodoItem)

## Dipendenze

- `flutter/material.dart`
- `provider` - Gestione dello stato

## Come Iniziare

1. Assicurati di avere Flutter installato
2. Clona questo repository
3. Esegui `flutter pub get` per installare le dipendenze
4. Esegui `flutter run` per avviare l'app

## Dettagli Tecnici

- **Gestione dello Stato**: Utilizza Provider con il pattern ChangeNotifier
- **Layout**: GridView con 2 colonne per la visualizzazione delle card
- **Tema**: Schema di colori rosso
