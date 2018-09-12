module.exports = function() {
  const config = require('../config/app.config.json');

  const bodyParser = require('body-parser');
  const router = require('express').Router();
  
  router.use(bodyParser.urlencoded({"extended":"true"}));
  router.use(bodyParser.json());

  router.use(function (req, res, next) {
    res.setHeader("Access-Control-Allow-Origin", config.cors.origin);
    res.setHeader("Access-Control-Allow-Methods", config.cors.methods);
    res.setHeader("Access-Control-Allow-Headers", config.cors.headers);
    // res.setHeader("Access-Control-Allow-Credentials", config.cors.credentials);
    next();
  });
  
  router.use(require('./api/users.api')());
  router.use(require('./api/terms.api')());
  router.use(require('./api/loans.api')());

  return router;
}