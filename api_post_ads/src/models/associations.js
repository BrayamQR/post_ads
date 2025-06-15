const Distrito = require("./distrito");
const Provincia = require("./provincia");
const Departamento = require("./departamento");

Distrito.belongsTo(Provincia, { foreignKey: "idProvincia", as: "provincia" });
Provincia.belongsTo(Departamento, {
  foreignKey: "idDepartamento",
  as: "departamento",
});
