const config = require('../../config/database.config.json');
const sql = require('mssql');

module.exports = class Loan {
  constructor() {
    this.loanID = null;
    this.userID = null;
    this.termID = null;
    this.amount = null;
    this.interestAmount = null;
    this.approved = null;
    this.createdAt = null;
    this.pending = null;

    this.user = null;
    this.term = null;
  }

  static map(data) { // Maps data into a instance of class
    let instance = null;
    if (data) {
      instance = new Loan()
      instance.loanID = data.loanID;
      instance.userID = data.userID;
      instance.termID = data.termID;
      instance.amount = data.amount;
      instance.interestAmount = data.interestAmount;
      instance.approved = data.approved;
      instance.createdAt = data.createdAt;
      instance.pending = data.approved;
      if (data.mapUser) {
        const User = require('./user.model');
        let user = new User();
        user.userID = data.userID;
        user.name = data.userName;
        instance.user = user;
      }
      if (data.mapTerm) {
        const Term = require('./term.model');
        let term = new Term();
        term.termID = data.termID;  
        term.interest = data.interest;  
        term.payments = data.payments;  
        instance.term = term;
      }
    }    
    return instance;
  }

  static mapArray(data) { // Maps data into a array of instances of class
    let array = [];
    for (const item of data) {
      array.push(Loan.map(item));
    }
    return array;
  }

  static filter(loanID, userID, pending) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('loanID', sql.Int, loanID)
        .input('userID', sql.Int, userID)
        .input('pending', sql.Bit, pending)
        .execute(`proc_loans_filter`);
    }).then(data => Loan.mapArray(data.recordset))
    .catch(err => console.log(err));
  }

  static approve(loanID) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('loanID', sql.Int, loanID)
        .execute(`proc_loans_approve`);
    }).then(data => true)
    .catch(err => console.log(err));
  }

  static deny(loanID) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('loanID', sql.Int, loanID)
        .execute(`proc_loans_deny`);
    }).then(data => true)
    .catch(err => console.log(err));
  }

  /**
   * Load users that was apprved a loan.
   * @param {number} loanID Loan ID to read approvers
   */
  static getApprovers(loanID) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('loanID', sql.Int, loanID)
        .execute(`proc_loan_approvers_read`);
    });
  }

  add() {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('userID', sql.Int, this.userID)
        .input('termID', sql.SmallInt, this.termID)
        .input('amount', sql.Numeric(10,2), this.amount)
        .input('interestAmount', sql.Numeric(5,2), this.interestAmount)
        .execute(`proc_loans_add`);
    }).then(data => {      
      return data.recordset[0].loanID;
    }).catch(err => console.log(err));
  }
}