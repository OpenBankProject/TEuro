const { expect } = require("chai");
const { ethers, artifacts } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { parseEther } = require("ethers/lib/utils");

const tokenName = "Test ERC20";
const tokenSymbol = "TERC20";
const initalSupply = parseEther("10.0");

describe("ERC20 Testing Suite", async () => {

    /**
     * This is a fixture definition for the MockERC20 Artifact.
     * It will help us in initializing the contract instance in every test.
     * 
     * @returns An object with 3 signature wallets,
     * one which is the owner of the deployed contract.
     * In addition to the actual instance of a deployed contract.
     */
    async function setupFixture() {
        const tokenArtifact = await artifacts.readArtifact("MockERC20");
        const [ owner, sender, reciever ] = await ethers.getSigners();
        const tokenFactory = await ethers.getContractFactory(
            tokenArtifact.abi,
            tokenArtifact.bytecode,
            owner
        );
        const tokenContract = await tokenFactory.deploy(
            tokenName,
            tokenSymbol,
            initalSupply
        );
        
        return { tokenContract, owner, sender, reciever };
    }

    describe("Should show the token properties", async() => {
        it("Should return the given name at initialization", async() => {
            const { tokenContract } = await loadFixture(setupFixture);

            expect( await tokenContract.name() )
                .to.equal(tokenName);
        });

        it("Should return the given symbol at initialization", async() => {
            const { tokenContract } = await loadFixture(setupFixture);

            expect ( await tokenContract.symbol() )
                .to.equal(tokenSymbol);
        });

        it("Should show the default decimals value", async() => {
            const { tokenContract } = await loadFixture(setupFixture);

            expect ( await tokenContract.decimals() )
                .to.equal(18);
        });

        it("Should show initial supply as the provided value at initialization", async() => {
            const { tokenContract } = await loadFixture(setupFixture);

            expect ( await tokenContract.totalSupply() )
                .to.equal(initalSupply);
        });
    });

    describe("Should correctly update and show changes in balances", async() => {
        it("Should return 0 when the requested account has no tokens", async() => {
            const { tokenContract, sender } = await loadFixture(setupFixture);

            expect ( await tokenContract.balanceOf(sender.address) )
                .to.equal(0);
        });

        it("Should return the correct balance for a token holder address", async() => {
            const { tokenContract, owner } = await loadFixture(setupFixture);

            expect ( await tokenContract.balanceOf(owner.address) )
                .to.equal(initalSupply);
        })
    });

    describe("Should correctly transfer funds and reverted as expected", async() => {
        it("Should revert when sender has not enough balance", async() => {
            const { tokenContract, sender } = await loadFixture(setupFixture);
            const fifteenEthers = parseEther("15.0");

            await expect ( tokenContract.transfer(
                sender.address,
                fifteenEthers
            ) )
                .to.be.revertedWith(
                    "ERC20: transfer amount exceeds balance"
                );
        });

        it("Should revert if destination is address `0`", async() => {
            const { tokenContract } = await loadFixture(setupFixture);
            const oneEther = parseEther('1.0');

            await expect ( tokenContract.transfer(
                ethers.constants.AddressZero,
                oneEther
            ) )
                .to.be.revertedWith(
                    "ERC20: transfer to the zero address"
                );
        });

        it("Should correctly transfer otherwise", async() => {
            const { tokenContract, owner, reciever } = await loadFixture(setupFixture);
            const oneEther = parseEther('1.0');

            await expect ( await tokenContract.transfer(
                reciever.address,
                oneEther
            ) )
                .to.emit(tokenContract, "Transfer")
                .withArgs(owner.address, reciever.address, oneEther);
        })
    })
});
