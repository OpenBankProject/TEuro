const { expect } = require("chai");
const { ethers, artifacts } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { shouldBehaveLikeERC20 } = require("./TEuro.behavior");

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

    const tEuroArtifact = await artifacts.readArtifact("TEuro");
    const tEuroFactory = await ethers.getContractFactory(
        tEuroArtifact.abi,
        tEuroArtifact.bytecode,
        owner
    );

    const tEuro = await tEuroFactory.deploy(
        tokenName,
        tokenSymbol
    );
    
    return { tEuro, owner, sender, reciever };
}

describe("tEuro", () => {
    describe("Parameter testing", () => {
        context("ERC20 related", () => {
            it("Should return expected constructor arguments", async() => {
                const { tEuro } = await loadFixture(setupFixture);

                expect( await tEuro.name() )
                    .to.equal("Test ERC20");
                expect ( await tEuro.symbol() )
                    .to.equal("TERC20");
                expect ( await tEuro.decimals() )
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
