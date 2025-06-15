const GenericList = require("../utils/GenericList");

const estados = [
  new GenericList(1, "Publicado"),
  new GenericList(2, "En proceso"),
  new GenericList(3, "Falta pago"),
  new GenericList(4, "Vencido"),
  new GenericList(5, "Anulado"),
];

module.exports = estados;
