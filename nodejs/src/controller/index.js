const { Router } = require("express");

const router = new Router();

router.all("/", (_, res) => res.status(204).send());

router.get("/search", require("./search"));
router.post("/publish", require("./publish"));

module.exports = router;
