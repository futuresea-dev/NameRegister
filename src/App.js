import React from 'react';
import './App.css';
import { UseWalletProvider } from 'use-wallet'

import rpcInfo from './Info/rpc.json';
import WalletInfo from './components/WalletInfo';


function App() {

    return (
        <React.Fragment>
            <UseWalletProvider
                chainId={rpcInfo.mainnet.chainId}
                connectors={{
                    walletconnect: { rpcUrl: rpcInfo.mainnet.rpc },
                }}
            >
                <WalletInfo/>
            </UseWalletProvider>
        </React.Fragment>
    );
}

export default App;
