
# Calcio Scout

**Creatore:** Alberto Memo 

---

## Panoramica

**Calcio Scout** è un'applicazione che permette di consultare schede di giocatori e squadre del campionato di Bundesliga tedesca (con la possibilità di modificare, aggiungere o eliminare i giocatori). L'app si appoggia a un servizio REST backend realizzato in PHP con database MySQL, che integra dati provenienti da un'API esterna gratuita (API-Football via RapidAPI) con dati gestiti internamente, le chiamate ai database restituiscono lo stesso json dell'api esterna.

L'utente può navigare tra le squadre, visualizzare i giocatori di ogni rosa, salvare i propri giocatori e le proprie squadre preferiti/e e inoltre ha la possibilità si aggiungere nuovi giocatori, di modificare quelli gia esistenti e di eliminarli.

---

## Struttura del progetto

Il progetto è diviso in due componenti principali:

- **Server** — REST server in PHP con database MySQL, espone le API per la gestione di squadre, giocatori e preferiti. Include l'integrazione con rapidapi.com per il popolamento automatico dei dati reali.
- **Client** — App Flutter con interfaccia per la consultazione delle schede e la gestione dei preferiti. Utilizza una cache locale per garantire il funzionamento offline (quando fa una chiamata se va a buon fine salva l'output di quella chiamata sulla cache locale, se una chiamata non va a buon fine guarda se precedentemente se l'era salvata sul db locale di flutter e quindi usa il json che ha salvato precedentemente).

---

## Diario di progetto

### Step 1 — Definizione dell'idea e setup del repository.
**Data:** [26/03/2026]  
**Descrizione:** Creazione del repository `consegna_finale`, stesura del README con titolo, abstract e struttura generale del progetto. 
### Step 2 — Aggiornamento readme e quasi completamento lato server.
**Data:** [17/04/2026]  
**Descrizione:** Creazione nuovo readme dato che il precedente era dentro una cartella sbagliata. Quasi completato il lato server. 
### Step 3 — Completamento lato server.
**Data:** [20/04/2026]  
**Descrizione:** Lato server completato. 
### Step 4 — Verifica funzionalità lato server.
**Data:** [30/04/2026]  
**Descrizione:** Creazione semplice client html per verificare la funzionalità del server. 
### Step 5 — Scrittura codice flutter per client.
**Data:** [9/05/2026]  
**Descrizione:** Scrittura codice flutter per client. 
### Step 6 — Progetto completato.
**Data:** [13/05/2026]  
**Descrizione:** Progetto calcio scout completato e ultimi dettagli sistemati. 

