import { expect } from "chai";
import { ethers } from "hardhat";
import {
  ContentMediaVoting,
  ContentMediaToken,
  ContentMediaSettlement,
} from "../typechain-types";
import keccak256 from "keccak256";

describe("ContentMediaVoting", function () {
  let contentMediaVoting: ContentMediaVoting;
  let contentMediaToken: ContentMediaToken;
  let contentMediaSettlement: ContentMediaSettlement;
  let owner: any;
  let account1: any;
  let account2: any;
  let account3: any;

  const DAILY_MINT_AMOUNT = 100_000;

  before(async function () {
    [owner, account1, account2, account3] = await ethers.getSigners();

    const ContentMediaTokenFactory = await ethers.getContractFactory(
      "ContentMediaToken"
    );
    contentMediaToken =
      (await ContentMediaTokenFactory.deploy()) as ContentMediaToken;

    const ContentMediaVotingFactory = await ethers.getContractFactory(
      "ContentMediaVoting"
    );
    contentMediaVoting = (await ContentMediaVotingFactory.deploy(
      contentMediaToken.getAddress()
    )) as ContentMediaVoting;

    const ContentMediaSettlementFactory = await ethers.getContractFactory(
      "ContentMediaSettlement"
    );
    contentMediaSettlement = (await ContentMediaSettlementFactory.deploy(
      contentMediaToken.getAddress(),
      contentMediaVoting.getAddress()
    )) as ContentMediaSettlement;

    await contentMediaToken.setSettlementContract(
      contentMediaSettlement.getAddress()
    );
  });

  describe("Post Creation", function () {
    it("Should create a post and emit PostCreated event", async function () {
      const contentHash = "QmTestHash";
      const tags = "blockchain,AI";

      await expect(contentMediaVoting.createPost(contentHash, tags))
        .to.emit(contentMediaVoting, "PostCreated")
        .withArgs(1, owner.address, contentHash, tags);
    });
  });

  describe("Multiple Post Voting", function () {
    it("Should create 3 posts by 3 different accounts and vote on them", async function () {
      await contentMediaVoting.connect(account1).createPost("QmPost1", "tag1");
      await contentMediaVoting.connect(account2).createPost("QmPost2", "tag2");
      await contentMediaVoting.connect(account3).createPost("QmPost3", "tag3");

      const vote1 = 500000;
      const vote2 = 49999;
      const vote3 = 9;

      await contentMediaVoting.vote(2, vote1); // 1 post is already in above tests so the index is 2
      await contentMediaVoting.vote(3, vote2);
      await contentMediaVoting.vote(4, vote3);

      expect(await contentMediaVoting.getPostScore(2)).to.equal(vote1);
      expect(await contentMediaVoting.getPostScore(3)).to.equal(vote2);
      expect(await contentMediaVoting.getPostScore(4)).to.equal(vote3);
    });
  });

  describe("Token Claiming", function () {
    it("Should allow a poster to claim their earned tokens", async function () {
      const currentDay = await contentMediaSettlement.getCurrentDay();

      // Travel time by 1 day as we can only settle after a day
      await ethers.provider.send("evm_increaseTime", [86400]);
      await ethers.provider.send("evm_mine", []);

      await contentMediaSettlement.settleDay(currentDay);

      await contentMediaSettlement.connect(account1).claimRewards();
      await contentMediaSettlement.connect(account2).claimRewards();

      console.log(
        await contentMediaToken.balanceOf(account1.address),
        await contentMediaToken.balanceOf(account2.address),
        "after claiming"
      );

      expect(
        await contentMediaToken.balanceOf(account1.address)
      ).to.be.greaterThan(0);

      expect(
        (await contentMediaToken.balanceOf(account1.address)) +
          (await contentMediaToken.balanceOf(account2.address)) +
          (await contentMediaToken.balanceOf(account3.address))
      ).to.be.lessThan(DAILY_MINT_AMOUNT);
    });
  });

  describe("Multi-Day Voting and Claiming", function () {
    it("Should allow voting on multiple days and claim rewards correctly", async function () {
      const currentDay2 = await contentMediaSettlement.getCurrentDay();

      await contentMediaVoting.vote(4, 1000);

      // This is day 3
      await ethers.provider.send("evm_increaseTime", [86400]);
      await ethers.provider.send("evm_mine", []);

      await contentMediaSettlement.settleDay(currentDay2);

      console.log(
        "active days of account 3",
        await contentMediaVoting.getUserVoteDays(account3)
      );

      console.log(
        "Claimable amount for account 3 on day 2: ",
        await contentMediaSettlement.getClaimableAmount(account3.address)
      );

      await contentMediaSettlement.connect(account2).claimRewards();
    });
  });
});
