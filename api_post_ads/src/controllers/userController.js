const userService = require("../services/userService");
const jwt = require("jsonwebtoken");

exports.registerUser = async (req, res) => {
  try {
    const user = await userService.registerUser(req.body);
    res.status(201).json({
      message: "Usuario registrado exitosamente",
      user,
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getUserByEmailOrUserName = async (req, res) => {
  try {
    const { identifier } = req.params;
    const user = await userService.getUserByEmailOrUserName(identifier);
    res.status(200).json(user);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await userService.getUserById(id);
    res.status(200).json(user);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { identifier, passUsuario } = req.body;
    const user = await userService.loginUser({ identifier, passUsuario });
    const token = jwt.sign(
      {
        id: user.idUsuario,
        email: user.emailUsuario,
        userName: user.userName,
        idTipoUsuario: user.idTipoUsuario,
      },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.status(200).json({
      message: `¡Bienvenido, ${user.nomUsuario}!`,
      user: {
        idUsuario: user.idUsuario,
        userName: user.userName,
        nomUsuario: user.nomUsuario,
        apeUsuario: user.apeUsuario,
        emailUsuario: user.emailUsuario,
        fotoUsuario: user.fotoUsuario,
        emailVerified: user.emailVerified,
        idTipoUsuario: user.idTipoUsuario,
      },
      token,
    });
  } catch (error) {
    res.status(401).json({ message: error.message });
  }
};

exports.sendPasswordResetCode = async (req, res) => {
  try {
    const { emailUsuario } = req.body;
    await userService.sendPasswordResetCode(emailUsuario);
    res.status(200).json({ message: "Código enviado al correo." });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.verifyPasswordResetCode = async (req, res) => {
  try {
    const { emailUsuario, codigo } = req.body;
    await userService.verifyPasswordResetCode(emailUsuario, codigo);
    res.status(200).json({ message: "Código válido." });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.resetPassword = async (req, res) => {
  try {
    const { emailUsuario, codigo, nuevaPassword } = req.body;
    await userService.resetPassword(emailUsuario, codigo, nuevaPassword);
    res.status(200).json({ message: "Contraseña actualizada correctamente." });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.findAllUsers = async (req, res) => {
  try {
    const users = await userService.findAllUsers();
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deactivateUser = async (req, res) => {
  try {
    const { idUsuario } = req.params;
    await userService.deactivateUser(idUsuario);
    res.status(200).json({ message: "Usuario eliminado correctamente." });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.resetPasswordToUserName = async (req, res) => {
  try {
    const { idUsuario } = req.params;
    await userService.resetPasswordToUserName(idUsuario);
    res.status(200).json({ message: "Contraseña restablecida exitosamente." });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.updateProfilePhoto = async (req, res) => {
  try {
    const { idUsuario } = req.params;
    if (!req.file) {
      return res.status(400).json({ message: "No se envió ninguna imagen." });
    }
    const newPhotoPath = await userService.updateProfilePhoto(
      idUsuario,
      req.file
    );
    res.status(200).json({
      message: "Foto de perfil actualizada correctamente.",
      fotoUsuario: newPhotoPath,
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { idUsuario } = req.params;
    const { nuevaPassword, actualPassword } = req.body;

    await userService.changePassword(idUsuario, nuevaPassword, actualPassword);

    res.status(200).json({ message: "Contraseña cambiada correctamente." });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.updateUserNameAndEmail = async (req, res) => {
  try {
    const { idUsuario } = req.params;
    const { userName, emailUsuario } = req.body;
    await userService.updateUserNameAndEmail(idUsuario, {
      userName,
      emailUsuario,
    });
    res
      .status(200)
      .json({ message: "Usuario y correo modificados correctamente." });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.updatePersonalData = async (req, res) => {
  try {
    const { idUsuario } = req.params;
    const { nomUsuario, apeUsuario } = req.body;
    await userService.updatePersonalData(idUsuario, { nomUsuario, apeUsuario });
    res
      .status(200)
      .json({ message: "Datos personales actualizados correctamente." });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.verifyEmailCode = async (req, res) => {
  try {
    const { emailUsuario, codigo } = req.body;
    await userService.verifyEmailCode(emailUsuario, codigo);
    res.status(200).json({ message: "Correo verificado correctamente." });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
