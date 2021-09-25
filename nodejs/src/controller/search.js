const Joi = require("joi");
const { LogEntry } = require("../model");

const schema = Joi.object({
  count: Joi.number().min(0).default(100),
  offset: Joi.number().min(0).default(0),
});

module.exports = (req, res, next) => {
  const { error, value } = schema.validate(req.query);
  if (error) {
    return next(error);
  }

  return LogEntry.findAll({ limit: value.count, offset: value.offset })
    .then((list) => res.json(list))
    .catch(next);
};
