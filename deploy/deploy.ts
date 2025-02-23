import { ethers } from "ethers";
import contractData from "./artifacts/ContentMediaToken.json";
import postContractData from "./artifacts/ContentMediaVoting.json";
import settlementContractData from "./artifacts/ContentMediaSettlement.json";
import { CONTRACT } from "./constants";
import { writeToFile } from "./utils/writeContract";

export const deployContract = async () => {
  const provider = new ethers.JsonRpcProvider(CONTRACT.PROVIDED_URL);
  const wallet = new ethers.Wallet(CONTRACT.PRIVATE_KEY, provider);

  console.log("Deploying Contracts...");

  // Step 1: Deploy token contract
  const tokenFactory = new ethers.ContractFactory(
    contractData.abi,
    contractData.bytecode,
    wallet
  );
  const tokenContract = await tokenFactory.deploy();
  const tokenContractAddress = await tokenContract.getAddress();
  await tokenContract.waitForDeployment();

  console.log("Deployed token contract: ", tokenContractAddress);

  // Step 2: Deploy Post contract with token address
  const postFactory = new ethers.ContractFactory(
    postContractData.abi,
    postContractData.bytecode,
    wallet
  );
  const postContract = await postFactory.deploy(tokenContractAddress);
  const postContractAddress = await postContract.getAddress();
  await postContract.waitForDeployment();

  console.log("Deployed post contract: ", postContractAddress);

  // Step 3: Deploy settlement contract with token address and post contract address
  const settleFactory = new ethers.ContractFactory(
    settlementContractData.abi,
    settlementContractData.bytecode,
    wallet
  );
  const settleContract = await settleFactory.deploy(
    tokenContractAddress,
    postContractAddress
  );
  const settleContractAddress = await settleContract.getAddress();
  await settleContract.waitForDeployment();

  console.log("Deployed settlement contract: ", settleContractAddress);
  console.log("Adding settlement role to token contract...");

  // Step 4: Grant settlement role to settlement contract
  //@ts-ignore
  await tokenContract.setSettlementContract(settleContractAddress);

  console.log("Added settlement role to token contract");
  writeToFile("deployedContracts.json", {
    TOKEN: tokenContractAddress,
    POST: postContractAddress,
    SETTLE: settleContractAddress,
  });

  console.log("Deployment successful!");
};

deployContract();
