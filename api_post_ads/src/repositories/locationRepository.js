const Departamento = require("../models/departamento");
const Provincia = require("../models/provincia");
const Distrito = require("../models/distrito");

exports.getAllDepartamentos = async () => {
  return await Departamento.findAll();
};

exports.getProvinciasByDepartamento = async (idDepartamento) => {
  return await Provincia.findAll({
    where: { idDepartamento },
  });
};

exports.getDistritosByProvincia = async (idProvincia) => {
  return await Distrito.findAll({
    where: { idProvincia },
  });
};

exports.getDistritosWithProvinciaAndDepartamento = async () => {
  return await Distrito.findAll({
    include: [
      {
        model: Provincia,
        as: "provincia",
        include: [
          {
            model: Departamento,
            as: "departamento",
          },
        ],
      },
    ],
  });
};
