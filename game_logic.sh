#!/bin/bash
# game_logic.sh - Rock Paper Scissors TCP Game Server
#
# ncat verbindet die TCP-Verbindung mit stdin/stdout dieses Skripts.
# read liest dadurch Nachrichten vom Client.
# echo sendet Antworten zurück zum Client.

# Der Server-Move wird beim Start als erstes Argument übergeben.
# Beispiel: ./game_logic.sh ROCK
SERVER_MOVE=$(echo "$1" | tr '[:lower:]' '[:upper:]')

# Debug-Ausgabe nur im Kali-Terminal, nicht an den Client.
echo "[+] Connection received. Server move is: $SERVER_MOVE" >&2

# Eingaben vom Client lesen.
while read -r line; do
    # Windows-Zeilenende entfernen, falls der Client von Windows kommt.
    line=$(echo "$line" | tr -d '\r')

    # Empfangene Nachricht im Kali-Terminal anzeigen.
    echo "[DEBUG RX]: $line" >&2

    # Nachricht anhand des Doppelpunktes zerlegen.
    cmd=$(echo "$line" | cut -d':' -f1 | tr '[:lower:]' '[:upper:]')
    username=$(echo "$line" | cut -d':' -f2)
    payload=$(echo "$line" | cut -d':' -f3 | tr '[:lower:]' '[:upper:]')

    # HELO verarbeitet den Handshake.
    if [ "$cmd" = "HELO" ]; then

        if [ -z "$username" ]; then
            echo "ERROR:MISSING_USERNAME:Username required"
        else
            echo "STAT:Server:READY:Welcome $username"
        fi

    # PLAY verarbeitet den Spielzug.
    elif [ "$cmd" = "PLAY" ]; then

        # Prüfen, ob ein Username vorhanden ist.
        if [ -z "$username" ]; then
            echo "ERROR:MISSING_USERNAME:Username required"
            continue
        fi

        # Prüfen, ob der Move gültig ist.
        case "$payload" in
            ROCK|PAPER|SCISSORS)
                ;;
            *)
                echo "ERROR:INVALID_MOVE:$payload"
                continue
                ;;
        esac

        # Spielauswertung: Erst TIE, dann WIN, sonst LOSE.
        if [ "$payload" = "$SERVER_MOVE" ]; then
            echo "STAT:Server:TIE:Same move"

        elif [ "$payload" = "ROCK" ] && [ "$SERVER_MOVE" = "SCISSORS" ]; then
            echo "STAT:Server:WIN:ROCK beats SCISSORS"

        elif [ "$payload" = "SCISSORS" ] && [ "$SERVER_MOVE" = "PAPER" ]; then
            echo "STAT:Server:WIN:SCISSORS beats PAPER"

        elif [ "$payload" = "PAPER" ] && [ "$SERVER_MOVE" = "ROCK" ]; then
            echo "STAT:Server:WIN:PAPER beats ROCK"

        else
            echo "STAT:Server:LOSE:$SERVER_MOVE beats $payload"
        fi

    # Alles andere ist ein ungültiger Befehl.
    else
        echo "ERROR:INVALID_COMMAND:$cmd"
    fi
done
