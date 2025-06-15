const express = require("express");
const passport = require("passport");
const authController = require("../controllers/authController");

const router = express.Router();

router.get(
  "/google",
  passport.authenticate("google", { scope: ["profile", "email"] })
);

router.get(
  "/google/callback",
  passport.authenticate("google", {
    failureRedirect: "/auth/failure",
    session: false,
  }),
  authController.googleCallback
);

router.get("/failure", (req, res) => {
  console.log("Entró a /failure");
  res
    .status(401)
    .json({ success: false, message: "Fallo en la autenticación con Google" });
});

module.exports = router;
