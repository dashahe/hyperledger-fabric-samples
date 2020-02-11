#! /bin/bash

packageChaincode() {
    CC_NAME=$1
    CC_SRC_PATH=$2
    CORE_PEER_LOCALMSPID=partya
    CORE_PEER_ADDRESS=milk-partya:7051
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/Admin@partya.example.com/msp
    echo "===================== Creating chaincode package ===================== "
    peer lifecycle chaincode package $CC_NAME.tar.gz --path ${CC_SRC_PATH} --lang golang --label ${CC_NAME}_1
    echo "===================== Chaincode packaged ===================== "
}

installChaincode() {
    CC_NAME=$1
    CC_SRC_PATH=$2
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
    CC_NAME=$1
    CC_SRC_PATH=$2
    CORE_PEER_LOCALMSPID=partya
    CORE_PEER_ADDRESS=milk-partya:7051
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/Admin@partya.example.com/msp
    echo "===================== Query chaincode package ID ===================== "
    peer lifecycle chaincode queryinstalled >&log.txt
    export PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; p;}' log.txt`
    echo "packgeID=$PACKAGE_ID"
}

approveChaincode() {
    CC_NAME=$1
    CC_SRC_PATH=$2
	for org in partya partyb partyc
	do
		CORE_PEER_LOCALMSPID=$org
		CORE_PEER_ADDRESS=milk-$org:7051
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$org.example.com/users/Admin@$org.example.com/msp
		echo "===================== Approving chaincode definition for $org ===================== "
		peer lifecycle chaincode approveformyorg -o milk-orderer:7050 --channelID $CHANNEL_NAME --signature-policy "OR('partya.peer','partyb.peer','partyc.peer')" --name $CC_NAME --version 1 --sequence 1 --package-id ${PACKAGE_ID} --waitForEvent
		echo "===================== Chaincode definition approved ===================== "
	done
}

checkCommitReadiness() {
    CC_NAME=$1
    CC_SRC_PATH=$2
    for org in partya partyb partyc
	do
		export CORE_PEER_LOCALMSPID=$org
		export CORE_PEER_ADDRESS=irs-$org:7051
		export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$org.example.com/users/Admin@$org.example.com/msp
		checkCommitReadiness "\"partya\": true" "\"partyb\": true" "\"partyc\": true"
	done
}

commitChaincode() {
    CC_NAME=$1
    CC_SRC_PATH=$2
	CORE_PEER_LOCALMSPID=partya
	CORE_PEER_ADDRESS=milk-partya:7051
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/Admin@partya.example.com/msp
    echo "===================== Commiting chaincode definition to channel ===================== "
    peer lifecycle chaincode commit -o milk-orderer:7050 --channelID $CHANNEL_NAME --signature-policy "OR('partya.peer','partyb.peer','partyc.peer')" --name $CC_NAME --version 1 --sequence 1 --peerAddresses milk-partya:7051 --peerAddresses milk-partyb:7051 --peerAddresses milk-partyc:7051 --waitForEvent
    echo "===================== Chaincode definition committed ===================== "
}

initChaincode() {
    CC_NAME=$1
    CC_SRC_PATH=$2
	CORE_PEER_LOCALMSPID=partya
	CORE_PEER_ADDRESS=milk-partya:7051
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/partya.example.com/users/Admin@partya.example.com/msp
    echo "===================== Initializing chaincode ===================== "
    
    peer chaincode invoke -o milk-orderer:7050 --channelID $CHANNEL_NAME  -n $CC_NAME --peerAddresses milk-partya:7051 milk-partyb:7051 milk-partyc:7051 -c '{"Args":["farm_contract:instantiate"]}' --waitForEvent
    echo "===================== Chaincode initialized ===================== "
}


chaincodeSetUp() {
    for cc in farm 
    do
        CC_SRC_PATH=$GOPATH/src/chaincode/$cc/
        CC_NAME=$cc
        
        echo 
        echo 
        echo "chaincode $cc set up now ....."

        ## package chaincode
        echo
        echo "packaging chaincode..."
        packageChaincode $CC_NAME $CC_SRC_PATH

        ## install chaincode
        echo
        echo "installing chaincode"
        installChaincode $CC_NAME $CC_SRC_PATH

        ## query chaincode package ID
        echo
        echo "querying package id"
        getChaincodePackageID $CC_NAME $CC_SRC_PATH

        ## approve chaincode
        echo
        echo "approving chaincode"
        approveChaincode $CC_NAME $CC_SRC_PATH

        . scripts/check-commit-readiness.sh

        ## commit chaincode
        echo
        echo "committing chaincode"
        commitChaincode $CC_NAME $CC_SRC_PATH

        # TODO: maybe not need init
        ## init chaincode
        echo
        echo "initializing chaincode"
        initChaincode $CC_NAME $CC_SRC_PATH

    done
}