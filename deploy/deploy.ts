import { ethers } from "ethers"
import contractData from "./artifacts/ContentMediaToken.json"
import postContractData from './artifacts/ContentMediaVoting.json'
import settlementContractData from './artifacts/ContentMediaVoting.json'
import { CONTRACT } from "./constants"
import * as fs from 'fs'
import dotenv from 'dotenv'
dotenv.config();

export const deployContract = async () => {

    console.log(process.env.PRIVATE_KEY)

    const provider = new ethers.JsonRpcProvider(CONTRACT.PROVIDED_URL);
    const wallet = new ethers.Wallet(CONTRACT.PRIVATE_KEY, provider);

    // Step 1: Deploy token contract
    const tokenFactory = new ethers.ContractFactory(contractData.abi, contractData.bytecode, wallet);
    const tokenContract = await tokenFactory.deploy(); 
    const tokenContractAddress = await tokenContract.getAddress();
    tokenContract.waitForDeployment()

    // Step 2: Deploy Post contract with token address
    const postFactory = new ethers.ContractFactory(postContractData.abi, postContractData.bytecode, wallet);
    const postContract = await postFactory.deploy(tokenContractAddress);
    const postContractAddress = await postContract.getAddress();

    // Step 3: Deploy settlement contract with token address and post contract address
    const settleFactory = new ethers.ContractFactory(settlementContractData.abi, settlementContractData.bytecode, wallet);
    const settleContract = await settleFactory.deploy(tokenContractAddress, postContractAddress);
    const settleContractAddress = await settleContract.getAddress();

    writeToFile('/', {tokenContractAddress, postContractAddress, settleContractAddress})

    console.log(`Token contract: ${tokenContractAddress}, Post contract: ${postContractAddress}, Settlement contract: ${settleContractAddress}`);

}


const writeToFile = (filePath: string, newData: any) => {
    const fileData = fs.readFileSync(filePath, 'utf8');
    const data = JSON.parse(fileData);
    data.push(newData);
    fs.writeFileSync(filePath,
        JSON.stringify(data, null, 2))
}

deployContract()