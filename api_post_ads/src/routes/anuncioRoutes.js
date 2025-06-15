const express = require("express");
const router = express.Router();
const anuncioController = require("../controllers/anuncioController");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

router.get("/all", anuncioController.getAllAnuncios);
router.get("/get/:id", anuncioController.getAnuncioById);
router.post("/register", anuncioController.createAnuncio);
router.get("/adbystate/:idEstado", anuncioController.getAnunciosByEstado);
router.get("/adbyuser/:idUsuario", anuncioController.getAnunciosByUsuario);
router.put("/editstate/:idAnuncio", anuncioController.updateEstadoAnuncio);
router.put("/edit/:idAnuncio", anuncioController.updateAnuncio);

const comprobantesDir = path.join(__dirname, "../uploads/comprobantes");
if (!fs.existsSync(comprobantesDir)) {
  fs.mkdirSync(comprobantesDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, comprobantesDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});
const upload = multer({ storage: storage });

router.put(
  "/confirm-payment/:idAnuncio",
  upload.single("imgComprobante"),
  anuncioController.confirmPayment
);

router.get("/payment-info/:idAnuncio", anuncioController.getPaymentInfo);

module.exports = router;
