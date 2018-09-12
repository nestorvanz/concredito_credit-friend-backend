const Term = require('../model/term.model');

module.exports = class TermDomain {
  static read(next) {
    Term.read().then(data => next(data));
  }

  static getByID(termID, next) {
    Term.getByID(termID).then(data => next(data));
  }
}