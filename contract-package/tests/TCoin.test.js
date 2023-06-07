const { expect } = require("chai");
const { ethers, artifacts } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { shouldBehaveLikeERC20 } = require("./TCoin.behavior");

/**
 * This is a fixture definition for the MockERC20 Artifact.
 * It will help us in initializing the contract instance in every test.
 * 
 * @returns An object with 3 signature wallets,
 * one which is the owner of the deployed contract.
 * In addition to the actual instance of a deployed contract.
 */
async function setupFixture() {
    const tokenName = "Test ERC20";
    const tokenSymbol = "TERC20";
        
    const [ owner, sender, reciever ] = await ethers.getSigners();

    const tCoinArtifact = await artifacts.readArtifact("TCoin");
    const tCoinFactory = await ethers.getContractFactory(
        tCoinArtifact.abi,
        tCoinArtifact.bytecode,
        owner
    );

    const tCoin = await tCoinFactory.deploy(
        tokenName,
        tokenSymbol
    );
    
    return { tCoin, owner, sender, reciever };
}

describe("TCoin", () => {
    describe("Parameter testing", () => {
        context("ERC20 related", () => {
            it("Should return expected constructor arguments", async() => {
                const { tCoin } = await loadFixture(setupFixture);

                expect( await tCoin.name() )
                    .to.equal("Test ERC20");
                expect ( await tCoin.symbol() )
                    .to.equal("TERC20");
                expect ( await tCoin.decimals() )
                    .to.equal(18)
            });
        });
    });

    describe("Behavior testing", () => {
        context("Behave like ERC20", async () => {
            await shouldBehaveLikeERC20(setupFixture);
        });
    });
});
