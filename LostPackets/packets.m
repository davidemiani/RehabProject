%script per interpolazione
%ho in ingresso un CELL ARRAY con gli oggetti Exel. di ognuno prendo
%IMUdata 
%PER ORA considero che sono tutti sincronizzati e con la stessa fc
%Exel e' il mio cell array con gli oggetti

%% INIT
%%
% paths management
csd = fileparts(mfilename('fullpath')); % current script directory
mainDir = fileparts(csd);
% ho bisogno di questo indirizzo in entrambe le due chiamate, successive
% dunque creo una variabile piuttosto che fare l'operazione due volte.
addpath(fullfile(mainDir,'davefuncs'));
addpath(fullfile(mainDir,'Exel_class'));
cd(csd) % serve se non sei già nella cartella dello script

% In generale, è meglio gestire in questo modo i percorsi. E' meglio
% rimanere sempre nella cartella dello script (che puoi ottenere con il
% primo comando) e da lì, se servono altre cartelle, aggiungerle al path
% con addpath, piuttosto che spostarsi tutte le volte fra le cartelle per
% chiamare le varie funzioni che servono allo script.

pulisci % elimina tutte le variabili ed i timer che girano nascosti


%% LOADING DATA
%%
% Il tuo vecchio script recitava:
%Exel(1).IMUdata=exelLog2table('hom.txt');
%Exel(2).IMUdata=exelLog2table('thx.txt');

% Incorretto, o comunque non coerente con quanto descritto sopra/con quanto
% deciso. Con questi due comandi stai creando una struttura chiamata Exel
% con dimensione 1x2 dove per ogni colonna hai un campo IMUdata, che
% contiene effettivamente la tabella dei dati. Per creare una cell array
% che include al suo interno in ogni cella un oggetto Exel con la table
% come definito, puoi procedere così:
ExelArray = cell(2,1); % initializing cell array 2x1
ExelArray{1,1} = Exel('EXLs3_0067','Segment','Homer','FigureVisible','off');
ExelArray{2,1} = Exel('EXLs3','Segment','Thorax','FigureVisible','off');
ExelArray{1,1}.ImuData = exelLog2table('hom.txt');
ExelArray{2,1}.ImuData = exelLog2table('thx.txt');
% ricordare di fare l'indexing sempre con due dimensioni, anche se l'array
% è monodimensionale (vettore), perché, soprattutto nei cicli for, è molto
% più rapido.

return % da togliere quando hai sistemato sotto


%% Simulazione pacchetti persi
%%
%cutPacket mi genera un numero casuale intero per localizzare il punto in
%cui tagliare. L'indice della riga � maggiore di un'unit� rispetto a ProgrNum
%Se CutPacket=10, taglier� ProgrNum da 9 a 9+NumCut
NumCut=20;
CutPacket1=randi(Exel(1).IMUdata.ProgrNum(end));
CutPacket2=randi(Exel(2).IMUdata.ProgrNum(end));
Exel(1).IMUdata(CutPacket1:CutPacket1+NumCut-1,:)=[];
Exel(2).IMUdata(CutPacket2:CutPacket2+NumCut-1,:)=[];
NumCut=1;
CutPacket1=randi(Exel(1).IMUdata.ProgrNum(end));
CutPacket2=randi(Exel(2).IMUdata.ProgrNum(end));
Exel(1).IMUdata(CutPacket1:CutPacket1+NumCut-1,:)=[];
Exel(2).IMUdata(CutPacket2:CutPacket2+NumCut-1,:)=[];


%%

Nobj = length(Exel); %2
MaxforInterp = 10;
for i = 1:Nobj
    %disp(Exel(i).IMUname)
    IMULost(i) = CheckLostPack(Exel(i).IMUdata);
    
    if IMULost(i).islost
            Exel(i).IMUdata = AddLostRow(IMULost(i),Exel(i).IMUdata,MaxforInterp);
    end

end


%%


