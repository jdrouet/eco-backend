const { Sequelize, DataTypes } = require("sequelize");

const sequelize = new Sequelize(
  process.env.DATABASE_URL ?? "postgres://eco:dummy@localhost/eco"
);

const LogEntry = sequelize.define(
  "LogEntry",
  {
    createdAt: {
      type: DataTypes.DATE,
      allowNull: false,
      field: "created_at",
    },
    level: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    payload: {
      type: DataTypes.JSON,
      allowNull: false,
    },
  },
  {
    tableName: "mylogs",
    timestamps: false,
  }
);

module.exports = { LogEntry };
