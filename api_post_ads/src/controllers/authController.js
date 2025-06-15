const jwt = require("jsonwebtoken");

exports.googleCallback = (req, res) => {
  try {
    if (!req.user) {
      return res
        .status(401)
        .json({ success: false, message: "No autenticado" });
    }

    const allowedDomain = process.env.ALLOWED_EMAIL_DOMAIN || "@gmail.com";
    const email = req.user.emailUsuario;

    if (!email || !email.endsWith(allowedDomain)) {
      return res.status(403).json({
        success: false,
        message: `Correo no permitido. Solo se permiten correos ${allowedDomain}`,
      });
    }

    const token = jwt.sign(
      {
        id: req.user.idUsuario,
        email: req.user.emailUsuario,
        nombre: req.user.nomUsuario,
        apellido: req.user.apeUsuario,
        idTipoUsuario: req.user.idTipoUsuario,
      },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    const user = {
      idUsuario: req.user.idUsuario,
      googleId: req.user.googleId,
      nomUsuario: req.user.nomUsuario,
      apeUsuario: req.user.apeUsuario,
      emailUsuario: req.user.emailUsuario,
      fotoUsuario: req.user.fotoUsuario,
      emailVerified: req.user.emailVerified,
      idTipoUsuario: req.user.idTipoUsuario,
    };

    const redirectUrl = `yourapp://callback?token=${token}&user=${encodeURIComponent(
      JSON.stringify(user)
    )}`;
    return res.redirect(redirectUrl);
  } catch (error) {
    console.error("Error en googleCallback:", error);
    res
      .status(500)
      .json({ success: false, message: "Error interno del servidor" });
  }
};
