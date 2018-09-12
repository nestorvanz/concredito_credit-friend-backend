module.exports = function() {
  const router = require('express').Router();
  const route = '/terms';
  const TermDomain = require('../domain/term.domain')

  router.get(`${route}`, function (req, res) {
    TermDomain.read(data => res.send(data));
  });

  router.get(`${route}/:id`, function (req, res) {
    TermDomain.getByID(req.params.id, data => res.send(data));
  });

  return router;
}