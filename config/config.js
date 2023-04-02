const dotenv = require("dotenv");
dotenv.config({ path: __dirname + "/../.env"});

module.exports = {
    config: {
        bscApiKey: process.env.BSCSCAN_API_KEY
    }
};
