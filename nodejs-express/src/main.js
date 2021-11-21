const express = require("express");
const bodyParser = require("body-parser");

const server = express();

server.use(express.json());
server.get("/", require("./status"));
server.post("/publish", require("./publish"));

server.listen(3000, (err) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log("listen on port 3000");
});
