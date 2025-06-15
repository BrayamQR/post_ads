const { DataTypes } = require("sequelize");
const sequelize = require("../config/db");

const Usuario = sequelize.define(
  "Usuario",
  {
    idUsuario: {
      type: DataTypes.INTEGER,
      field: "id_usuario",
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    googleId: {
      type: DataTypes.STRING,
      field: "google_id",
      allowNull: true,
      unique: true,
    },
    nomUsuario: {
      type: DataTypes.STRING,
      field: "nom_usuario",
      allowNull: false,
    },
    apeUsuario: {
      type: DataTypes.STRING,
      field: "ape_usuario",
      allowNull: true,
    },
    userName: {
      type: DataTypes.STRING,
      field: "user_name",
      allowNull: true,
      unique: true,
    },
    emailUsuario: {
      type: DataTypes.STRING,
      field: "email_usuario",
      allowNull: false,
      unique: true,
    },
    passUsuario: {
      type: DataTypes.STRING,
      field: "pass_usuario",
      allowNull: true,
    },
    fotoUsuario: {
      type: DataTypes.STRING,
      field: "foto_usuario",
      allowNull: true,
    },
    emailVerified: {
      type: DataTypes.BOOLEAN,
      field: "email_verificado",
      defaultValue: false,
      allowNull: false,
    },
    codigoRecuperacion: {
      type: DataTypes.STRING,
      field: "codigo_recuperacion",
      allowNull: true,
    },
    codigoExpiraEn: {
      type: DataTypes.DATE,
      field: "codigo_expira_en",
      allowNull: true,
    },
    idTipoUsuario: {
      type: DataTypes.INTEGER,
      field: "id_tipousuario",
      allowNull: false,
      defaultValue: 0,
    },
    lvigente: {
      type: DataTypes.BOOLEAN,
      field: "lvigente",
      allowNull: false,
      defaultValue: true,
    },
  },
  {
    tableName: "usuario",
    timestamps: false,
  }
);

module.exports = Usuario;
