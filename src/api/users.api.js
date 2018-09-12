module.exports = function() {
  const router = require('express').Router();
  const route = '/users';
  const UserDomain = require('../domain/user.domain')

  router.post(`${route}/sign-in`, function (req, res) {
    UserDomain.signIn(req.body.name, data => res.send(data));
  });

  router.get(`${route}/:id`, function (req, res) {
    UserDomain.getByID(req.params.id, data => res.send(data));
  });

  router.get(`${route}/:id/loans-history`, function (req, res) {
    UserDomain.getLoansHistory(req.params.id, data => res.json(data));
  });

  router.get(`${route}/:id/pending-loan`, function (req, res) {
    UserDomain.getPendingLoan(req.params.id, data => res.json(data));
  });

  router.get(`${route}/:id/loans-to-approve`, function (req, res) {    
    UserDomain.getLoansToApprove(req.params.id, data => res.send(data));
  });

  router.post(`${route}/:id/verify`, function (req, res) {
    UserDomain.verifyToken(req.params.id, req.body.token, data => res.send(data));
  });
  
  return router;
}