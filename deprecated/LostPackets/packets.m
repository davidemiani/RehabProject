%script per interpolazione
%input = cellArray di oggetti Exel
%ipotesi:oggetti sincronizzati e con stessa fc

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

ExelArray = cell(2,1); % initializing cell array 2x1
ExelArray{1,1} = Exel('EXLs3_0067','Segment','Homer','FigureVisible','off');
ExelArray{2,1} = Exel('EXLs3','Segment','Thorax','FigureVisible','off');
ExelArray{1,1}.ImuData = exelLog2table('hom.txt');
ExelArray{2,1}.ImuData = exelLog2table('thx.txt');
% ricordare di fare l'indexing sempre con due dimensioni, anche se l'array
% è monodimensionale (vettore), perch�, soprattutto nei cicli for, è molto
% più rapido.


%% Simulazione pacchetti persi
%%
%cutPacket genera un numero casuale intero per localizzare il punto in
%cui tagliare.
%Se CutPacket=10, taglier� ProgrNum da 9 a 9+NumCut
NumCut=20;
CutPacket1=randi(ExelArray{1,1}.ImuData.ProgrNum(end));
CutPacket2=randi(ExelArray{2,1}.ImuData.ProgrNum(end));
ExelArray{1,1}.ImuData(CutPacket1:CutPacket1+NumCut-1,:)=[];
ExelArray{2,1}.ImuData(CutPacket2:CutPacket2+NumCut-1,:)=[];
NumCut=1;
CutPacket1=randi(ExelArray{1,1}.ImuData.ProgrNum(end));
CutPacket2=randi(ExelArray{2,1}.ImuData.ProgrNum(end));
ExelArray{1,1}.ImuData(CutPacket1:CutPacket1+NumCut-1,:)=[];
ExelArray{2,1}.ImuData(CutPacket2:CutPacket2+NumCut-1,:)=[];


%%

Nobj = length(ExelArray); %2
MaxforInterp = 10;
for i = 1:Nobj
    %disp(Exel(i).IMUname)
    ImuLost(i) = CheckLostPack(ExelArray{i,1}.ImuData);
    
    if ImuLost(i).islost
            ExelArray{i,1}.ImuData = AddLostRow(ImuLost(i),ExelArray{i,1}.ImuData,MaxforInterp);
    end

end




