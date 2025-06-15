const userRepository = require("../repositories/userRepository");
const bcrypt = require("bcrypt");
const nodemailer = require("nodemailer");
const fs = require("fs");
const path = require("path");

exports.registerUser = async ({
  nomUsuario,
  apeUsuario,
  userName,
  emailUsuario,
  passUsuario,
  idTipoUsuario,
}) => {
  if (!nomUsuario || !userName || !emailUsuario || !passUsuario) {
    throw new Error("Estos campos son obligatorios");
  }

  const existingUser = await userRepository.findByEmail(emailUsuario);
  if (existingUser) {
    throw new Error("El correo ya está registrado");
  }

  const existingUserName = await userRepository.findByUserName(userName);
  if (existingUserName) {
    throw new Error("El nombre de usuario ya está en uso");
  }

  const hashedPassword = await bcrypt.hash(passUsuario, 10);

  const user = await userRepository.createUser({
    nomUsuario,
    apeUsuario,
    userName,
    emailUsuario,
    passUsuario: hashedPassword,
    emailVerified: false,
    idTipoUsuario: idTipoUsuario ?? 0,
  });

  return user;
};

exports.getUserByEmailOrUserName = async (identifier) => {
  if (!identifier) {
    throw new Error("Se requiere un identificador (email o nombre de usuario)");
  }
  const user = await userRepository.findByEmailOrUserName(identifier);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }
  return user;
};

exports.getUserById = async (idUsuario) => {
  const user = await userRepository.findById(idUsuario);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }
  return user;
};

exports.loginUser = async ({ identifier, passUsuario }) => {
  const user = await userRepository.findByEmailOrUserName(identifier);

  if (!user) {
    throw new Error("Usuario no encontrado");
  }

  const validPassword = await bcrypt.compare(passUsuario, user.passUsuario);
  if (!validPassword) {
    throw new Error("Contraseña incorrecta");
  }

  return user;
};

exports.sendPasswordResetCode = async (emailUsuario) => {
  const user = await userRepository.findByEmailOrUserName(emailUsuario);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }

  const codigo = Math.floor(100000 + Math.random() * 900000).toString();
  const expiraEn = new Date(Date.now() + 15 * 60 * 1000); // 15 minutos

  await userRepository.updateUser(user.idUsuario, {
    codigoRecuperacion: codigo,
    codigoExpiraEn: expiraEn,
  });

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  try {
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: user.emailUsuario,
      subject: "Código de verificación",
      text: `Tu código de verificación es: ${codigo}`,
    });
  } catch (error) {
    console.error("Error enviando correo:", error);
    throw new Error(error.message || "No se pudo enviar el correo");
  }

  return true;
};

exports.verifyPasswordResetCode = async (emailUsuario, codigo) => {
  const user = await userRepository.findByEmailOrUserName(emailUsuario);
  if (
    !user ||
    user.codigoRecuperacion !== codigo ||
    !user.codigoExpiraEn ||
    new Date(user.codigoExpiraEn) < new Date()
  ) {
    throw new Error("Código inválido o expirado");
  }
  return true;
};

exports.resetPassword = async (emailUsuario, codigo, nuevaPassword) => {
  await exports.verifyPasswordResetCode(emailUsuario, codigo);

  const user = await userRepository.findByEmail(emailUsuario);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }

  const hashedPassword = await bcrypt.hash(nuevaPassword, 10);

  await userRepository.updateUser(user.idUsuario, {
    passUsuario: hashedPassword,
    codigoRecuperacion: null,
    codigoExpiraEn: null,
  });

  return true;
};

exports.findAllUsers = async () => {
  return await userRepository.findAllUsers();
};

exports.deactivateUser = async (idUsuario) => {
  const user = await userRepository.findById(idUsuario);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }
  await userRepository.deactivateUser(idUsuario);
  return true;
};

exports.resetPasswordToUserName = async (idUsuario) => {
  const user = await userRepository.findById(idUsuario);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }

  const hashedPassword = await bcrypt.hash(user.userName, 10);

  await userRepository.updateUser(user.idUsuario, {
    passUsuario: hashedPassword,
  });

  return true;
};

exports.updateProfilePhoto = async (idUsuario, file) => {
  const user = await userRepository.findById(idUsuario);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }

  if (user.fotoUsuario) {
    const oldPhotoPath = path.join(
      __dirname,
      "../uploads/photoperfil",
      path.basename(user.fotoUsuario)
    );
    if (fs.existsSync(oldPhotoPath)) {
      await fs.promises.unlink(oldPhotoPath);
    }
  }

  const newPhotoPath = `/uploads/photoperfil/${file.filename}`;

  await userRepository.updateProfilePhoto(idUsuario, newPhotoPath);

  return newPhotoPath;
};

exports.changePassword = async (idUsuario, nuevaPassword, actualPassword) => {
  const user = await userRepository.findById(idUsuario);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }
  if (actualPassword) {
    const valid = await bcrypt.compare(actualPassword, user.passUsuario);
    if (!valid) {
      throw new Error("La contraseña actual es incorrecta");
    }
  }

  const hashedPassword = await bcrypt.hash(nuevaPassword, 10);

  await userRepository.updateUser(idUsuario, {
    passUsuario: hashedPassword,
  });

  return true;
};

exports.updateUserNameAndEmail = async (
  idUsuario,
  { userName, emailUsuario }
) => {
  const user = await userRepository.findById(idUsuario);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }

  let updateFields = { userName };

  if (emailUsuario && emailUsuario !== user.emailUsuario) {
    const existingEmail = await userRepository.findByEmail(emailUsuario);
    if (existingEmail && existingEmail.idUsuario !== idUsuario) {
      throw new Error("El correo ya está registrado por otro usuario");
    }
    updateFields.emailUsuario = emailUsuario;
    updateFields.emailVerified = false;

    if (user.googleId) {
      updateFields.googleId = null;
    }
  }

  if (userName && userName !== user.userName) {
    const existingUserName = await userRepository.findByUserName(userName);
    if (existingUserName && existingUserName.idUsuario !== idUsuario) {
      throw new Error("El nombre de usuario ya está en uso por otro usuario");
    }
  }

  await userRepository.updateUser(idUsuario, updateFields);

  return true;
};

exports.updatePersonalData = async (idUsuario, { nomUsuario, apeUsuario }) => {
  const user = await userRepository.findById(idUsuario);
  if (!user) {
    throw new Error("Usuario no encontrado");
  }

  await userRepository.updateUser(idUsuario, {
    nomUsuario,
    apeUsuario,
  });

  return true;
};

exports.verifyEmailCode = async (emailUsuario, codigo) => {
  const user = await userRepository.findByEmail(emailUsuario);
  if (
    !user ||
    user.codigoRecuperacion !== codigo ||
    !user.codigoExpiraEn ||
    new Date(user.codigoExpiraEn) < new Date()
  ) {
    throw new Error("Código inválido o expirado");
  }

  await userRepository.updateUser(user.idUsuario, {
    emailVerified: true,
    codigoRecuperacion: null,
    codigoExpiraEn: null,
  });

  return true;
};
