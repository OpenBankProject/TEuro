const { expect } = require("chai");
const { ethers } = require("hardhat");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { getEmittedArgument,
    encodeFulfillmentParameters,
    getBytesSelector } = require("../helpers/utils");
const { UserStatus } = require("../helpers/dataTypes");

/**
 * Behavioral logic for testing the Validator contract.
 * @param {function()} setupFixture Initial fixture to be run prior to all tests.
 */
async function shouldBehaveLikeValidator (
    setupFixture
) {
    context("Success", () => {
        context("setRequestParameters", () => {
            it("should set request parameters", async () => {
                const { airnodeAddress, sponsorAddress, derivedAddress,
                    endpointId, validator } = await loadFixture(setupFixture);

                // The expected values are the default values.
                expect ( await validator.airnode() )
                    .to.equal(ethers.constants.AddressZero);
                expect ( await validator.getEndpointId() )
                    .to.equal(ethers.constants.HashZero);
                expect ( await validator.getDerivedAddress() )
                    .to.equal(ethers.constants.AddressZero);
                expect ( await validator.getSponsorAddress() )
                    .to.equal(ethers.constants.AddressZero);

                await expect ( validator.setRequestParameters(
                        airnodeAddress,
                        endpointId,
                        derivedAddress.address,
                        sponsorAddress.address
                    ) )
                    .to.emit(validator, "SetRequestParameters")

                // The expected values are the same as the ones set in the
                // function call.
                expect( await validator.airnode() )
                    .to.equal(airnodeAddress);
                expect ( await validator.getEndpointId() )
                    .to.equal(endpointId);
                expect ( await validator.getDerivedAddress() )
                    .to.equal(derivedAddress.address);
                expect ( await validator.getSponsorAddress() )
                    .to.equal(sponsorAddress.address);
            });
        });

        context("callAirnode", () => {
            it("should call airnode", async () => {
                const { airnodeAddress, sponsorAddress, 
                    derivedAddress, endpointId, validator,
                    userAddress } = await loadFixture(setupFixture);

                await validator.setRequestParameters(
                    airnodeAddress,
                    endpointId,
                    derivedAddress.address,
                    sponsorAddress.address
                );

                // Now we test that we can call the function and
                // that the event is emitted.
                await expect ( validator.callAirnode(
                        userAddress.address,
                        1
                    ) )
                    .to.emit(validator, "UpdateRequest")
                    .withArgs(
                        anyValue,
                        userAddress.address,
                        1
                    )
            });

            it("should update mappings with request ID", async () => {
                const { airnodeAddress, sponsorAddress, 
                    derivedAddress, userAddress, 
                    endpointId, validator, 
                    mockAirnodeRrpV0 } = await loadFixture(setupFixture);

                await validator.setRequestParameters(
                    airnodeAddress,
                    endpointId,
                    derivedAddress.address,
                    sponsorAddress.address
                );
                
                // Now we test that the mappings are updated correctly.
                const callTx = await (await validator.callAirnode(
                    userAddress.address,
                    1
                )).wait();

                const requestId = await getEmittedArgument(
                    callTx,
                    validator,
                    "UpdateRequest",
                    0
                );

                expect( await validator.getUserByRequestId(requestId[0]) )
                    .to.equal(userAddress.address);
                expect ( await validator.fulfillments(requestId[0]) )
                    .to.equal(true);

                const callbackSelector = getBytesSelector(
                    "updateUserStatus(bytes32,bytes)"
                );
                const expectedRequestParameters = encodeFulfillmentParameters(
                    airnodeAddress,
                    validator.address,
                    callbackSelector
                );

                // Here we check that the protocol contract correctly received
                // the request.
                expect ( await mockAirnodeRrpV0.requestIdToFulfillmentParameters(
                    requestId[0]
                ) )
                    .to.equal(expectedRequestParameters);
            });
        });

        context("updateUserStatus", async () => {
            it("should update user status", async () => {
                const { airnodeAddress, sponsorAddress, 
                    derivedAddress, userAddress, 
                    endpointId, validator, 
                    mockAirnodeRrpV0 } = await loadFixture(setupFixture);
                
                // We replicate some steps to setup the workflow of the request.
                await validator.setRequestParameters(
                    airnodeAddress,
                    endpointId,
                    derivedAddress.address,
                    sponsorAddress.address
                );
                const callTx = await (await validator.callAirnode(
                    userAddress.address,
                    1
                )).wait();
                const requestId = await getEmittedArgument(
                    callTx,
                    validator,
                    "UpdateRequest",
                    0
                );
                const callbackSelector = getBytesSelector(
                    "updateUserStatus(bytes32,bytes)"
                );

                // First we validate that the user status is false.
                expect ( await validator.getUserStatus(userAddress.address) )
                    .to.equal(false);

                // Now we test that we can call the function and
                // that the event is emitted.
                const expectedData = ethers.utils.defaultAbiCoder.encode(
                    ["bool"], 
                    [true]
                )
                await expect ( mockAirnodeRrpV0.fulfill(
                        requestId[0],
                        airnodeAddress,
                        validator.address,
                        callbackSelector,
                        expectedData,
                        []
                    ) )
                    .to.emit(mockAirnodeRrpV0, "FulfilledRequest")
                    .withArgs(
                        airnodeAddress,
                        requestId[0],
                        expectedData
                    )
                    .to.emit(validator, "UserStatusUpdated")
                    .withArgs(
                        userAddress.address,
                        UserStatus["VALID"]
                    );

                // Finally we verify that user status has changed.
                expect ( await validator.getUserStatus(userAddress.address) )
                    .to.equal(true);
            });
        });
    });
}

module.exports = {
    shouldBehaveLikeValidator
}
