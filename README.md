# Schlummerzeit

Ein Schlaf-Tracker für Babys. Ein großer Knopf startet und beendet einen Schlaf. Aus dem Verlauf und dem Alter des
Babys schätzt die App, wann das nächste Schläfchen und die Nacht fällig sind. Der Plan zeigt das für heute bzw. morgen.
Schlafphasen lassen sich nachtragen. Alle Daten bleiben lokal im Browser.

## Dateien

| Datei | Inhalt |
|---|---|
| `index.html` | die komplette App (HTML/CSS/JavaScript in einer Datei) |
| `build-iphone.ps1` | baut daraus die installierbare Web-App im Ordner `iphone-app/` |
| `iphone-app/` | Ergebnis des Builds: Seite, Manifest, Service Worker (offline) und Icons |

## Aufs iPhone bringen

1. `powershell -File build-iphone.ps1` ausführen. Das Skript erzeugt `iphone-app/` neu, mit einer neuen Cache-Version im Service Worker.
2. Den Inhalt von `iphone-app/` über HTTPS bereitstellen, zum Beispiel per GitHub Pages.
3. Die Seite in Safari öffnen und „Teilen → Zum Home-Bildschirm“ wählen. Danach läuft die App offline und im Vollbild.

## Hinweis

Die Vorhersagen sind grobe Richtwerte und kein medizinischer Rat.
