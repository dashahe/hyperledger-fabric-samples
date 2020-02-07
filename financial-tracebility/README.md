# 金融溯源项目

## 背景


## 区块链网络

## 网络搭建和启动

### 1. identity相关文件生成
首先生成模板：`cryptogen showtemplate > cryto-config.yaml`，然后修改[cryto-config.yaml](./cryto-config.yaml)文件来符合我们的区块链网络设定，包括org和org有多少peer。

然后`cryptogen generate --config=./crypto-config.yaml --output="crypto-config"`生成相关文件到`crypto-config/`目录下。

### 2. orderer gensisi block 和 channel transaction
拷贝一个模板过来[configtx.yaml](./configtx.yaml)`，然后根据自己的组织架构来修改配置，主要就是organizations和profiles。另外，可以根据自己的要求来修改policies，来配置访问权限。

- `configtxgen -profile TestOrgOrdererGenesis -channelID finan-channel -outputBlock ./channel-artifacts/genesis.block` 生成orderer genesis block。

- `configtxgen -profile TestOrgChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID finan-channel` 生成 channel transaction。

- `configtxgen -profile TestOrgChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchor.tx -channelID finan-channel -asOrg Org1MSP` 等三条命令分别生成anchor transaction，用来在org1、2、3的peer上面安装channel的anchor。

## 3. docker compose file编写
docker compose包括orderer, peer, cli, ca和couchdb等几个容器。

## chaincode


## application