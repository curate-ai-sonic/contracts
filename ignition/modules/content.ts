import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SocialMediaDeployment = buildModule("ContentDeployment", (m: any) => {
  // Deploy SocialMediaToken
  const token = m.contract("ContentMediaToken");

  console.log(token)

  // Deploy SocialMediaVoting with token address
  const voting = m.contract("ContentMediaVoting", [token]);

  // Deploy SocialMediaSettlement with token and voting contract addresses
  const settlement = m.contract("ContentMediaSettlement", [token, voting]);

  return { token, voting, settlement };
});

export default SocialMediaDeployment;
