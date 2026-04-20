
# Calcio Scout

**Creatore:** Alberto Memo 

---

## Abstract

**Calcio Scout** è un'applicazione che permette di consultare schede dettagliate di giocatori e squadre del campionato di Bundesliga tedesca. L'app si appoggia a un servizio REST backend realizzato in PHP con database MySQL, che integra dati provenienti da un'API esterna gratuita (API-Football via RapidAPI) con dati gestiti internamente.

L'utente può navigare tra le squadre, visualizzare i giocatori di ogni rosa, e salvare i propri giocatori e le proprie squadre preferiti/e.

---

## Struttura del progetto

Il progetto è diviso in due componenti principali:

- **Backend** — REST server in PHP con database MySQL, espone le API per la gestione di squadre, giocatori e preferiti. Include l'integrazione con rapidapi.com per il popolamento automatico dei dati reali.
- **Frontend** — App Flutter con interfaccia per la consultazione delle schede e la gestione dei preferiti. Utilizza SQLite come cache locale per garantire il funzionamento offline.

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

