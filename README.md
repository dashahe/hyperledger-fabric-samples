# hyperledger-fabric-samples
Some samples used for practicing block chain using hyperledger fabric.

## content
[牛奶食品溯源](./milk)
[金融溯源](./financial-tracebility)

## TODO
- 加入tests
- 拆解network.sh脚本，将步骤更加细致化，方便调试，避免每次都需要重启docker container
- 加入CA，使用etcd raft来做共识
- 封装一下底层api，避免每次都需要自己来手写json marshal
