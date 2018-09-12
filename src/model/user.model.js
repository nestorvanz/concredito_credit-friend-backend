const config = require('../../config/database.config.json');
const sql = require('mssql');
const Loan = require('./loan.model');

module.exports = class User {
  constructor() {
    this.userID = null;
    this.name = null;
    this.token = null;
  }

  static map(data) {
    let instance = new User();
    instance.userID = data.userID;
    instance.name = data.name;
    instance.token = data.token;
    return instance;
  }

  static mapArray(data) {
    let array = [];
    for (const item of data) {
      array.push(User.map(item));
    }
    return array;
  }

  static signIn(name, token) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('name', sql.VarChar(50), name)
        .input('token', sql.Text, token)
        .execute(`proc_users_sign_in`);
    }).then(res => {
      return res.recordset.length ?
        User.map(res.recordset[0]) : null;
    }).catch(err => {
      console.log(err);
    });
  }

  static getByID(userID) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('userID', sql.Int, userID)
        .execute(`proc_users_read`);
    }).then(res => {
      return res.recordset.length ?
        User.map(res.recordset[0]) : null;
    }).catch(err => {
      console.log(err);
    });
  }

  static getLoans(userID) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('userID', sql.Int, userID)
        .execute(`proc_loans_to_approve`);
    }).then(res => {
      let rs = res.recordset;
      return Loan.mapArray(res.recordset);
    }).catch(err => {
      console.log(err);
    });
  }

  static getLoansToApprove(userID) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('userID', sql.Int, userID)
        .execute(`proc_loans_to_approve`);
    }).then(data => Loan.mapArray(data.recordset))
    .catch(err => console.log(err));
  }

  static getPendingLoan(userID) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('userID', sql.Int, userID)
        .execute(`proc_loans_pending`);
    }).then(res => {
      return Loan.map(res.recordset[0]);
    }).catch(err => {
      console.log(err);
    });
  }

  static getLoansHistory(userID) {
    return sql.connect(config.creditFriends).then(pool => {
      return pool.request()
        .input('userID', sql.Int, userID)
        .execute(`proc_loans_user_history`);
    });
  }
}