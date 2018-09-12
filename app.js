const config = require('./config/app.config.json');
const express = require('express');

const app = express();
app.use(require('./src/router')());

server = app.listen(config.port, () => console.log("App running on port: " + config.port));