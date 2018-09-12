const User = require('../model/user.model');
const Loan = require('../model/loan.model');

module.exports = class UserDomain {
  static getByID(userID, next) {
    User.getByID(userID).then(res => next(res));
  }

  static signIn(name, next) {
    User.signIn(name, (new Date()).getTime()).then(res => next(res));
  }

  static getLoansHistory(userID, next) {
    Loan.filter(null, userID, 0).then(data => next(data));
  }

  static getPendingLoan(userID, next) {
    User.getPendingLoan(userID).then(data => next(data));
  }

  static getLoansToApprove(userID, next) {    
    User.getLoansToApprove(userID).then(res => next(res));
  }

  static verifyToken(userID, token, next) {
    User.getByID(userID).then(user => {
      if (user && user.token == token) next(true); // User verified
      else next(false); // User not verified
    });
  }
}