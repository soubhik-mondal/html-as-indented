const fs = require("fs");

const params = require("minimist")(process.argv.slice(2), {
  alias: {
    input: "i",
    output: "o",
  },
  default: {
    output: "",
  },
});

if (!params.input) {
  console.error("Input file not specified.");
  process.exit(1);
}

if (Array.isArray(params.input)) {
  console.error("Too many input files specified.");
  process.exit(1);
}

if (Array.isArray(params.output)) {
  console.error("Too many output files specified.");
  process.exit(1);
}

let inputFile;
try {
  inputFile = fs.readFileSync(params.input).toString();
} catch (e) {
  if (e.code === "ENOENT") {
    console.error("Input file not found.");
    process.exit(1);
  } else {
    throw e;
  }
}

const output = require('./parser').parse(inputFile);

if (!params.output) {
  console.log(output);
} else {
  fs.writeFileSync(params.output, output);
}
