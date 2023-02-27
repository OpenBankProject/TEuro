const express = require("express");
const { User, sequelize } = require("./models.js");

const app = express();
const userRouter = express.Router();
const identityRouter = express.Router()

app.use( express.json() );
app.use("/user", userRouter);
app.use("/identity", identityRouter);

app.get("/", (_, res) => {
  res.status(200).send("TCoin Validation API");
});

userRouter.post("/", async (req, res) => {
    const { legalName, 
        dateOfBirth } = req.body;

    if (!legalName || !dateOfBirth) {
        res.status(400).send({
            message: "Missing parameters"
        });
    }
    
    try {
        const user = await User.create({
            legalName: legalName,
            dateOfBirth: dateOfBirth
        });

        res.status(201).send({
            userId: user.id
        });

    } catch (err) {
        console.log(`\n/user: ${err}\n`);
        res.status(500).send();
    }
});

userRouter.get("/status", async (req, res) => {
    const { id } = req.query;
    
    try {
        const user = await User.findAll({
            where: { 
                id: id
            }
        });

        if (user.length > 0) {
            res.status(200).send({
                status: user[0].dataValues.valid
            });
        } else {
            res.status(400).send({
                message: "User not found"
            });
        }
    } catch (err) {
        console.error(`\n/user/status: ${err}\n`)
        res.status(500).send();
    }
});

identityRouter.post("/", async (req, res) => {
    const { id } = req.query;
    const { documentName, 
        countryName, issueDate,
        placeName, expirityDate } = req.body;

    if (!(id && documentName && countryName 
        && issueDate && placeName && expirityDate)) {
            res.status(400).send({
                message: "Missing parameters"
        });
    }

    try {
        const count = await User.update({
            identityDocument: documentName,
            identityDocumentCountry: countryName,
            issueDate: issueDate,
            issuePlace: placeName,
            expirityDate: expirityDate,
            valid: true
        }, {
            where: { id: id }
        });

        if (count > 0) {
            res.status(200).send();
        } else {
            res.status(400).send({
                message: "User not found"
            });
        }
    } catch (err) {
        console.error(`\n/identity: ${err}\n`);
        res.status(500).send();
    }
});

app.listen(
    8000, 
    async () => 
    {   
        console.log("\nStarting server...\n");
        await sequelize.sync({ force: true });
        console.log("\nApp listening on port 8000!\n")
});
