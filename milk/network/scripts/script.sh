#! /bin/bash

CHANNEL_NAME="milkchannel"
CC_SRC_PATH=$GOPATH/src/milkcc/
CC_NAME=milkcc

####################### functions ########################
createChannel() {
	CORE_PEER_LOCALMSPID=partya
	CORE_PEER_ADDRESS=milk-partya:7051
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/Admin@partya.example.com/msp
	echo "===================== Creating channel ===================== "
	peer channel create -o milk-orderer:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx
	echo "===================== Channel created ===================== "
}

joinChannel() {
	for org in partya partyb partyc
	do
		CORE_PEER_LOCALMSPID=$org
		CORE_PEER_ADDRESS=milk-$org:7051
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$org.example.com/users/Admin@$org.example.com/msp
		echo "===================== Org $org joining channel ===================== "
		peer channel join -b $CHANNEL_NAME.block -o milk-orderer:7050
		echo "===================== Channel joined ===================== "
	done
}

packageChaincode() {
    CORE_PEER_LOCALMSPID=partya
    CORE_PEER_ADDRESS=milk-partya:7051
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/Admin@partya.example.com/msp
    echo "===================== Creating chaincode package ===================== "
    peer lifecycle chaincode package $CC_NAME.tar.gz --path ${CC_SRC_PATH} --lang golang --label ${CC_NAME}_1
    echo "===================== Chaincode packaged ===================== "
}

installChaincode() {
	for org in partya partyb partyc
	do
		CORE_PEER_LOCALMSPID=$org
		CORE_PEER_ADDRESS=milk-$org:7051
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$org.example.com/users/Admin@$org.example.com/msp
		echo "===================== Org $org installing chaincode ===================== "
		peer lifecycle chaincode install $CC_NAME.tar.gz
		echo "===================== Org $org chaincode installed ===================== "
	done
}

getChaincodePackageID() {
    CORE_PEER_LOCALMSPID=partya
    CORE_PEER_ADDRESS=milk-partya:7051
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/Admin@partya.example.com/msp
    echo "===================== Query chaincode package ID ===================== "
    peer lifecycle chaincode queryinstalled >&log.txt
    export PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; p;}' log.txt`
    echo "packgeID=$PACKAGE_ID"
}

approveChaincode() {
	for org in partya partyb partyc
	do
		CORE_PEER_LOCALMSPID=$org
		CORE_PEER_ADDRESS=milk-$org:7051
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$org.example.com/users/Admin@$org.example.com/msp
		echo "===================== Approving chaincode definition for $org ===================== "
		peer lifecycle chaincode approveformyorg -o milk-orderer:7050 --channelID $CHANNEL_NAME --signature-policy "OR('partya.peer','partyb.peer','partyc.peer')" --name $CC_NAME --version 1 --init-required --sequence 1 --package-id ${PACKAGE_ID} --waitForEvent
		echo "===================== Chaincode definition approved ===================== "
	done
}

checkCommitReadiness() {
    for org in partya partyb partyc
	do
		export CORE_PEER_LOCALMSPID=$org
		export CORE_PEER_ADDRESS=irs-$org:7051
		export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$org.example.com/users/Admin@$org.example.com/msp
		checkCommitReadiness "\"partya\": true" "\"partyb\": true" "\"partyc\": true"
	done
}

commitChaincode() {
	CORE_PEER_LOCALMSPID=partya
	CORE_PEER_ADDRESS=milk-partya:7051
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/Admin@partya.example.com/msp
    echo "===================== Commiting chaincode definition to channel ===================== "
    peer lifecycle chaincode commit -o milk-orderer:7050 --channelID $CHANNEL_NAME --signature-policy "OR('partya.peer','partyb.peer','partyc.peer')" --name $CC_NAME --version 1 --init-required --sequence 1 --peerAddresses milk-partya:7051 --peerAddresses milk-partyb:7051 --peerAddresses milk-partyc:7051 --waitForEvent
    echo "===================== Chaincode definition committed ===================== "
}

initChaincode() {
	CORE_PEER_LOCALMSPID=partya
	CORE_PEER_ADDRESS=milk-partya:7051
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/Admin@partya.example.com/msp
    echo "===================== Initializing chaincode ===================== "
    peer chaincode invoke -o milk-orderer:7050 --isInit -C $CHANNEL_NAME --waitForEvent -n $CC_NAME --peerAddresses milk-partya:7051 --peerAddresses milk-partyb:7051 --peerAddresses milk-partyc:7051 -c '{"Args":["init"]}'
    echo "===================== Chaincode initialized ===================== "
}

getState() {
	CORE_PEER_LOCALMSPID=partya
	CORE_PEER_ADDRESS=milk-partya:7051
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/User1@partya.example.com/msp
	echo "===================== Invoking chaincode ===================== "
	peer chaincode invoke -o milk-orderer:7050 -C $CHANNEL_NAME --waitForEvent -n $CC_NAME --peerAddresses milk-partya:7051 --peerAddresses milk-partyb:7051 -c '{"Args":["getState", "this_is_key"]}'
	echo "===================== Chaincode invoked ===================== "
}

putState() {
	CORE_PEER_LOCALMSPID=partya
	CORE_PEER_ADDRESS=milk-partya:7051
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/User1@partya.example.com/msp
	echo "===================== Invoking chaincode ===================== "
	peer chaincode invoke -o milk-orderer:7050 -C $CHANNEL_NAME --waitForEvent -n $CC_NAME --peerAddresses milk-partya:7051 --peerAddresses milk-partyb:7051 -c '{"Args":["putState", "this_is_key", "this is value man"]}'
	echo "===================== Chaincode invoked ===================== "
}

####################### commands ########################

## create channel
echo
echo "create channel..."
createChannel

## join channel
echo
echo "join channel..."
joinChannel

## package chaincode
echo
echo "packaging chaincode..."
packageChaincode

## install chaincode
echo
echo "installing chaincode"
installChaincode

## query chaincode package ID
echo
echo "querying package id"
getChaincodePackageID

## approve chaincode
echo
echo "approving chaincode"
approveChaincode

. scripts/check-commit-readiness.sh

## commit chaincode
echo
echo "committing chaincode"
commitChaincode

# TODO: maybe not need init
## init chaincode
echo
echo "initializing chaincode"
initChaincode

## put state in ledger
echo
echo "putting state"
putState

## get state in ledger
echo
echo "getState"
getState

## end
echo "create channel and install chaincode finished successfully!"