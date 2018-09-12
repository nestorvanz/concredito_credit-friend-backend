const User = require('../model/user.model');
const Loan = require('../model/loan.model');
const LoanApprover = require('../model/loan-approver.model');

module.exports = class LoanDomain {
  static signIn(name, next) {
    User.signIn(name, (new Date()).getTime()).then(res => next(res));
  }

  static add(userID, termID, amount, interestAmount, next) {
    let loan = new Loan();
    loan.userID = userID;
    loan.termID = termID;
    loan.amount = amount;
    loan.interestAmount = interestAmount;
    loan.add().then(loanID => next(loanID));
  }

  static approve(loanID, next) {
    Loan.approve(loanID).then(result => next(result));
  }

  static deny(loanID, next) {
    Loan.deny(loanID).then(result => next(result));
  }

  static getApprovers(loanID, next) {
    LoanApprover.getByLoanID(loanID).then(users => next(users));
  }

  static getPendingLoan(userID, next) {
    User.getPendingLoan(userID).then(res => next(res));
  }
}