const { DataTypes } = require("sequelize");
const sequelize = require("../config/db");

const Anuncio = sequelize.define(
  "Anuncio",
  {
    idAnuncio: {
      type: DataTypes.INTEGER,
      field: "id_anuncio",
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },

    nomAnunciante: {
      type: DataTypes.STRING,
      field: "nom_anunciante",
      allowNull: false,
    },
    idDistrito: {
      type: DataTypes.INTEGER,
      field: "id_distrito",
      allowNull: false,
    },

    idCategoria: {
      type: DataTypes.INTEGER,
      field: "id_categoria",
      allowNull: false,
    },

    idTipo: {
      type: DataTypes.INTEGER,
      field: "id_tipo",
      allowNull: false,
    },
    idJornada: {
      type: DataTypes.INTEGER,
      field: "id_jornada",
      allowNull: true,
    },
    descCorta: {
      type: DataTypes.STRING,
      field: "desc_corta",
      allowNull: false,
    },
    detallAnuncio: {
      type: DataTypes.TEXT,
      field: "detall_anuncio",
      allowNull: false,
    },
    tiempoPublicacion: {
      type: DataTypes.STRING,
      field: "tiempo_publicacion",
      allowNull: false,
    },
    fechaCreacion: {
      type: DataTypes.DATE,
      field: "fecha_creacion",
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    fechaPublicacion: {
      type: DataTypes.DATE,
      field: "fecha_publicacion",
      allowNull: true,
    },
    fechaVencimiento: {
      type: DataTypes.DATE,
      field: "fecha_vencimiento",
      allowNull: true,
    },
    fechaModificacion: {
      type: DataTypes.DATE,
      field: "fecha_modificacion",
      allowNull: true,
    },
    telCelular: {
      type: DataTypes.STRING,
      field: "tel_celular",
      allowNull: true,
    },
    whatsappContacto: {
      type: DataTypes.STRING,
      field: "whatsapp_contacto",
      allowNull: true,
    },
    emailContacto: {
      type: DataTypes.STRING,
      field: "email_contacto",
      allowNull: true,
    },
    linkReferencia: {
      type: DataTypes.STRING,
      field: "link_referencia",
      allowNull: true,
    },
    nroOperacion: {
      type: DataTypes.STRING,
      field: "nro_operacion",
      allowNull: true,
      unique: true,
    },
    nomTitular: {
      type: DataTypes.STRING,
      field: "nom_titular",
      allowNull: true,
    },
    medioOperacion: {
      type: DataTypes.STRING,
      field: "medio_operacion",
      allowNull: true,
    },
    imgComprobante: {
      type: DataTypes.STRING,
      field: "img_comprobante",
      allowNull: true,
    },
    fechaPago: {
      type: DataTypes.DATE,
      field: "fecha_pago",
      allowNull: true,
    },
    montoPago: {
      type: DataTypes.DECIMAL(10, 2),
      field: "monto_pago",
      allowNull: true,
    },
    motivoEstado: {
      type: DataTypes.STRING,
      field: "motivo_estado",
      allowNull: true,
    },
    idUsuario: {
      type: DataTypes.INTEGER,
      field: "id_usuario",
      allowNull: false,
    },
    idEstado: {
      type: DataTypes.INTEGER,
      field: "id_estado",
      allowNull: false,
      defaultValue: 0,
    },
  },
  {
    tableName: "anuncio",
    timestamps: false,
  }
);

module.exports = Anuncio;
