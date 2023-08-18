const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { parseEther } = require("ethers/lib/utils");

/**
 * Behavioral logic for testing the TEuro contract.
 * @param {function()} setupFixture Initial fixture to be run prior to all tests.
 */
async function shouldBehaveLikeERC20 (
    setupFixture
) {
    context("Success", () => {
        it("Should correctly update and show changes in balances", async() => {
            it("Should return 0 when the requested account has no tokens", async() => {
                const { tEuro, sender } = await loadFixture(setupFixture);

                expect ( await tEuro.balanceOf(sender.address) )
                    .to.equal(0);
            });

            it("Should return the correct balance for a token holder address", async() => {
                const { tEuro, owner } = await loadFixture(setupFixture);

                expect ( await tEuro.balanceOf(owner.address) )
                    .to.equal(initalSupply);
            })
        });

        it("Should correctly transfer funds and reverted as expected", async() => {
            it("Should revert when sender has not enough balance", async() => {
                const { tEuro, sender } = await loadFixture(setupFixture);
                const fifteenEthers = parseEther("15.0");

                await expect ( tEuro.transfer(
                    sender.address,
                    fifteenEthers
                ) )
                    .to.be.revertedWith(
                        "ERC20: transfer amount exceeds balance"
                    );
            });

            it("Should revert if destination is address `0`", async() => {
                const { tEuro } = await loadFixture(setupFixture);
                const oneEther = parseEther('1.0');

                await expect ( tEuro.transfer(
                    ethers.constants.AddressZero,
                    oneEther
                ) )
                    .to.be.revertedWith(
                        "ERC20: transfer to the zero address"
                    );
            });

            it("Should correctly transfer otherwise", async() => {
                const { tEuro, owner, reciever } = await loadFixture(setupFixture);
                const oneEther = parseEther('1.0');

                await expect ( await tEuro.transfer(
                    reciever.address,
                    oneEther
                ) )
                    .to.emit(tEuro, "Transfer")
                    .withArgs(owner.address, reciever.address, oneEther);
            });
        });
    });
}

module.exports = {
    shouldBehaveLikeERC20
}
