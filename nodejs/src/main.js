const express = require("express");
const bodyParser = require("body-parser");
const morgan = require("morgan");

const server = express();

server.use(morgan("combined"));
server.use(express.json());
server.use(require("./controller"));

server.listen(3000, (err) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log("listen on port 3000");
});
