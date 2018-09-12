const config = require('../../config/database.config.json');
const sql = require('mssql');

module.exports = class Term {
  constructor() {
    this.termID = null,
    this.payments = null,
    this.interest = null
  }

  static map(data) {
    let instance = null;
    if (data) {
      instance = new Term();
      instance.termID = data.termID;
      instance.payments = data.payments;
      instance.interest = data.interest;
    }
    return instance;
  }

  static mapArray(data) {
    let array = [];
    for (let i = 0; i < data.length; i++) {
      array.push(Term.map(data[i]));
    }
    return array;
  }

  static read() {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('termID', sql.Numeric(10,2), null)
        .execute(`proc_terms_read`);
    }).then(res => {
      return Term.mapArray(res.recordset);
    }).catch(err => {
      console.log(err);
    });
  }

  static getByID(termID) {
    return new sql.ConnectionPool(config.creditFriends).connect().then(pool => {
      return pool.request()
        .input('termID', sql.Numeric(10,2), termID)
        .execute(`proc_terms_read`);
    }).then(res => {
      return Term.map(res.recordset[0]);
    }).catch(err => {
      console.log(err);
    });
  }
}