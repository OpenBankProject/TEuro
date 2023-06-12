const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { parseEther } = require("ethers/lib/utils");

/**
 * Behavioral logic for testing the TCoin contract.
 * @param {function()} setupFixture Initial fixture to be run prior to all tests.
 */
async function shouldBehaveLikeERC20 (
    setupFixture
) {
    context("Success", () => {
        it("Should correctly update and show changes in balances", async() => {
            it("Should return 0 when the requested account has no tokens", async() => {
                const { tCoin, sender } = await loadFixture(setupFixture);

                expect ( await tCoin.balanceOf(sender.address) )
                    .to.equal(0);
            });

            it("Should return the correct balance for a token holder address", async() => {
                const { tCoin, owner } = await loadFixture(setupFixture);

                expect ( await tCoin.balanceOf(owner.address) )
                    .to.equal(initalSupply);
            })
        });

        it("Should correctly transfer funds and reverted as expected", async() => {
            it("Should revert when sender has not enough balance", async() => {
                const { tCoin, sender } = await loadFixture(setupFixture);
                const fifteenEthers = parseEther("15.0");

                await expect ( tCoin.transfer(
                    sender.address,
                    fifteenEthers
                ) )
                    .to.be.revertedWith(
                        "ERC20: transfer amount exceeds balance"
                    );
            });

            it("Should revert if destination is address `0`", async() => {
                const { tCoin } = await loadFixture(setupFixture);
                const oneEther = parseEther('1.0');

                await expect ( tCoin.transfer(
                    ethers.constants.AddressZero,
                    oneEther
                ) )
                    .to.be.revertedWith(
                        "ERC20: transfer to the zero address"
                    );
            });

            it("Should correctly transfer otherwise", async() => {
                const { tCoin, owner, reciever } = await loadFixture(setupFixture);
                const oneEther = parseEther('1.0');

                await expect ( await tCoin.transfer(
                    reciever.address,
                    oneEther
                ) )
                    .to.emit(tCoin, "Transfer")
                    .withArgs(owner.address, reciever.address, oneEther);
            });
        });
    });
}

module.exports = {
    shouldBehaveLikeERC20
}
