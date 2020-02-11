#! /bin/bash

# global variables
IMAGE_TAG="2.0"
CHANNEL_NAME="milkchannel"
COMPOSE_FILE=docker-compose.yaml

export PATH=${PWD}/../../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false

# functions
generateCerts() {
    if [ -d "crypto-config" ]; then
        rm -rf crypto-config/
    fi
    cryptogen generate --config=./crypto-config.yaml 
    res=$?
    if [ $res -ne 0 ]; then
        echo "Failed to genearate certifacts..."
        exit 1
    fi
    echo
} 

generateChannelArtifacts() {
    mkdir channel-artifacts
    configtxgen -profile MilkNetGenesis -outputBlock ./channel-artifacts/genesis.block -channelID system-channel
    res=$?
    if [ $res -ne 0 ]; then
        echo "Failed to generate orderer genesis block..."
        exit 1
    fi
    echo

    configtxgen -profile MilkChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
    res=$?
    if [ $res -ne 0 ]; then
        echo "Failed to generate channel configuration transaction..."
        exit 1
    fi
    echo

    for orgmsp in partya partyb partyc; do
        configtxgen -profile MilkChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
    done
}

networkUp() {
    generateCerts
    generateChannelArtifacts

    IMAGE_TAG=$IMAGE_TAG docker-compose -f $COMPOSE_FILE up -d orderer partya partyb partyc cli

    echo Vendoring Go dependencies ...
    pushd ../chaincode
    GO111MODULE=on go mod vendor
    go list
    popd

    docker exec cli sh scripts/script.sh
}

networkDown() {
    docker-compose -f $COMPOSE_FILE down --volumes --remove-orphans
 
    # docker run -v $PWD:/tmp/first-network --rm hyperledger/fabric-tools:$IMAGETAG rm -Rf /tmp/first-network/ledgers-backup
    
    # CONTAINER_IDS=$(docker ps -aq)
    
    #TODO clean images
    rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config
}

MODE=$1
if [ "$MODE" == "up" ]; then 
    networkUp
elif [ "$MODE" == "down" ]; then
    networkDown
else
    echo "up or down, make a choice"
fi