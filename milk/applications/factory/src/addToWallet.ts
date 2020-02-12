import { Wallets, X509Identity } from 'fabric-network';
import * as fs from 'fs';
import * as path from 'path';

const configPath = path.resolve(__dirname, '..', '..', '..', 'network', 'crypto-config')

export async function addToWallet() {
    try {
        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);
        
        const credPath = path.join(configPath, '/peerOrganizations/partyb.example.com/users/Admin@partyb.example.com')
        const certificate = fs.readFileSync(path.join(credPath, '/msp/signcerts/Admin@partyb.example.com-cert.pem')).toString();
        const privateKey = fs.readFileSync(path.join(credPath, '/msp/keystore/priv_sk')).toString();

        const identityLabel = 'Admin@partyb.example.com';

        // Check to see if we've already enrolled the admin user.
        const identity = {
            credentials: {
                certificate,
                privateKey
            },
            mspId: 'partyb',
            type: 'X.509'
        }

        await wallet.put(identityLabel, identity);
        
        console.log('Successfully enrolled admin user "admin" and imported it into the wallet');

    } catch (error) {
        console.error(`Failed to enroll admin user "admin": ${error}`);
        process.exit(1);
    }
}

addToWallet();