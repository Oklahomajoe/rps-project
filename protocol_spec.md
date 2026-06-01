# Rock Paper Scissors TCP Protocol

## Message Format

Each message is text-based.
Fields are separated by colons.
Each message ends with a newline.

## Client to Server

Handshake:
HELO:Username

Play move:
PLAY:Username:MOVE

Valid moves:
ROCK
PAPER
SCISSORS

## Server to Client

Ready response:
STAT:Server:READY:Welcome Username

Game result:
STAT:Server:VERDICT:Description

Valid verdicts:
WIN
LOSE
TIE

Error response:
ERROR:Type:Description

## Example Trace

Client -> Server:
HELO:Alice

Server -> Client:
STAT:Server:READY:Welcome Alice

Client -> Server:
PLAY:Alice:SCISSORS

Server -> Client:
STAT:Server:LOSE:ROCK beats SCISSORS
