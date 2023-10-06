const fs = require("fs");
const path = require("path");
const peggy = require("peggy");

module.exports = peggy.generate(
  fs.readFileSync(path.resolve(__dirname, "./grammar.peggy")).toString()
);
