const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const ethers = require('ethers');

// Sample contributors with addresses and amounts
const contributorsData = [
  { address: "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", amount: 100 },
  { address: "0x79091E9bDd1190fdc71B13795bFeB7Ee551CD859", amount: 200 },
];

// Function to generate leaf nodes
const getLeaf = (address, amount) =>
  keccak256(ethers.solidityPacked(["address", "uint256"], [address, amount]));

// Generate leaves
const leaves = contributorsData.map(({ address, amount }) => getLeaf(address, amount));

// Create the Merkle tree
const merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// Get Merkle Root
const merkleRoot = merkleTree.getRoot().toString('hex');
console.log("🔹 Merkle Root:", "0x" + merkleRoot);

// Pick a user to generate a proof
const userAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"; // Change this to verify different users
const userAmount = 100;

// Generate the leaf for this user
const leaf = getLeaf(userAddress, userAmount);

// Generate the Merkle Proof
const proof = merkleTree.getHexProof(leaf);
console.log("🔹 Merkle Proof:", proof);

