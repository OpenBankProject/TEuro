const { Sequelize, DataTypes } = require('sequelize');
const { getEnvKey } = require('./utils.js');

const sequelize = new Sequelize (
    getEnvKey('DB_URI'), 
    {
        dialect: 'sqlite',
    },
);

const User = sequelize.define('User', {
    username: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    valid: DataTypes.BOOLEAN,
});

module.exports = {
    sequelize,
    User
}
