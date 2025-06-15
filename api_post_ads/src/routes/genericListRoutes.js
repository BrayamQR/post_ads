const express = require("express");
const router = express.Router();

const genericListController = require("../controllers/genericListController");

router.get("/categorys", genericListController.getAllCategorias);

router.get("/types/:categoriaId", genericListController.getTiposByCategoria);

router.get("/days/:categoriaId", genericListController.getJornadasByCategoria);

router.get("/states", genericListController.getAllEstados);

router.get("/user-types", genericListController.getTiposUsuario);

module.exports = router;
