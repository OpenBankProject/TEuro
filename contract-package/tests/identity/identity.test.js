// Testing spec for "Identity.sol" contract.

const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers, 
    artifacts, upgrades } = require("hardhat");
const { shouldBehaveLikeIdentity } = require("./identity.behavior");
const { getAccounts, 
    getEventsLibrary } = require("../helpers/fixtures");

/**
 * This is a fixture definition for the Identity Contract.
 * It will help us in initializing the contract instance in every test.
 */
async function setupFixture() {
    // Get signers from local node.
    const { owner, user, ops, extra } = await loadFixture(getAccounts);
    const { events } = await loadFixture(getEventsLibrary);

    // Create factory from artifacts.
    const identityArtifact = await artifacts.readArtifact("Identity");
    const issuerArtifact = await artifacts.readArtifact("ClaimIssuer");

    const identityFactory = await ethers.getContractFactory(
        identityArtifact.abi,
        identityArtifact.bytecode,
        owner
    );
    const issuerFactory = await ethers.getContractFactory(
        issuerArtifact.abi,
        issuerArtifact.bytecode,
        owner
    );

    // Deploy mock identity contract.
    const identity = await upgrades.deployProxy(
        identityFactory,
        [
            owner.address
        ],
        {
            initializer: "initialize",
            kind: "uups"
        }
    );
    await identity.deployed();

    const issuer = await upgrades.deployProxy(
        issuerFactory,
        [
            owner.address
        ],
        {
            initialize: "initialize",
            kind: "uups"
        }
    );
    await issuer.deployed();

    // Create keys. NOTE: Hash encode address with `keccak256` to
    // pad over 32 bytes, which is the expected type for the function.
    const abiCoder = ethers.utils.defaultAbiCoder;
    const userKey = ethers.utils.keccak256(
        abiCoder.encode(['address'], [user.address])
    );

    // Key for user.
    await identity.addKey(
        userKey,
        2,
        1
    );
    // Key for operator.
    await identity.addKey(
        userKey,
        3,
        1
    );

    // Generate claims.
    claimTopic = 2;
    claimId = ethers.utils.keccak256(
        abiCoder.encode(
            ['address', 'uint256'],
            [issuer.address, claimTopic]
        )
    );
    // Assuming output as True from KYC as example.
    claimData = abiCoder.encode(
        ['bool'],
        [true]
    );
    // Defined structure for `dataHash` on validation of claims
    // in `ClaimIssuer` contract.
    claimSignature = await ops.signMessage(
        ethers.utils.arrayify(
            ethers.utils.keccak256(
                abiCoder.encode(
                    ['address', 'uint256', 'bytes'],
                    [identity.address, claimTopic, claimData]
                )
            )
        )
    )

    const userClaim = {
        id: claimId,
        topic: claimTopic,
        scheme: 1,
        data: claimData,
        signature: claimSignature,
        uri: 'https://example.com'
    }

    return {
        identity, issuer, events,
        owner, user, ops, extra,
        userClaim
    }
}

describe("Identity", () => {
    describe("Deployment", () => {
        context("Initializer", () => {
            it("should revert on already deployed identity", async () => {
                const { identity,
                    owner } = await loadFixture(setupFixture);

                await expect (
                    identity.initialize(owner.address)
                ).to.be.revertedWith(
                    "Initializable: contract is already initialized"
                );
            });

            it("Should return implementation version", async () => {
                const { identity } = await loadFixture(setupFixture);

                await expect (
                    await identity.version()
                ).to.equal(
                    1
                );
            });
        });
    })

    describe("Behavior", async () => {
        await shouldBehaveLikeIdentity(setupFixture);
    });
});
