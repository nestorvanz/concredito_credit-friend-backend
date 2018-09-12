const sql = require('mssql');
module.exports = class DatabaseComponent {
  constructor(conf) {
    // this.host = conf.host;
    // this.port = conf.port;
    // this.database = conf.database;
    // this.user = conf.user;
    // this.pass = conf.pass;

    return sql.connect(`mssql://${conf.user}:${conf.pass}@${conf.host}/${conf.database}`);
  }

  // async connect() {
    
  // }
}