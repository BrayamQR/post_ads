const categorias = require("../data/categorias");
const jornadas = require("../data/jonadas");
const tipos = require("../data/tipos");
const estados = require("../data/estados");
const tiposUsuario = require("../data/tiposusuario");

exports.getAllCategorias = () => {
  return categorias;
};

exports.getTiposByCategoria = (categoriaId) => {
  return tipos[categoriaId] || [];
};

exports.getJornadasByCategoria = (categoriaId) => {
  return jornadas[categoriaId] || [];
};

exports.getAllEstados = () => {
  return estados;
};

exports.getTiposUsuario = () => {
  return tiposUsuario;
};
