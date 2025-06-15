const { DataTypes } = require("sequelize");
const sequelize = require("../config/db");

const Departamento = sequelize.define(
  "Departamento",
  {
    idDepartamento: {
      type: DataTypes.INTEGER,
      field: "id_departamento",
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    descDepartamento: {
      type: DataTypes.STRING,
      field: "desc_departamento",
      allowNull: false,
    },
  },
  {
    tableName: "departamento",
    timestamps: false,
  }
);

module.exports = Departamento;
