Acquisizioni del 24/11/2017


Lo script mainAcquisition.m esegue l'acquisizione e salva il contenuto di
ExelObj.ImuData in formato 'dataHum' (lo stesso utilizzato per le
acquisizioni precedenti) nella sottocartella data. Lo script gestisce tutto
il processo di acquisizione, mostrando a schermo l'andamento delle
accelerazioni e gli angoli calcolati con le funzioni definite in FraFuncs
sotto il nome di computeFrontalAngle.m e computeSagittalAngle.m.
Infine chiede all'utente il nome del file da salvare.

Cosa deve fare chi acquisisce:
* cambiare, se necessario, i parametri impostati nella sezione INIT;
* rispettare, per il nome del file, il formato: Angolo_NumeroProvaPiano.mat


Computazione angoli
Siccome le funzioni di Francesco funzionano solo con gli oggetti e per ora
abbiamo deciso di utilizzare il vecchio tipo di dato ('dataHum'), ho
sviluppato due funzioni computeFrontalAngle e computSagittalAngle, che
prendono in ingresso le accelerazioni di interesse e restituiscono Acos ed
Atan come arry di double. Utilizzare queste funzioni e modificare queste
ultime per calcolare gli angoli negli script di statistica.


mainStatistics
per ora uguale al vecchio mainValutazionePrecisioneAngoli, ho modificato
solamente:
* aggiunta anche del path frafuncs
* niente agginta del path della cartella dei dati ma puntamento a file (già
implementato nel primo ciclo for)
* niente moltiplicazione per costante correttiva delle velocità, già
eseguito a monte dalla classe Exel.
Ovviamente per come è definito lo script della vecchia statistica così 
proprio non può girare, e va modificato con alcuni accorgimenti. Lascio a
voi questo increscioso compito quando definirete a modo quante prove fare
ecc.
