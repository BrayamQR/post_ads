const e = require("express");
const genericList = require("../repositories/genericListRepository");

exports.getAllCategorias = () => {
  return genericList.getAllCategorias();
};

exports.getTiposByCategoria = (categoriaId) => {
  return genericList.getTiposByCategoria(categoriaId);
};

exports.getJornadasByCategoria = (categoriaId) => {
  return genericList.getJornadasByCategoria(categoriaId);
};

exports.getAllEstados = () => {
  return genericList.getAllEstados();
};

exports.getTiposUsuario = () => {
  return genericList.getTiposUsuario();
};
