# html-as-indented
**HTML but without all the angle brackets and closing tags**

> NOTE: This project is just a demonstration of how to use [peggy](https://github.com/peggyjs/peggy) to generate HTML from a template. If you are looking for HTML shorthands, use [emmet](https://github.com/emmetio/emmet), or you might also wanna check out a templating engine like [pug](https://github.com/pugjs/pug).

## How to use
```
$ node src/index.js --input "path-to-input-file" --output "path-to-output-file"
```

## Options
```
--input,  --i,  -input, -i : (Required) Path to the input file
--output, --o, -output, -o : Path to the output file, default is STDOUT
```

## How it works
This:
```
html(lang="en")
  body
    h1
     "Hello world"
```
Becomes:
```
<html lang="en">
  <body>
    <h1>Hello world</h1>
  </body>
</html>
```
