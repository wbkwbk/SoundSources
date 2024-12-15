@echo off

:: Quellverzeichnis
set Quellverzeichnis=D:\data\Tresorit\mruff\Flipper\LordOfTheRings\MODS\Topper\SoundSources\Production\Source
:: Zielverzeichnis
set Zielverzeichnis=D:\data\Virtual Machines\XChangeW11\Topper\ProdSounds

:: Prüfen, ob das Quellverzeichnis existiert
if not exist "%Quellverzeichnis%" (
    echo Quellverzeichnis "%Quellverzeichnis%" existiert nicht!
    pause
    exit /b
)

:: Prüfen, ob das Zielverzeichnis existiert, falls nicht, erstellen
if not exist "%Zielverzeichnis%" (
    md "%Zielverzeichnis%"
    if not exist "%Zielverzeichnis%" (
        echo Fehler beim Erstellen des Zielverzeichnisses!
        pause
        exit /b
    )
)

:: Alle Dateien aus dem Quellverzeichnis und seinen Unterverzeichnissen kopieren
for /r "%Quellverzeichnis%" %%a in (*.mp3 *.wav *.ogg) do (
    copy "%%a" "%Zielverzeichnis%"
)

echo Alle Dateien wurden kopiert.
pause