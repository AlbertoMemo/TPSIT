# Chrono

1. **Ticker Stream**  
   Genera un evento ogni 100 millisecondi. È la sorgente temporale del cronometro.

2. **Gestione del tempo**  
   Ogni evento incrementa `_ticks` solo se lo stato è *running*.  
   I tick vengono poi convertiti in secondi e mostrati in formato `mm:ss.s`.

3. **Stati principali**  
   - `MainState`: gestisce **START → STOP → RESET**  
   - `PauseState`: gestisce **PAUSE ↔ RESUME**

4. **Funzioni principali**  
   - `_start()`: avvia il ticker  
   - `_stop()`: ferma il ticker  
   - `_reset()`: azzera il tempo  
   - `_togglePauseState()`: mette in pausa o riprende il conteggio

5. **Interfaccia grafica**  
   Mostra il tempo al centro e due **FloatingActionButton** in basso a destra:  
   - uno per **START / STOP / RESET**  
   - uno per **PAUSE / RESUME**

