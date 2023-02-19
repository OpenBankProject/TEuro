const express = require("express");
const { User } = require("./models.js");

const app = express();

app.use( express.json() );

app.get("/", (_, res) => {
  res.status(200).send("Healthy!");
});


app.get("/status/:id", async (req, res) => {
    const { id: userId } = req.params;
    
    const user = await User.findAll({
        where: { 
            id: userId
        }
    });

    res.status(200).send({
        status: user.valid
    });
});

app.post("/create", async (req, res) => {
    const { username } = req.body;

    if (!username) {
        res.status(400).send({
            message: "Missing user id"
        });
    }
    
    const user = await User.create({
        username,
        valid: false
    });

    res.status(200).send({
        id: user.id
    });
});

app.post("/approve/:id", async (req, res) => {
    const { id: userId } = req.params;
    
    await User.update({
        valid: true
    }, {
        where: { id: userId }
    });

    res.status(200);
});

app.listen(
    80, 
    async () => 
    {   
        console.log("Starting server...");
        await sequelize.sync();
        console.log("Mock API listening on port 80!")
});
