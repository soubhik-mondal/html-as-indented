const fs = require("fs");
const path = require("path");
const peggy = require("peggy");

const grammar = fs
  .readFileSync(path.resolve(__dirname, "./grammar.peggy"))
  .toString();

const parser = peggy.generate(grammar);

const testFilesPath = "../test";
const tests = fs
  .readdirSync(path.resolve(__dirname, testFilesPath))
  .map((each) => ({
    file: each,
    data: fs
      .readFileSync(path.resolve(__dirname, testFilesPath, each))
      .toString(),
  }));

for (let index in tests) {
  let output = [index, tests[index].file];
  try {
    parser.parse(tests[index].data);
    output.push(true);
  } catch (e) {
    output.push(false, e.message);
  }
  console.log(
    "Test",
    output[0],
    "(",
    output[1],
    ") :",
    output[2] ? "Success" : "Error :",
    output[2] ? "" : output[3]
  );
}
