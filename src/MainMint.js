import { useState } from "react";
import { ethers, BigNumber } from 'ethers';
import { Box, Button, Flex } from '@chakra-ui/react';
import mccmNFT from './MccmNFT.json';
import background from "./img/background.jpg"

const mccmNFTAddress = "0xf97D2586937e021dF6Ff104572dA6a46c2E9b33d";

const MainMint = ({ accounts, setAccounts }) => {
    const [mintAmount, setMintAmount] = useState(1);
    const isConnected = Boolean(accounts[0]);

    async function connectAccount() {
        if (window.ethereum) {
            const accounts = await window.ethereum.request({
                method: "eth_requestAccounts",
            });
            setAccounts(accounts);
        }
    }

    async function handleMint() {
        if (window.ethereum) {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(
                mccmNFTAddress,
                mccmNFT.abi,
                signer
            );
            try {
                const response = await contract.mintMccmMeta(BigNumber.from(mintAmount), {
                    value: ethers.utils.parseEther((0.003 * mintAmount).toString()),
                });
                console.log('response: ', response);
            } catch (err) {
                console.log("error: ", err)
            }

        }
    }
    const handleDecrement = () => {
        if (mintAmount <= 1) return;
        setMintAmount(mintAmount - 1);
    };

    const handleIncrement = () => {
        if (mintAmount >= 10) return;
        setMintAmount(mintAmount + 1);
    };

    return (
        <Flex justify="center" align="center" height="100vh" paddingBottom="1500px">
            <Box width="520px">
                <div>
                    <h1>Mansion Cat Club！Meow～</h1>
                    <p>歡迎加入豪宅貓俱樂部！喵嗚～，讓我們一同完成心願。 </p>
                </div>
                {/* Connect */}
                {isConnected ? (
                    <Box margin="0 15px">Connected</Box>
                ) : (
                    <Button
                        background="#D6517D"
                        borderRadius="5px"
                        boxShadow="0px 2px 2px 1px #0F0F0F"
                        color="white"
                        cursor="pointer"
                        fontFamily="inherit"
                        padding="15px"
                        margin="0 15px"
                        onClick={connectAccount}
                    >
                        Connect
                    </Button>
                )}
                {isConnected ? (
                    <div>
                        <div>
                            <button onClick={handleDecrement}>-</button>
                            <input type="number" value={mintAmount} />
                            <button onClick={handleIncrement}>+</button>
                        </div>
                        <button onClick={handleMint}>Mint now</button>
                    </div>
                ) : (
                    <p>You must be connected to Mint.</p>
                )}
            </Box>
        </Flex>
    );
};


export default MainMint;