# Calcio Scout

**Creatore:** [Alberto Memo]  

---

## Abstract

**Calcio Scout** è un'applicazione mobile sviluppata in Flutter che permette di consultare schede dettagliate di giocatori e squadre del campionato di Serie A italiana. L'app si appoggia a un servizio REST backend realizzato in PHP con database MySQL, che integra dati provenienti da un'API esterna gratuita (API-Football via RapidAPI) con dati gestiti internamente tramite CRUD completo.

L'utente può navigare tra le squadre, visualizzare i giocatori di ogni rosa, e salvare i propri giocatori preferiti aggiungendo note personali. L'app è progettata per funzionare anche in assenza di connessione internet: in modalità offline, tutte le richieste vengono dirottate su un database locale SQLite (pacchetto `sqflite`) che funge da cache dei dati precedentemente scaricati.

---

## Struttura del progetto

Il progetto è diviso in due componenti principali:

- **Backend** — REST server in PHP con database MySQL, espone le API per la gestione di squadre, giocatori e preferiti. Include l'integrazione con API-Football per il popolamento automatico dei dati reali.
- **Frontend** — App Flutter con interfaccia per la consultazione delle schede e la gestione dei preferiti. Utilizza SQLite come cache locale per garantire il funzionamento offline.

---

## Diario di progetto

### Step 1 — Definizione dell'idea e setup del repository
**Data:** [26/03/2026]  
**Descrizione:** Creazione del repository `consegna_finale`, stesura del README con titolo, abstract e struttura generale del progetto. 
