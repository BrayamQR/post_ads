const sequelize = require("../config/db");

const Usuario = require("./usuario");
const Anuncio = require("./anuncio");
const Distrito = require("./distrito");
const Departamento = require("./departamento");
const Provincia = require("./provincia");

//Relaciones de Anuncio

Anuncio.belongsTo(Distrito, {
  foreignKey: "idDistrito",
  targetKey: "idDistrito",
});
Distrito.hasMany(Anuncio, {
  foreignKey: "idDistrito",
  sourceKey: "idDistrito",
});

Anuncio.belongsTo(Usuario, {
  foreignKey: "idUsuario",
  targetKey: "idUsuario",
});

Usuario.hasMany(Anuncio, {
  foreignKey: "idUsuario",
  sourceKey: "idUsuario",
});

//Relaciones de Distrito

Distrito.belongsTo(Provincia, {
  foreignKey: "idProvincia",
  targetKey: "idProvincia",
});

Provincia.hasMany(Distrito, {
  foreignKey: "idProvincia",
  sourceKey: "idProvincia",
});

//Relaciones de provincia

Provincia.belongsTo(Departamento, {
  foreignKey: "idDepartamento",
  targetKey: "idDepartamento",
});

Departamento.hasMany(Provincia, {
  foreignKey: "idDepartamento",
  sourceKey: "idDepartamento",
});

module.exports = {
  sequelize,
  Usuario,
  Anuncio,
  Distrito,
  Provincia,
  Departamento,
};
