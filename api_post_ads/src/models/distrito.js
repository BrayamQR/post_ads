const { DataTypes } = require("sequelize");
const sequelize = require("../config/db");

const Distrito = sequelize.define(
  "Distrito",
  {
    idDistrito: {
      type: DataTypes.INTEGER,
      field: "id_distrito",
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    descDistrito: {
      type: DataTypes.STRING,
      field: "desc_distrito",
      allowNull: false,
    },
    idProvincia: {
      type: DataTypes.INTEGER,
      field: "id_provincia",
      allowNull: false,
    },
  },
  {
    tableName: "distrito",
    timestamps: false,
  }
);

module.exports = Distrito;
