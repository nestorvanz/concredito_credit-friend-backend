module.exports = function() {
  const router = require('express').Router();
  const route = '/loans';
  const LoanDomain = require('../domain/loan.domain')

  router.post(route, (req, res) => {
    LoanDomain.add(
      req.body.userID,
      req.body.termID,
      req.body.amount,
      req.body.interestAmount,
      loanID => res.json(loanID)
    );
  });

  router.get(`${route}/:id/approvers`, (req, res) => {
    LoanDomain.getApprovers(req.params.id, users => res.send(users));
  });

  router.post(`${route}/:id/approve`, (req, res) => {
    LoanDomain.approve(req.params.id, result => res.json(result));
  });

  router.post(`${route}/:id/deny`, (req, res) => {
    LoanDomain.deny(req.params.id, result => res.json(result));
  });
  
  return router;
}