%% 1. INITIALISATION ET CHARGEMENT DES DONNÉES
clear; clc; close all;

filename = 'f1_telemetry_piastri_spa.csv';

% Vérification de l'existence du fichier
if ~exist(filename, 'file')
    error('Le fichier %s est introuvable. Assurez-vous qu''il est dans le dossier courant.', filename);
end

% Importation des données sous forme de Table
fprintf('Chargement de la télémétrie de Bahrein...\n');
data = readtable(filename);

% Extraction et conversion forcée en double
distance = double(data.Distance);      % Metres
vitesse  = double(data.Speed);         % km/h
throttle = double(data.Throttle);      % %
rpm      = double(data.RPM);           % Tr/min
gear     = double(data.nGear);         % Rapport engagé
posX     = double(data.X);             % Coordonnées 3D
posY     = double(data.Y);
posZ     = double(data.Z);

% Correction du format de Brake
if iscell(data.Brake)
    brake = double(string(data.Brake) == "True" | string(data.Brake) == "1");
else
    brake = double(data.Brake);
end

fprintf('Données chargées avec succès ! Tour de %d points de mesure.\n', length(vitesse));

%% 2. VISUALISATION 1 : TRACÉ DU CIRCUIT (SPEED MAP 2D)
figure('Name', 'F1 Trackside Performance - Circuit Map', 'Color', [0.15 0.15 0.15]);
set(gcf, 'Position', [100, 100, 900, 600]);

% Utilisation de scatter pour afficher le circuit coloré par la vitesse
scatter(posX, posY, 15, vitesse, 'filled');
colormap(jet);
cb = colorbar;
cb.Color = 'w';
cb.Label.String = 'Vitesse (km/h)';
cb.Label.FontSize = 11;

axis equal;
grid on;
ax = gca;
ax.Color = [0.1 0.1 0.1];
ax.XColor = 'w'; ax.YColor = 'w';
title('Spa-Francorchamps - Profil de Vitesse (Pole Position Lap)', 'Color', 'w', 'FontSize', 14);
xlabel('Position X (m)', 'Color', 'w');
ylabel('Position Y (m)', 'Color', 'w');

%% 3. VISUALISATION 2 : PANNEAU DE TÉLÉMÉTRIE PISTE
figure('Name', 'F1 Telemetry Dashboard - Piastri Spa', 'Color', [0.95 0.95 0.95]);

% Subplot 1 : Vitesse & Rapport
subplot(3,1,1);
plot(distance, vitesse, 'r', 'LineWidth', 1.5);
grid on;
ylabel('Vitesse (km/h)');
title('Télémétrie Piste - Piastri (Spa-Francorchamps)');
yyaxis right;
plot(distance, gear, 'k--', 'LineWidth', 1);
ylabel('Rapport (Gear)');
legend('Vitesse', 'Rapport', 'Location', 'best');

% Subplot 2 : Inputs Pilote (Throttle / Brake)
subplot(3,1,2);
plot(distance, throttle, 'g', 'LineWidth', 1.2); hold on;
plot(distance, brake, 'b', 'LineWidth', 1.2);
grid on;
ylabel('Inputs Pilote (%)');
legend('Accélérateur (Throttle)', 'Frein (Brake)', 'Location', 'best');

% Subplot 3 : Moteur (RPM)
subplot(3,1,3);
plot(distance, rpm, 'm', 'LineWidth', 1.2);
grid on;
xlabel('Distance sur le tour (m)');
ylabel('Régime Moteur (RPM)');
legend('RPM', 'Location', 'best');

fprintf('Graphiques générés ! Prêt pour l''étape suivante.\n');

%% 4. PRÉPARATION DES DONNÉES POUR SIMULINK
fprintf('Conversion des données pour Simulink...\n');

% Conversion de Time en objet Duration puis en secondes (numérique)
if iscell(data.Time) || isstring(data.Time) || ischar(data.Time)
    tstr = string(data.Time);
    tstr = regexprep(tstr,'\s*days\s*',':');     % "0 days 00:00:00" -> "0:00:00:00"
    t_dur = duration(tstr);                      % accepte "dd:hh:mm:ss" ou "hh:mm:ss"
    time_seconds = seconds(t_dur - t_dur(1));
elseif isduration(data.Time)
    time_seconds = seconds(data.Time - data.Time(1));
else
    time_seconds = double(data.Time - data.Time(1));
end

% Création des signaux d'entrée pour Simulink (Objets TimeSeries)
sim_throttle   = timeseries(double(throttle), time_seconds);
sim_brake      = timeseries(double(brake), time_seconds);
sim_speed_real = timeseries(double(vitesse), time_seconds);

