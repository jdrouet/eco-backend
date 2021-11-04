const cluster = require("cluster");
const express = require("express");
const bodyParser = require("body-parser");
const morgan = require("morgan");
const os = require("os");

if (cluster.isMaster) {
  const numCpus = os.cpus().length;
  for (let i = 0; i < numCpus; i++) {
    cluster.fork();
  }
  cluster.on("exit", (worker, code, signal) => {
    console.log(`worker ${worker.process.pid} died`);
  });
} else {
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
}
