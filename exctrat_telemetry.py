import fastf1
import pandas as pd
import os

# Creer un dossier de cache
if not os.path.exists('cache'):
    os.makedirs('cache')
fastf1.Cache.enable_cache('cache')

print("Chargement de la session de qualification...")
session = fastf1.get_session(2025, 'bahrein', 'Q')
session.load()

fastest_lap = session.laps.pick_driver('PIA').pick_fastest()

print(f"Meilleur tour récupéré : {fastest_lap['LapTime']} par {fastest_lap['Driver']}")


telemetry = fastest_lap.get_telemetry()


selected_columns = [
    'Date', 'SessionTime', 'Time', 'Distance', 'Speed', 
    'RPM', 'nGear', 'Throttle', 'Brake', 'DRS', 'X', 'Y', 'Z'
]
telemetry_filtered = telemetry[selected_columns]

# Exporter les donnees pour MATLAB

output_file = 'f1_telemetry_piastri_bahrein.csv'

chemin_complet = os.path.join(r"C:\Users\user\Desktop\Files\Projet-F1\Trackside Real-Time Telemetry & AI AnomalyPerformance Analytics",output_file)

telemetry_filtered.to_csv(chemin_complet, index=False)

print(f" Succès ! Données exportées dans '{output_file}' ({len(telemetry_filtered)} points de données).")