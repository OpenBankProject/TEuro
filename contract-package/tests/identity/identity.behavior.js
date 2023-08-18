// Behavior testing for identity contract.

const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getEmittedArgument } = require("../helpers/utils");

async function shouldBehaveLikeIdentity (
    setupFixture
) {
    describe("Key Management", () => {
        context("View Functions", () => {
            it("getKey", async() => {
                const { identity,
                    user } = await loadFixture(setupFixture);
                const userKey = ethers.utils.keccak256(
                    ethers.utils.defaultAbiCoder.encode(
                        ['address'],
                        [user.address]
                    )
                );
                const keyData =  await identity.getKey(userKey);

                expect ( keyData.purposes 
                ).to.deep.equal(
                    [2, 3]
                );
                expect (
                    keyData.keyType
                ).to.equal(
                    1
                );
                expect (
                    keyData.key
                ).to.equal(
                    userKey
                );
            });

            it("getKeyPurposes", async () => {
                const { identity,
                    user } = await loadFixture(setupFixture);

                const userKey = ethers.utils.keccak256(
                    ethers.utils.defaultAbiCoder.encode(
                        ['address'],
                        [user.address]
                    )
                );

                expect ( 
                    await identity.getKeyPurposes(
                        userKey
                    )
                ).to.deep.equal(
                    [2, 3]
                );
            });

            it("getKeysByPurpose", async () => {
                const { identity,
                    user } = await loadFixture(setupFixture);

                const userKey = ethers.utils.keccak256(
                    ethers.utils.defaultAbiCoder.encode(
                        ['address'],
                        [user.address]
                    )
                );

                expect (
                    await identity.getKeysByPurpose(
                        2
                    )
                ).to.deep.equal(
                    [userKey]
                );

                expect (
                    await identity.getKeysByPurpose(
                        3
                    )
                ).to.deep.equal(
                    [userKey]
                );
            });

            context("keyHasPurpose", () => {
                it("should return true for valid purpose", async () => {
                    const { identity,
                        user } = await loadFixture(setupFixture);

                    const userKey = ethers.utils.keccak256(
                        ethers.utils.defaultAbiCoder.encode(
                            ['address'],
                            [user.address]
                        )
                    );

                    expect (
                        await identity.keyHasPurpose(
                            userKey,
                            2
                        )
                    ).to.equal(
                        true
                    );
                    expect (
                        await identity.keyHasPurpose(
                            userKey,
                            3
                        )
                    ).to.equal(
                        true
                    );
                });

                it("should return false for invalid purpose", async () => {
                    const { identity,
                        user } = await loadFixture(setupFixture);

                    const userKey = ethers.utils.keccak256(
                        ethers.utils.defaultAbiCoder.encode(
                            ['address'],
                            [user.address]
                        )
                    );

                    expect (
                        await identity.keyHasPurpose(
                            userKey,
                            1
                        )
                    ).to.equal(
                        false
                    );
                });

                it("should return true if management key even if purpose is not set", async () => {
                    const { identity,
                        owner } = await loadFixture(setupFixture);

                    const ownerKey = ethers.utils.keccak256(
                        ethers.utils.defaultAbiCoder.encode(
                            ['address'],
                            [owner.address]
                        )
                    );

                    expect (
                        await identity.keyHasPurpose(
                            ownerKey,
                            3
                        )
                    ).to.equal(
                        true
                    );
                });
            });
        });

        context("Core Logic", () => {
            context("addKey", () => {
                it("Should revert on not manager key", async () => {
                    const { identity,
                        user } = await loadFixture(setupFixture);

                    const userIdentity = await identity.connect(user);
                    const extraKey = ethers.utils.keccak256(
                        ethers.utils.defaultAbiCoder.encode(
                            ['address'],
                            [user.address]
                        )
                    );

                    await expect (
                        userIdentity.addKey(
                            extraKey,
                            1,
                            1
                        )
                    ).to.be.revertedWithCustomError(
                        userIdentity,
                        "UnauthorizedCaller"
                    );
                });

                it("Should add purpose to existing key", async () => {
                    const { identity,
                        user } = await loadFixture(setupFixture);

                    const userKey = ethers.utils.keccak256(
                        ethers.utils.defaultAbiCoder.encode(
                            ['address'],
                            [user.address]
                        )
                    );
                    
                    // Validate key has no purpose
                    expect (
                        await identity.keyHasPurpose(
                            userKey,
                            4
                        )
                    ).to.equal(
                        false
                    );

                    // Add purpose to key
                    await identity.addKey(
                        userKey,
                        4,
                        1
                    )

                    // Validate key has purpose
                    expect (
                        await identity.keyHasPurpose(
                            userKey,
                            4
                        )
                    ).to.equal(
                        true
                    );
                });

                it("Should add new key if non existent", async () => {
                    const { identity, events,
                        extra } = await loadFixture(setupFixture);
                    
                    const extraKey = ethers.utils.keccak256(
                        ethers.utils.defaultAbiCoder.encode(
                            ['address'],
                            [extra.address]
                        )
                    );

                    // Validate key does not exist
                    const initialKeyData = await identity.getKey(
                        extraKey
                    );

                    expect (
                        initialKeyData.purposes
                    ).to.deep.equal(
                        []
                    );
                    expect (
                        initialKeyData.keyType
                    ).to.equal(
                        0
                    );
                    expect (
                        initialKeyData.key
                    ).to.equal(
                        ethers.constants.HashZero
                    );

                    // Add key
                    const tx = await (
                        await identity.addKey(
                            extraKey,
                            2,
                            1
                        )
                    ).wait();

                    const addedKey = await getEmittedArgument(
                        tx,
                        events,
                        "KeyAdded",
                        0
                    );

                    expect (
                        addedKey[0]
                    ).to.equal(
                        extraKey
                    );

                    // Validate key exists
                    const finalKeyData = await identity.getKey(
                        extraKey
                    );

                    expect (
                        finalKeyData.purposes
                    ).to.deep.equal(
                        [2]
                    );
                    expect (
                        finalKeyData.keyType
                    ).to.equal(
                        1
                    );
                    expect (
                        finalKeyData.key
                    ).to.equal(
                        extraKey
                    );
                });

                it("Should revert if key already has purpose", async () => {
                    const { identity,
                        user } = await loadFixture(setupFixture);
                    
                    const userKey = ethers.utils.keccak256(
                        ethers.utils.defaultAbiCoder.encode(
                            ['address'],
                            [user.address]
                        )
                    );

                    await expect (
                        identity.addKey(
                            userKey,
                            2,
                            1
                        )
                    ).to.be.revertedWithCustomError(
                        identity,
                        "KeyAlreadyHavePurpose"
                    );
                });
            });

            context("removeKey", () => {
                it("Should revert on not manager key", async () => {
                    const { identity,
                        user } = await loadFixture(setupFixture);

                    const userIdentity = await identity.connect(user);
                    const userKey = ethers.utils.keccak256(
                        ethers.utils.defaultAbiCoder.encode(
                            ['address'],
                            [user.address]
                        )
                    );

                    await expect (
                        userIdentity.removeKey(
                            userKey,
                            2
                        )
                    ).to.be.revertedWithCustomError(
                        userIdentity,
                        "UnauthorizedCaller"
                    );
                });

                it("Should remove purpose from existing key", async () => {
                    const { identity, events,
                        user } = await loadFixture(setupFixture);

                    const userKey = ethers.utils.keccak256(
                        ethers.utils.defaultAbiCoder.encode(
                            ['address'],
                            [user.address]
                        )
                    );
                    
                    // Validate key has purpose
                    expect (
                        await identity.keyHasPurpose(
                            userKey,
                            2
                        )
                    ).to.equal(
                        true
                    );

                    // Remove purpose from key
                    const tx = await (
                        await identity.removeKey(
                            userKey,
                            2
                        )
                    ).wait();
                    const removedKey = await getEmittedArgument(
                        tx,
                        events,
                        "KeyRemoved",
                        0
                    );
                    expect (
                        removedKey[0]
                    ).to.equal(
                        userKey
                    );

                    // Validate key has no purpose
                    expect (
                        await identity.keyHasPurpose(
                            userKey,
                            2
                        )
                    ).to.equal(
                        false
                    );
                });

                it("Should remove key if no purpose left", async () => {
                    // const { identity, events,
                    //     user } = await loadFixture(setupFixture);

                    // const userKey = ethers.utils.keccak256(
                    //     ethers.utils.defaultAbiCoder.encode(
                    //         ['address'],
                    //         [user.address]
                    //     )
                    // );
                    
                    // // Validate key has purpose
                    // expect (
                    //     await identity.keyHasPurpose(
                    //         userKey,
                    //         2
                    //     )
                    // ).to.equal(
                    //     true
                    // );

                    // // Remove purpose from key
                    // const tx = await (
                    //     await identity.removeKey(
                    //         userKey,
                    //         2
                    //     )
                    // ).wait();
                    // const removedKey = await getEmittedArgument(
                    //     tx,
                    //     events,
                    //     "KeyRemoved",
                    //     0
                    // );
                    // expect (
                    //     removedKey[0]
                    // ).to.equal(
                    //     userKey
                    // );

                    // // Validate key has no purpose
                    // expect (
                    //     await identity.keyHasPurpose(
                    //         userKey,
                    //         2
                    //     )
                    // ).to.equal(
                    //     false
                    // );

                    // // Validate key does not exist
                    // const finalKeyData = await identity.getKey(
                    //     userKey
                    // );

                    // expect (
                    //     finalKeyData.purposes
                    // ).to.deep.equal(
                    //     []
                    // );
                    // expect (
                    //     finalKeyData.keyType
                    // ).to.equal(
                    //     0
                    // );
                    // expect (
                    //     finalKeyData.key
                    // ).to.equal(
                    //     ethers.constants.HashZero
                    // );
                });
            });
        });
    });
}

module.exports = {
    shouldBehaveLikeIdentity
}
