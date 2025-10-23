Sequence
## Funzionalità

### Generazione della Sequenza
All'inizio del gioco, viene generata una sequenza casuale di 4 colori, che l'utente deve replicare. Ogni colore è rappresentato da un indice in una lista (`colorList`).

### Interazione dell'Utente
L'utente può cliccare sui cerchi colorati (in basso) per cambiarne il colore. Ogni volta che l'utente clicca su un cerchio, il colore cambia in un ciclo (grigio → giallo → verde → blu → rosso → grigio, e così via).

### Controllo della Sequenza
Quando l'utente è pronto, può premere il pulsante con il simbolo **"?"** per verificare se la sequenza di colori scelta è corretta. Il codice confronta la sequenza dell'utente con quella generata all'inizio.

### Feedback
- **Sequenza corretta**: Se la sequenza è corretta, viene mostrato il messaggio **"BEA!"** e la sequenza viene resettata per iniziare una nuova partita.
- **Sequenza errata**: Se la sequenza è sbagliata, viene mostrato il messaggio **"Sequenza non corretta"** e l'utente può riprovare.

### Reset e Nuova Sequenza
Dopo ogni tentativo (giusto o sbagliato), i colori vengono resettati e viene generata una nuova sequenza casuale.
