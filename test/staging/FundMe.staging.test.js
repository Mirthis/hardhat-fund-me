const { assert } = require("chai");
const { getNamedAccounts, network, ethers } = require("hardhat");
const { developmentChains } = require("../../helper-hardat-config");

developmentChains.includes(network.name)
  ? describe.skip
  : describe("FundMe", async function () {
      let fundMe;
      let deployer;
      const sendValue = ethers.utils.parseEther("1");

      beforeEach(async function () {
        deployer = (await getNamedAccounts()).deployer;
        fundMe = await ethers.getContract("FundMe", deployer);
      });

      it("allows people to fund and withdraw", async () => {
        await fundMe.fund({ value: sendValue });
        await fundMe.withdraw();
        const endingBalance = ethers.provider.getBalance(fundMe.address);
        assert.equal(endingBalance.toString(), "0");
      });
    });
