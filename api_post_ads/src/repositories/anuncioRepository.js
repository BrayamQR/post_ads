const Anuncio = require("../models/anuncio");
const Distrito = require("../models/distrito");
const Provincia = require("../models/provincia");
const Departamento = require("../models/departamento");

Anuncio.belongsTo(Distrito, { foreignKey: "idDistrito", as: "distrito" });

exports.getAllAnuncios = async () => {
  return await Anuncio.findAll({
    include: [
      {
        model: Distrito,
        as: "distrito",
        include: [
          {
            model: Provincia,
            as: "provincia",
            include: [
              {
                model: Departamento,
                as: "departamento",
              },
            ],
          },
        ],
      },
    ],
  });
};

exports.createAnuncio = async (data) => {
  return await Anuncio.create(data);
};

exports.getAnuncioById = async (id) => {
  return await Anuncio.findOne({
    where: { idAnuncio: id },
    include: [
      {
        model: Distrito,
        as: "distrito",
        include: [
          {
            model: Provincia,
            as: "provincia",
            include: [
              {
                model: Departamento,
                as: "departamento",
              },
            ],
          },
        ],
      },
    ],
  });
};

exports.getAnunciosByEstado = async (idEstado) => {
  return await Anuncio.findAll({
    where: { idEstado },
    include: [
      {
        model: Distrito,
        as: "distrito",
        include: [
          {
            model: Provincia,
            as: "provincia",
            include: [
              {
                model: Departamento,
                as: "departamento",
              },
            ],
          },
        ],
      },
    ],
  });
};
exports.getAnunciosByUsuario = async (idUsuario) => {
  return await Anuncio.findAll({
    where: { idUsuario },
    include: [
      {
        model: Distrito,
        as: "distrito",
        include: [
          {
            model: Provincia,
            as: "provincia",
            include: [
              {
                model: Departamento,
                as: "departamento",
              },
            ],
          },
        ],
      },
    ],
  });
};

exports.updateEstadoAnuncio = async (
  idAnuncio,
  idEstado,
  fechaPublicacion,
  fechaVencimiento,
  motivoEstado
) => {
  return await Anuncio.update(
    {
      idEstado,
      fechaModificacion: new Date(),
      fechaPublicacion,
      fechaVencimiento, // <--- Nuevo campo
      motivoEstado,
    },
    {
      where: { idAnuncio },
    }
  );
};

exports.updateAnuncio = async (idAnuncio, data) => {
  return await Anuncio.update(
    {
      nomAnunciante: data.nomAnunciante,
      idDistrito: data.distrito?.idDistrito || data.idDistrito,
      idCategoria: data.categoria?.id || data.idCategoria,
      idTipo: data.tipo?.id || data.idTipo,
      idJornada: data.jornada ? data.jornada.id || data.idJornada : null,
      descCorta: data.descCorta,
      detallAnuncio: data.detallAnuncio,
      tiempoPublicacion: data.tiempoPublicacion,
      telCelular: data.telCelular,
      whatsappContacto: data.whatsappContacto,
      emailContacto: data.emailContacto,
      linkReferencia: data.linkReferencia,
      idUsuario: data.idUsuario,
      fechaModificacion: new Date(),
    },
    {
      where: { idAnuncio },
    }
  );
};

exports.confirmPayment = async (
  idAnuncio,
  nroOperacion,
  nomTitular,
  medioOperacion,
  imgComprobante,
  montoPago
) => {
  const result = await Anuncio.update(
    {
      idEstado: 2,
      fechaModificacion: new Date(),
      fechaPago: new Date(),
      nroOperacion,
      nomTitular,
      medioOperacion,
      imgComprobante,
      montoPago,
    },
    {
      where: { idAnuncio },
    }
  );
  console.log("Filas actualizadas:", result[0]);
  return result;
};

exports.getPaymentInfo = async (idAnuncio) => {
  return await Anuncio.findOne({
    where: { idAnuncio },
    attributes: [
      "nroOperacion",
      "nomTitular",
      "medioOperacion",
      "imgComprobante",
      "idEstado",
      "fechaPago",
      "fechaModificacion",
      "montoPago",
      "motivoEstado",
    ],
  });
};

exports.findByNroOperacion = async (nroOperacion) => {
  return await Anuncio.findOne({
    where: { nroOperacion },
  });
};
