// Test specification for the Validator contract.

const { artifacts, ethers } = require("hardhat");
const { shouldBehaveLikeValidator } = require("./Validator.behavior");

/**
 * Initial fixture to be run prior to all tests.
 * @returns 
 */
async function setupFixture() {
    const [ owner, sponsorAddress, derivedAddress,
        userAddress ] = await ethers.getSigners();
    const validatorArtifact = await artifacts.readArtifact("MockValidator");
    const mockAirnodeRrpV0Artifact = await artifacts.readArtifact("MockAirnodeRrpV0");
    const validatorFactory = await ethers.getContractFactory(
        validatorArtifact.abi,
        validatorArtifact.bytecode,
        owner
    );
    const mockAirnodeRrpV0Factory = await ethers.getContractFactory(
        mockAirnodeRrpV0Artifact.abi,
        mockAirnodeRrpV0Artifact.bytecode,
        owner
    );
    const mockAirnodeRrpV0 = await mockAirnodeRrpV0Factory.deploy();
    const validator = await validatorFactory.deploy(
        mockAirnodeRrpV0.address
    );

    const airnodeAddress = "0x87761496d42Ca9Af9944BC6916A682C5f4888671"
    const endpointId = "0x38fe8e80ef717f403a567df8c9c98bbf671fc565ec120b472563961cff3b09e3";
    
    return { owner, sponsorAddress, airnodeAddress, derivedAddress,
        userAddress, validator, mockAirnodeRrpV0, endpointId };
}

describe("Validator", async () => {
    describe("Behavior", async () => {
        await shouldBehaveLikeValidator(setupFixture);
    })
});