const config = require('../../config/database.config.json');
const sql = require('mssql');
const User = require('./user.model');

module.exports = class LoanApprover {
  constructor() {
    this.loanID = null;
    this.userID = null;
  }

  static map(data) {
    let instance = null;
    if (data) {
      instance = new LoanApprover();
      instance.loanID = data.loanID;
      instance.userID = data.userID;
    }
    return instance;
  }

  static mapArray(data) {
    let array = [];
    for (const item of data) array.push(Loan.map(item));
    return array;
  }

  static getByLoanID(loanID) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('loanID', sql.Numeric(10,2), loanID)
        .execute(`proc_loan_approvers_read`);
    }).then(res => {
      return User.mapArray(res.recordset);
    }).catch(err => {
      console.log(err);
    });
  }
}