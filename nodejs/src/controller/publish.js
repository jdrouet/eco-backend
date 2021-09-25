const Joi = require("joi");
const { LogEntry } = require("../model");

const schema = Joi.array().items(
  Joi.object({
    createdAt: Joi.date().timestamp("unix").required(),
    level: Joi.string().required(),
  })
);

module.exports = (req, res, next) => {
  const { error, value } = schema.validate(req.body, { allowUnknown: true });
  if (error) {
    return next(error);
  }

  const data = value.map(({ createdAt, level, ...payload }) => ({
    createdAt,
    level,
    payload,
  }));

  return LogEntry.bulkCreate(data)
    .then((created) => res.json(created.length))
    .catch(next);
};
