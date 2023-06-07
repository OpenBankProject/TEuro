const fs = require("fs");
const { config } = require("dotenv");
const { Wallet } = require("ethers");
const { JsonRpcProvider } = require("@ethersproject/providers");

/**
 * Get the wallet private from the .env file
 * 
 * @returns {string} The private key of the wallet
 */
function getWallet() {
  config();
  return process.env.PRIVATE_KEY;
}

/**
 * Get the provider for the given network.
 * @param {string} network The network to get the provider for.
 * 
 * @returns {JsonRpcProvider} The provider instance.
 */
function getProvider(
    network
) {
    const pk = getWallet();
    const provider =  new JsonRpcProvider(
        process.env[`${network.toUpperCase()}_URL`] || ""
    );
    return new Wallet(pk, provider);
}

/**
 * Loads a JSON file from the given path.
 * @param {String} file The path where the file is located.
 * 
 * @returns {Object} The parsed JSON data.
 */
function loadJsonFile(
    file
) {
    const appRoot = require("app-root-path");
    try {
        const data = fs.readFileSync(`${appRoot}${file[0] === "/" ? file : "/" + file}`);
        return JSON.parse(data);
    } catch (err) {
        return {};
    }   
};

/**
 * Writes a JSON file to the given path given some javascript data.
 * @param {Object} data 
 * @param {String} path 
 * @param {String} mode 
 */
function writeJsonFile(
    data,
    path,
    mode
) {
    const appRoot = require("app-root-path");
    const fileMode = mode || "w";
    let prevData;
    if (fileMode === "a") {
        try {
            prevData = loadJsonFile(path);
        } catch (err) {
            console.error(`writeJsonFile: ${err.message}`);
        }
    } else if (fileMode === "w") {
        prevData = {}
    } else {
        throw Error("Invalid mode. Must be 'w' or 'a'.");
    }

    if (typeof prevData !== "object") {
        throw Error("Invalid data. Must be an object.");
    }
    const parsedData = JSON.stringify(
        { ...prevData, ...data },
        null,
        2
    );

    fs.writeFileSync(`${appRoot}/${path}`, parsedData);
    console.log(`Filed written to: ${appRoot}/${path}`);
};

module.exports = {
    getWallet,
    getProvider,
    loadJsonFile,
    writeJsonFile
}