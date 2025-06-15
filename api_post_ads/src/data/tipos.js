const GenericList = require("../utils/GenericList");

const tipoCompraVenta = [
  new GenericList(7, "Inmueble"),
  new GenericList(8, "Vehiculo"),
  new GenericList(9, "Alimentos"),
  new GenericList(10, "Prendas de vestir"),
  new GenericList(11, "Equipos electronicos"),
];

const tipoAlquiler = [
  new GenericList(4, "Inmueble"),
  new GenericList(5, "Vehiculo"),
  new GenericList(6, "Maquinaria pesada"),
];

const tipos = {
  1: [
    new GenericList(1, "Presencial"),
    new GenericList(2, "Hibrido"),
    new GenericList(3, "Remoto"),
  ],
  2: tipoAlquiler,
  3: tipoCompraVenta,
  4: tipoCompraVenta,
};

module.exports = tipos;
