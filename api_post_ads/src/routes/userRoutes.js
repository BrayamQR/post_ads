const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");
const multer = require("multer");
const path = require("path");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, "../uploads/photoperfil"));
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});
const upload = multer({ storage: storage });

router.post("/reguser", userController.registerUser);

router.post("/login", userController.login);

router.get(
  "/get/indentifier/:identifier",
  userController.getUserByEmailOrUserName
);

router.get("/get/id/:id", userController.getUserById);

router.post("/verify-email", userController.sendPasswordResetCode);
router.post("/verify-code", userController.verifyPasswordResetCode);
router.post("/password-reset", userController.resetPassword);
router.get("/all", userController.findAllUsers);
router.put(
  "/restore-password/:idUsuario",
  userController.resetPasswordToUserName
);
router.delete("/deactivate/:idUsuario", userController.deactivateUser);

router.put(
  "/update-photo/:idUsuario",
  upload.single("fotoUsuario"),
  userController.updateProfilePhoto
);

router.put("/change-password/:idUsuario", userController.changePassword);

router.put(
  "/update-verification/:idUsuario",
  userController.updateUserNameAndEmail
);

router.put(
  "/update-personal-data/:idUsuario",
  userController.updatePersonalData
);

router.post("/verify-email-code", userController.verifyEmailCode);

module.exports = router;
