const { DataTypes } = require("sequelize");
const sequelize = require("../config/db");

const Provincia = sequelize.define(
  "Provincia",
  {
    idProvincia: {
      type: DataTypes.INTEGER,
      field: "id_provincia",
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    descProvincia: {
      type: DataTypes.STRING,
      field: "desc_provincia",
      allowNull: false,
    },
    idDepartamento: {
      type: DataTypes.INTEGER,
      field: "id_departamento",
      allowNull: false,
    },
  },
  {
    tableName: "provincia",
    timestamps: false,
  }
);

module.exports = Provincia;
