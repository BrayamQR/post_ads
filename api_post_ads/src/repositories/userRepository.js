const { Usuario } = require("../models");
const { Op } = require("sequelize");

exports.findByEmail = async (email) => {
  return await Usuario.findOne({
    where: { emailUsuario: email, lvigente: true },
  });
};

exports.findByUserName = async (userName) => {
  return await Usuario.findOne({
    where: { userName: userName, lvigente: true },
  });
};

exports.findByGoogleId = async (googleId) => {
  return await Usuario.findOne({ where: { googleId } });
};

exports.createUser = async (userData) => {
  return await Usuario.create(userData);
};

exports.findByEmailOrUserName = async (identifier) => {
  return await Usuario.findOne({
    where: {
      [Op.or]: [{ emailUsuario: identifier }, { userName: identifier }],
      lvigente: true,
    },
  });
};

exports.findById = async (idUsuario) => {
  return await Usuario.findOne({ where: { idUsuario, lvigente: true } });
};

exports.updateUser = async (idUsuario, updateData) => {
  return await Usuario.update(updateData, {
    where: { idUsuario },
  });
};

exports.findAllUsers = async () => {
  return await Usuario.findAll({
    where: { lvigente: true },
  });
};

exports.deactivateUser = async (idUsuario) => {
  return await Usuario.update({ lvigente: false }, { where: { idUsuario } });
};

exports.updateProfilePhoto = async (idUsuario, fotoUsuario) => {
  return await Usuario.update({ fotoUsuario }, { where: { idUsuario } });
};
