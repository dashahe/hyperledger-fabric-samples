#! /bin/bash

cryptogen generate --config=./crypto-config.yaml --output="crypto-config"

# orderer genesis
configtxgen -profile TestOrgOrdererGenesis -channelID finan-channel -outputBlock ./channel-artifacts/genesis.block

# channel transation
configtxgen -profile TestOrgChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID finan-channel

# anchor transation for org1, org2, org3
configtxgen -profile TestOrgChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchor.tx -channelID finan-channel -asOrg Org1MSP
configtxgen -profile TestOrgChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchor.tx -channelID finan-channel -asOrg Org2MSP
configtxgen -profile TestOrgChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchor.tx -channelID finan-channel -asOrg Org3MSP