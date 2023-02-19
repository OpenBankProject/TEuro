const getEnvKey = (key) => {
    require("dotenv").config();
    return process.env[key] || undefined;
}

module.exports = {
    getEnvKey
}