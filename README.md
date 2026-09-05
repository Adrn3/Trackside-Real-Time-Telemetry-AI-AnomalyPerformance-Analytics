# Trackside-Real-Time-Telemetry-AI-AnomalyPerformance-Analytics
Ce projet est un algorithme de détection d'anomalies (Machine Learning Toolbox) prédisant la dégradation des pneus et les pannes capteurs via la modélisation dynamique du véhicule sous Simulink afin de simuler les flux de données (télémétrie) en temps réel.

![MATLAB](https://img.shields.io/badge/MATLAB-R2023b%2B-blue?logo=mathworks)
![Simulink](https://img.shields.io/badge/Simulink-Model-orange?logo=mathworks)
![Python](https://img.shields.io/badge/Python-3.10%2B-green?logo=python)
![F1 Telemetry](https://img.shields.io/badge/Data-FastF1%20API-red)

## Algorthime de détection IA

## Préréquis & Installation

### Python
- **Windows** : Téléchargez Python depuis [python.org](https://www.python.org/). 
- **Linux** : Installez Python via la commande :  
     ```bash
     sudo apt install python3.10
     ```
### Matlab + Simulink
- **Windows** : Téléchargez Matlab depuis [matlab.com](https://www.mathworks.com/help/install/ug/install-products-with-internet-connection.html). 
- **Linux** : Installez Matlab via la commande :  
     ```bash
     sudo unzip matlab_R2026a_Linux.zip -d ./matlab_R2026a_Linux cd ./matlab_R2026a_Linux
     ```
     Dans le dossier d'installation, exécutez le script d'installation pour ouvrir le programme d'installation.
     ```bash
     xhost +SI:localuser:root
     sudo -H ./install
     xhost -SI:localuser:root
     ```
### Cloner le projet
```bash
     git clone https://github.com/Adrn3/Trackside-Real-Time-Telemetry-AI-AnomalyPerformance-Analytics
```
## Guide d'utilisation
```bash
     python extract_telemetry.py
```
Étape 2 : Chargement et Simulation dans MATLAB
    Ouvrez MATLAB 
    Exécutez le fichier analyse_telemetry_f1.m pour charger les variables (vitesse, throttle, brake, time_seconds) dans le Workspace et vérifier le jumeau numérique.

Étape 3 : Lancement du Pit-Wall Dashboard
    Ouvrez l'application F1_PitWall_Dashboard.mlapp via App Designer
    Cliquez sur le bouton Run.
    Cliquez sur le bouton LANCER L'ANALYSE PISTE pour lancer le diagnostic IA en temps réel.

## Dépendances
Bibliothèques utilisées :
FastF1
Pandas
Numpy
Matplotlib
