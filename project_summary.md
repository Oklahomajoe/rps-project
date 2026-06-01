# Rock Paper Scissors TCP Game Server - Project Summary

## 1. Project Goal

The goal of this project was to build a simple TCP-based Rock Paper Scissors game server using Bash and ncat on Kali Linux.

The server accepts plain text protocol messages from a client, processes the input, validates commands and moves, and sends protocol-compliant responses back over the TCP connection.

## 2. System Architecture

Host Machine:
- Acts as the client.
- Connects to the game server using ncat.
- Sends raw protocol commands manually.

Kali Linux VM:
- Runs the TCP server.
- Uses ncat as the socket listener.
- Starts game_logic.sh for each incoming connection.
- Processes protocol messages using Bash.

Pinggy:
- Provides a public TCP tunnel.
- Forwards internet traffic to the local Kali server on port 12345.

Wireshark:
- Captures and analyzes the TCP traffic.
- Filter used: tcp.port == 12345

## 3. Protocol Specification

Messages are text-based.
Fields are separated by colons.
Each message ends with a newline.

Client handshake:
HELO:Username

Client move:
PLAY:Username:MOVE

Valid moves:
ROCK
PAPER
SCISSORS

Server ready response:
STAT:Server:READY:Welcome Username

Server game result:
STAT:Server:VERDICT:Description

Valid verdicts:
WIN
LOSE
TIE

Server error:
ERROR:Type:Description

## 4. Example Game Trace

Client -> Server:
HELO:Alice

Server -> Client:
STAT:Server:READY:Welcome Alice

Client -> Server:
PLAY:Alice:PAPER

Server -> Client:
STAT:Server:WIN:PAPER beats ROCK

Client -> Server:
PLAY:Alice:SPOCK

Server -> Client:
ERROR:INVALID_MOVE:SPOCK

## 5. Implemented Features

- HELO handshake handling
- Username validation
- PLAY command parsing
- Move validation
- Case normalization for commands and moves
- WIN, LOSE and TIE calculation
- Invalid command handling
- Invalid move handling
- Local TCP test with ncat
- Public TCP test through Pinggy
- Wireshark traffic analysis

## 6. Test Results

The server was tested locally from the host machine using ncat.

Successful test cases:
- HELO:Alice
- PLAY:Alice:ROCK
- PLAY:Alice:PAPER
- PLAY:Alice:SCISSORS
- PLAY:Alice:SPOCK
- HELLO:Alice

The server correctly returned READY, WIN, LOSE, TIE and ERROR responses.

The server was also exposed publicly through Pinggy and tested over the internet using the generated Pinggy hostname and port.

Wireshark was used to capture the TCP traffic with the filter:

tcp.port == 12345

## 7. Submitted Files and Evidence

Code:
- game_logic.sh

Protocol documentation:
- protocol_spec.md

Screenshots:
- Local ncat test
- Pinggy tunnel
- Pinggy ncat test
- Wireshark traffic capture
