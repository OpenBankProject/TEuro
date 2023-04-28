// Miscelaneous utility functions shared across the package.

const fs = require("fs");

/**
 * Loads a JSON file from a given path.
 * 
 * @param path String to the file path.
 * 
 * @returns The JSON file as an object.
 */
export function loadJsonFile(path) {
    try {
        const appRoot = require("app-root-path");
        let filePath = `${appRoot}${path[0] === "/" ? path : "/" + path}`;
        console.log(`Loading file from: ${filePath}...\n`);
        return JSON.parse(
            fs.readFileSync(
                filePath,
                "utf8"
            )
        );
    } catch (err) {
        console.error(`loadJsonFile: ${err}\n`);
    }
}

/**
 * Writes or Appends to a JSON File the given data.
 * 
 * @param data The data to be used for the file, 
 * @param path The location to write or append the data,
 * @param mode (optional) - If "a" appends the data, else "w" to overwrite. Defaults to "w".
 * 
 * @remarks The parent root of the file should already exists. 
 * If we use the following path: "./exampleDir/exampleFile.json" 
 * then "./exampleDir/" should exists, else you'll get an error.
 */
export function writeJsonFile(
    data,
    path,
    mode = "w"
) {
    try {
        const appRoot = require("app-root-path");
        let filePath = `${appRoot}${path[0] === "/" ? path : "/" + path}`;
        let prevData;

        if (mode === "a") {
            prevData = loadJsonFile(path);
        } else if (mode === "w") {
            prevData = {};
        } else {
            throw Error(`Invalid mode: ${mode}\n`);
        }

        const parsedData = JSON.stringify(
            { ...prevData, ...data },
            null,
            2
        );

        console.log(`Writing file to: ${filePath}...\n`);
        fs.writeFileSync(
            filePath,
            parsedData
        );
    } catch (err) {
        console.error(`writeJsonFile: ${err}\n`);
    }
}
