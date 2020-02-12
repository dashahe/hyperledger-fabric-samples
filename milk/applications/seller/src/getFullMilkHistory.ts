import * as path from 'path';
import * as fs from 'fs';
import { Wallets, Gateway } from 'fabric-network';

const ccpPath = path.resolve(__dirname, "..", "gateway")

async function getFullMilkHistory(milkID: string) {
    try {
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);
    
        const userName = "Admin@partyc.example.com"

        const identity = await wallet.get(userName);
        if (!identity) {
            console.log(`can't get identity from wallet for ${userName}`);
            return;
        }

        let connectionOptions = {
            identity: userName,
            wallet: wallet,
            discovery: { enabled: false, asLocalhost: true }
        };

        let connectionProfile = JSON.parse(fs.readFileSync(path.join(ccpPath, "networkConnection.json"), 'utf8'));
    
        const gateway = new Gateway();
        await gateway.connect(connectionProfile, connectionOptions);

        const network = await gateway.getNetwork('milkchannel');
        const contract = network.getContract('seller');

        const response = await contract.submitTransaction("getFullMilkHistory", milkID);
        console.log("transaction submitted");
        console.log(`getFullMilkHistory result: ${response}`)
    
        gateway.disconnect();
    } catch (error) {
        console.error(`failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

getFullMilkHistory(
    "66666"
);