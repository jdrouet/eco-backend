const Joi = require("joi");
const superagent = require("superagent");

const schema = Joi.object({
  ts: Joi.date().timestamp("unix").required(),
  tags: Joi.object().pattern(Joi.string(), Joi.string()).required(),
  values: Joi.object().required(),
});

const blackholeUrl = process.env.BLACKHOLE_URL ?? "http://localhost:3010";

module.exports = (req, res, next) => {
  const { error, value } = schema.validate(req.body, { allowUnknown: true });
  if (error) {
    return next(error);
  }

  Object.assign(value.tags, { through: "nodejs" });

  return superagent
    .post(blackholeUrl)
    .send(value) // sends a JSON post body
    .end((err) => {
      if (err) return next(err);
      return res.status(204).send();
    });
};
