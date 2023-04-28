// Functionalities related with Airnode packages.

const { deriveEndpointId } = require("@api3/airnode-admin");

/**
 * Exports the endpoint ids derived from a set of given API parameters
 * using the API3 package.
 * @param {string} title The title of the API.
 * @param {Array<String>} endpointNames The set of endpoint names.
 * @param {string} path The path where to save a file with the output.
 */
async function deriveEndpoints (
    title,
    endpointNames,
    path
) {
    let derivedEndpoints = [];

    for (let i in endpointNames) {
        let result = {
            name: endpointNames[i],
            address: await deriveEndpointId(
                title,
                endpointNames[i]
            )
        }
        derivedEndpoints.push(result);
    }

    writeJsonFile(
        derivedEndpoints,
        path,
        "w"
    );
}

/**
 * Executes the workflow to derive the endpoint ids.
 */
async function exportEndpoints () {
    const title = 'tCoinValidation';
    const endpointNames = [
        'userStatus',
        'userRoot',
        'identityRoot',
        'root'
    ];
    const path = 'apiEndpoints.json';

    await deriveEndpoints(title, endpointNames, path);
}

exportEndpoints();