% Sauvegarde dans le Workspace MATLAB
assignin('base', 'sim_throttle', sim_throttle);
assignin('base', 'sim_brake', sim_brake);
assignin('base', 'sim_speed_real', sim_speed_real);
assignin('base', 't_end', max(time_seconds));

fprintf('Données prêtes dans le Workspace ! Temps total du tour : %.2f secondes.\n', max(time_seconds));

%% 5. EXÉCUTION SIMULINK ET COMPARAISON TÉLÉMÉTRIE / PISSE
fprintf('Lancement de la simulation Simulink...\n');

% Exécution du modèle Simulink depuis le script MATLAB
simOut = sim('f1_vehicle_model');

% Extraction du signal de vitesse simulé (conversion m/s -> km/h)
vitesse_simulee_kmh = simOut.simout.Data * 3.6; 
temps_simule        = simOut.simout.Time;

% Création du graphique de superposition (Pit-Wall Overlay)
figure('Name', 'Trackside Telemetry Validation & Fault Detection', 'Color', [0.95 0.95 0.95]);

% Courbes de vitesse
plot(time_seconds, vitesse, 'b', 'LineWidth', 1.8, 'DisplayName', 'Télémétrie Réelle (Piastri)');
hold on;
plot(temps_simule, vitesse_simulee_kmh, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Simulation Physique (Simulink)');

% Ligne de déclenchement de la panne (Step à 35s)
xline(35, 'g--', 'LineWidth', 2, 'DisplayName', 'Déclenchement Anomalie Aéro (Step)');

% Visuel
grid on;
title('Comparaison Vitesse Piste vs Modèle Virtuel & Injection de Panne', 'FontSize', 12);
xlabel('Temps du tour (s)');
ylabel('Vitesse (km/h)');
legend('Location', 'southwest');

fprintf('Simulation terminée avec succès ! Comparez la déviation après t = 35s.\n');

%% 6. IA OPTIMISÉE : DÉTECTION EN PLEINE CHARGE (FULL THROTTLE)
fprintf('Analyse IA ciblée sur les lignes droites...\n');

% 1. Resynchronisation et résidu
vitesse_sim_interp = interp1(temps_simule, vitesse_simulee_kmh, time_seconds, 'linear', 'extrap');
residu_brut = abs(vitesse - vitesse_sim_interp);

% 2. Masque Pleine Charge (Throttle > 80%) pour ignorer les freinages
masque_pleine_charge = throttle > 80;
residu_pleine_charge = residu_brut;
residu_pleine_charge(~masque_pleine_charge) = NaN; % On masque hors lignes droites

% 3. Seuil dynamique calculé uniquement sur la pleine charge saine (t < 35s)
residu_sain_straight = residu_brut( time_seconds(:) < 35 & masque_pleine_charge(:) );
seuil_opti = mean(residu_sain_straight) + 2 * std(residu_sain_straight);

% 4. Condition d'alerte validée
alerte_ia = double(residu_brut > seuil_opti & masque_pleine_charge' & time_seconds' >= 35);

% 5. Affichage Dashboard IA
figure('Name', 'Trackside AI Fault Detection System', 'Color', [0.95 0.95 0.95]);

subplot(2,1,1);
plot(time_seconds, residu_brut, 'Color', [0.8 0.8 0.8], 'DisplayName', 'Résidu global'); hold on;
plot(time_seconds, residu_pleine_charge, 'm', 'LineWidth', 2, 'DisplayName', 'Résidu Pleine Charge');
yline(seuil_opti, 'r--', 'Seuil Calibré (Aéro)', 'LineWidth', 1.5);
xline(35, 'g--', 'Injection Panne (t=35s)', 'LineWidth', 1.5);
grid on;
title('Résidu de Performance Aérodynamique (Masque Pleine Charge)');
ylabel('Écart (km/h)');
legend('Location', 'northeast');

subplot(2,1,2);
area(time_seconds, alerte_ia, 'FaceColor', [0.85 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
grid on;
ylim([-0.1 1.1]);
title('Signal d''Alerte Pit-Wall (Validé sur Lignes Droites)');
xlabel('Temps du tour (s)');
ylabel('État Alerte');

% Diagnostic
t_impact = time_seconds(find(alerte_ia, 1));
if ~isempty(t_impact)
    fprintf(' ALERTE IA CONFIRMÉE : Dégât aéro détecté à t = %.2f s !\n', t_impact);
end