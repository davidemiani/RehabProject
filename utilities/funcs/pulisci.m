%PULISCI clc, clear all, close all per l'italiano medio.
%   Utilizza 'pulisci' per cancellare la Command Window, liberare il
%   Workspace e la memoria, nonche' chiudere tutte le finestre aperte.
% Author Davide Miani

% cleaning up the Command Window
clc

% cloasing all figures opened
close all

% stopping all timers
timers = timerfindall;
for i = 1 : numel( timers )
    try
        stop( timers(i) )
        delete( timers(i) );
    catch ME
    end
end

% cleaning up all variables in Workspace
clearvars
clearvars -global

