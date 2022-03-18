import { useWallet } from 'use-wallet'
import React, { useEffect, useState } from 'react';
import { useStatePersist } from 'use-state-persist';

import { TextField, Button, Container, Card, CardContent } from '@material-ui/core';
import { createStyles, makeStyles } from '@material-ui/core/styles';

import Web3 from 'web3'
import networkInfo from '../Info/rpc.json';
import abi from "../Info/abi";
import keccak256 from "keccak256";

const useStyles = makeStyles((theme) =>
  createStyles({
    card: {
      display: 'flex',
      flexWrap: 'wrap',
      width: 700,
      margin: `${theme.spacing(0)} auto`,
      marginTop: theme.spacing(10)
    },
    container: {
      marginBottom: 20,
      width: '100%'
    },
    input: {
      width: '100%'
    },
    actionContainer: {
      display: 'flex',
      justifyContent: 'space-between'
    }
  })
);

export default function WalletInfo() {
  const web3 = new Web3(window.ethereum);
  const [userDisconnected, setUserDisconnected] = useStatePersist(true);
  const { account, connect, reset } = useWallet()

  const [name, setName] = useState("Tester");
  const [blockCount, setBlockCount] = useState(10);
  const [amount, setAmount] = useState("10000000000000000");

  const contractAddress = "0xcaA0b09660B78Ce7F3D5Ccfd7fA3746F50738aBb";

  const connectOrDisconnect = () => {  

    if (account) { // If connected then disconnect
      setUserDisconnected(true);
      reset();
    } else {           
      const metamaskChainId = parseInt(web3.currentProvider.chainId, 16);
      // If network is different
      if (networkInfo.mainnet.chainId != metamaskChainId) {
        window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: '0x' + (parseInt(networkInfo.mainnet.chainId)).toString(16) }],
        })
      } else { // same network then connect
        setUserDisconnected(false);
        connect('injected')
      }
    }
  }

  useEffect(() => {
    if (!account && !userDisconnected) {
      connect();
    }
  }, [account, userDisconnected])
  
  const onRegister = async () => {

    try {
      const marketplaceContract = new web3.eth.Contract(
        abi,
        contractAddress
      );
      
      const receipt = await marketplaceContract.methods.register(keccak256(name), blockCount.toString())
                  .send({gas:210000, value: amount, from: account});
  
      console.log(receipt);
    }catch(e) {
      console.log(e);
    }
  }

  const onRenew = async () => {
    try {
      const marketplaceContract = new web3.eth.Contract(
        abi,
        contractAddress
      );
      
      const receipt = await marketplaceContract.methods.renew(keccak256(name), blockCount.toString())
                  .send({gas:210000, value: amount, from: account});
  
      console.log(receipt);
    }catch(e) {
      console.log(e);
    }
  }

  const onCancel = async () => {
    try {
      const marketplaceContract = new web3.eth.Contract(
        abi,
        contractAddress
      );
      
      const receipt = await marketplaceContract.methods.cancel(keccak256(name))
                  .send({gas:210000, from: account});
  
      console.log(receipt);
    }catch(e) {
      console.log(e);
    }
  }
  
  const connectLabel = (!account ? 'Connect' : 'Disconnect');
  const classes = useStyles();

  return (
    <Card className={classes.card}>
      <CardContent style={{width: "100%"}}>
        <Container className={classes.container}>
          <TextField
              id="standard-read-only-input"
              label="Your Wallet"             
              value={account}
              className={classes.input}
              InputProps={{
                readOnly: true,
              }}
            />
          </Container>
        <Container className={classes.container}>
          <Button variant="contained" color="primary" onClick={connectOrDisconnect}>{connectLabel}</Button>
        </Container>
        <Container className={classes.container}>
          <TextField
              id="standard-read-only-input"
              label="Name"             
              value={name}
              className={classes.input}
              placeholder="0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"
              onChange={(e) => setName(e.target.value)}
            />
          </Container>
          <Container className={classes.container}>
          <TextField
              id="standard-read-only-input"
              label="Block Count"
              value={blockCount}
              className={classes.input}
              onChange={(e) => setBlockCount(e.target.value)}
            />
          </Container>
          <Container className={classes.container}>
            <TextField
              id="standard-read-only-input"
              label="amount"
              value={amount}
              className={classes.input}
              onChange={(e) => setAmount(e.target.value)}
            />
          </Container>
          <Container className={classes.actionContainer}>
            <Button variant="contained" color="primary" onClick={onRegister}>Register</Button>
            <Button variant="contained" color="primary" onClick={onRenew}>Renew</Button>
            <Button variant="contained" color="primary" onClick={onCancel}>Cancel</Button>
          </Container>
      </CardContent>
    </Card>
  );
}