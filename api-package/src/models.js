const { Sequelize, DataTypes } = require('sequelize');

const sequelize = new Sequelize ({
        dialect: 'sqlite',
        storage: "../test.db"
    });

const User = sequelize.define('User', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        allowNull: false,
        primaryKey: true
    },
    username: {
        type: DataTypes.UUID,
        allowNull: false,
        unique: true,
        defaultValue: DataTypes.UUIDV4
    },
    legalName: {
        type: DataTypes.STRING,
        allowNull: false
    },
    dateOfBirth: {
        type: DataTypes.DATE,
        allowNull: false
    },
    identityDocument: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    identityDocumentCountry: {
        type: DataTypes.STRING,
        allowNull: true
    },
    issueDate: {
        type: DataTypes.DATE,
        allowNull: true
    },
    issuePlace: {
        type: DataTypes.STRING,
        allowNull: true
    },
    expirityDate: {
        type: DataTypes.DATE,
        allowNull: true
    },
    valid: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false
    }
});

module.exports = {
    sequelize,
    User
}
