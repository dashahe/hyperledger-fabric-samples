#! /bin/bash

docker-compose -f docker-compose.yaml down
docker-compose -f docker-compose.yaml up -d ca1.example.com \
     ca2.example.com ca3.example.com orderer.example.com    \
     peer0.org1.example.com peer0.org1.example.com          \
     peer0.org2.example.com couchdb cli
