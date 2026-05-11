# Changelog

## v1.0.1 — 2026-05-12

### WiFi Finder
- Son Geiger actif uniquement quand la fenêtre est visible
- Fenêtre 2× plus large et redimensionnable (680×460, min 480×380)
- Animation des ondes variable selon la force du signal (nombre, épaisseur, opacité, amplitude)
- Conseil contextuel de déplacement selon la qualité du signal

### Speed Test
- Ajout de la latence (RTT) affichée côte à côte avec le RPM
- Fenêtre 30 % plus large et redimensionnable (468×480, min 380×420)
- Animation pulsante sur les jauges pendant le test
- Calcul des valeurs finales en moyenne (EMA) plutôt que dernière valeur
- Parsing multi-lignes JSON de networkQuality pour robustesse

### Traceroute
- Zoom-in par hop beaucoup plus proche de la Terre (80 km vs 400 km)
- Délais entre hops doublés pour mieux apprécier chaque étape
- Zoom arrière final vers la vue globale en fin de tracé

### Usages
- Calcul corrigé : une seule mesure de latence (3 pings vers 1.1.1.1)
- Seuils hiérarchiques par profil — gaming est toujours le plus exigeant, mail le plus tolérant
- Grille toujours visible avant la mesure (plus d'écran vide)
- Résultats animés un par un à l'arrivée

## v1.0.0 — 2026-05-10

- Initial public release
- Menu bar globe icon (green/orange/red)
- WiFi Finder (organic Geiger style)
- Speed Test (networkQuality)
- Traceroute (3D MapKit globe)
- Usage (4 quality profiles)
- Preferences + Sparkle auto-updates
