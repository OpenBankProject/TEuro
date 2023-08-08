// Fixtures shared across the package

const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");

/**
 * Returns a list of funded accounts from the local node.
 * 
 * @returns {Promise<ethers.Signer[]>}. A list of signers.
 */
async function getAccounts() {
    const [ owner, user, ops, extra ] = await ethers.getSigners();
    return {
        owner,
        user,
        ops,
        extra
    };
}

/**
 * Returns an instance from the Events Library contract.
 * 
 * @returns {Promise<ethers.Contract>} The deployed Events library.
 */
async function getEventsLibrary () {
    const { owner } = await loadFixture(getAccounts);

    const eventsArtifact = await artifacts.readArtifact("Events");
    const eventsFactory = await ethers.getContractFactory(
        eventsArtifact.abi,
        eventsArtifact.bytecode,
        owner
    );

    const events = await eventsFactory.deploy();
    await events.deployed();

    return {
        events
    }
}

module.exports = {
    getAccounts,
    getEventsLibrary
}
