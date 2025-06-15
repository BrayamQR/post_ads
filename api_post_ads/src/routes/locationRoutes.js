const express = require("express");
const router = express.Router();
const locationController = require("../controllers/locationController");

router.get("/departamentos", locationController.getAllDepartamentos);

router.get(
  "/provincias/:idDepartamento",
  locationController.getProvinciasByDepartamento
);

router.get(
  "/distritos/:idProvincia",
  locationController.getDistritosByProvincia
);

router.get(
  "/distritos-anidados",
  locationController.getDistritosWithProvinciaAndDepartamento
);

module.exports = router;
