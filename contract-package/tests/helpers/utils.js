// Miscellaneous functionalities to be used in the tests.

const { keccak256, solidityPack,
  hexDataSlice, toUtf8Bytes  } = require('ethers/lib/utils');

/**
 * Looks trough a TransactionReceipt for an emitted value out from a topic name
 * and a set of position indexes defined in the solidity contract.
 * @param {TransactionReceipt} txReceipt The target transaction.
 * @param {Contract} emmiterContract The contract emitting the event.
 * @param {String} eventName The target event name.
 * @param {Number} targetArgIndex The positional index of the argument.
 * 
 * @returns Any sort of raw value from the parsed events.
 */
function getEmittedArgument (
    txReceipt,
    emmiterContract,
    eventName,
    targetArgIndex
) {
    try {
      const topicHash = emmiterContract.interface.getEventTopic(
        eventName
      );
      const output = txReceipt.logs.map(log => {
        if (log.topics[0] === topicHash) {
          let rawData = emmiterContract.interface.parseLog(
            log
          );
          return rawData.args[targetArgIndex];
        }
      });
  
      return output;
      
    } catch (err) {
      console.error(err)
    }
  }

/**
 * Mimicks the AirnodeRrpV0 encoding for request parameters
 * when calling `makeFullRequest` function.
 * @param {String} airnodeAddress 
 * @param {String} fulfillAddress 
 * @param {String} fulfillFunctionId
 * 
 * @returns {String} The encoded request parameters. 
 */
function encodeFulfillmentParameters (
  airnodeAddress,
  fulfillAddress,
  fulfillFunctionId
) {
  const packedData = solidityPack(
    ['address', 'address', 'bytes4'],
    [airnodeAddress, fulfillAddress, fulfillFunctionId]
  );
  return keccak256(packedData)
}

/**
 * Creates a Solidity `bytes4` selector from a function string selector.
 * @param {String} functionSelector The full function selector as string.
 * 
 * @returns A string representing the function selector in `bytes4` format.
 */
function getBytesSelector (
  functionSelector
) {
  return hexDataSlice(
    keccak256(
      toUtf8Bytes(
        functionSelector
      )
    ),
    0,
    4
  );
}

module.exports = {
    getEmittedArgument,
    encodeFulfillmentParameters,
    getBytesSelector
}
