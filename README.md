# TPSIT - ZCalc

## **Autore**: Alberto Memo 4IC 2024/2025
il codice è formato da 4 classi: una classe ZCalc che estende
JFrame, una classe Stato e una classe ButtonClickListener che 
implementa ActionListener, che gestisce le funzioni "C" (cancella),
"Del" (cancella un carattere alla volta), e "=" (risolve le operazioni 
inserite da tastiera sulla stringa di testo principale).

La classe ZCalc gestisce l'aspetto grafico della calcolatrice e la 
classe stato riconosce i caratteri della stinga come "+", "-"... e li 
converte in operazioni.

il metodo Object().Parse() nella classe State in questo caso converte 
i caratteri di una stringa in forme adeguate a svolgere diversi tipi 
di operazione (int, double, float...).
