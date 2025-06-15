const genericListService = require("../services/genericListService");

exports.getAllCategorias = (req, res) => {
  const categorias = genericListService.getAllCategorias();
  res.status(200).json(categorias);
};

exports.getTiposByCategoria = (req, res) => {
  const { categoriaId } = req.params;
  const tipos = genericListService.getTiposByCategoria(categoriaId);
  res.status(200).json(tipos);
};

exports.getJornadasByCategoria = (req, res) => {
  const { categoriaId } = req.params;
  const jornadas = genericListService.getJornadasByCategoria(categoriaId);
  res.status(200).json(jornadas);
};

exports.getAllEstados = (req, res) => {
  const estados = genericListService.getAllEstados();
  res.status(200).json(estados);
};
exports.getTiposUsuario = (req, res) => {
  const tiposUsuario = genericListService.getTiposUsuario();
  res.status(200).json(tiposUsuario);
};
