const locationRepository = require("../repositories/locationRepository");

exports.getAllDepartamentos = async () => {
  return await locationRepository.getAllDepartamentos();
};

exports.getProvinciasByDepartamento = async (idDepartamento) => {
  return await locationRepository.getProvinciasByDepartamento(idDepartamento);
};

exports.getDistritosByProvincia = async (idProvincia) => {
  return await locationRepository.getDistritosByProvincia(idProvincia);
};

exports.getDistritosWithProvinciaAndDepartamento = async () => {
  return await locationRepository.getDistritosWithProvinciaAndDepartamento();
};
