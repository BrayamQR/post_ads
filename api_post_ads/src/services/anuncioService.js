const anuncioRepository = require("../repositories/anuncioRepository");
const Anuncio = require("../utils/Anuncio");
const { Distrito, Provincia, Departamento } = require("../utils/location");

const categorias = require("../data/categorias");
const tipos = require("../data/tipos");
const jornadas = require("../data/jonadas");
const estados = require("../data/estados");

function mapAnuncio(a) {
  const departamentoObj = a.distrito?.provincia?.departamento
    ? new Departamento(
        a.distrito.provincia.departamento.idDepartamento,
        a.distrito.provincia.departamento.descDepartamento
      )
    : null;

  const provinciaObj = a.distrito?.provincia
    ? new Provincia(
        a.distrito.provincia.idProvincia,
        a.distrito.provincia.descProvincia,
        departamentoObj
      )
    : null;

  const distritoObj = a.distrito
    ? new Distrito(a.distrito.idDistrito, a.distrito.descDistrito, provinciaObj)
    : null;

  const categoriaObj = categorias.find((c) => c.id === a.idCategoria) || null;
  const tipoObj =
    (tipos[a.idCategoria] || []).find((t) => t.id === a.idTipo) || null;
  const jornadaObj =
    (jornadas[a.idCategoria] || []).find((j) => j.id === a.idJornada) || null;
  const estadoObj = estados.find((e) => e.id === a.idEstado) || null;

  return new Anuncio({
    idAnuncio: a.idAnuncio,
    nomAnunciante: a.nomAnunciante,
    distrito: distritoObj,
    categoria: categoriaObj,
    tipo: tipoObj,
    jornada: jornadaObj,
    descCorta: a.descCorta,
    detallAnuncio: a.detallAnuncio,
    tiempoPublicacion: a.tiempoPublicacion,
    fechaPublicacion: a.fechaPublicacion,
    fechaVencimiento: a.fechaVencimiento,
    fechaModificacion: a.fechaModificacion,
    telCelular: a.telCelular,
    whatsappContacto: a.whatsappContacto,
    emailContacto: a.emailContacto,
    linkReferencia: a.linkReferencia,
    nroOperacion: a.nroOperacion,
    nomTitular: a.nomTitular,
    medioOperacion: a.medioOperacion,
    imgComprobante: a.imgComprobante,
    fechaCreacion: a.fechaCreacion,
    fechaPago: a.fechaPago,
    montoPago: a.montoPago,
    motivoEstado: a.motivoEstado,
    idUsuario: a.idUsuario,
    estado: estadoObj,
  });
}

exports.getAllAnuncios = async () => {
  const anuncios = await anuncioRepository.getAllAnuncios();
  return anuncios.filter((a) => a.idEstado !== 0).map(mapAnuncio);
};

exports.getAnuncioById = async (id) => {
  const anuncio = await anuncioRepository.getAnuncioById(id);
  if (!anuncio || anuncio.idEstado === 0) return null;
  return mapAnuncio(anuncio);
};

exports.getAnunciosByEstado = async (idEstado) => {
  if (parseInt(idEstado) === 0) return [];
  const anuncios = await anuncioRepository.getAnunciosByEstado(idEstado);
  return anuncios.filter((a) => a.idEstado !== 0).map(mapAnuncio);
};

exports.getAnunciosByUsuario = async (idUsuario) => {
  const anuncios = await anuncioRepository.getAnunciosByUsuario(idUsuario);
  return anuncios.filter((a) => a.idEstado !== 0).map(mapAnuncio);
};

exports.updateEstadoAnuncio = async (idAnuncio, idEstado, motivoEstado) => {
  const anuncio = await anuncioRepository.getAnuncioById(idAnuncio);
  if (!anuncio) {
    throw new Error("Anuncio no encontrado");
  }

  let fechaPublicacion = null;
  let fechaVencimiento = null;

  if (idEstado === 1) {
    fechaPublicacion = new Date();

    const tiempoDias = anuncio?.tiempoPublicacion
      ? parseInt(anuncio.tiempoPublicacion)
      : 0;
    if (tiempoDias > 0) {
      fechaVencimiento = new Date(fechaPublicacion);
      fechaVencimiento.setDate(fechaVencimiento.getDate() + tiempoDias);
    }
  }

  return await anuncioRepository.updateEstadoAnuncio(
    idAnuncio,
    idEstado,
    fechaPublicacion,
    fechaVencimiento,
    motivoEstado
  );
};

exports.createAnuncio = async (anuncioData) => {
  return await anuncioRepository.createAnuncio({
    nomAnunciante: anuncioData.nomAnunciante,
    idDistrito: anuncioData.distrito.idDistrito,
    idCategoria: anuncioData.categoria.id,
    idTipo: anuncioData.tipo.id,
    idJornada: anuncioData.jornada ? anuncioData.jornada.id : null,
    descCorta: anuncioData.descCorta,
    detallAnuncio: anuncioData.detallAnuncio,
    tiempoPublicacion: anuncioData.tiempoPublicacion,
    telCelular: anuncioData.telCelular,
    whatsappContacto: anuncioData.whatsappContacto,
    emailContacto: anuncioData.emailContacto,
    linkReferencia: anuncioData.linkReferencia,
    idUsuario: anuncioData.idUsuario,
    idEstado: anuncioData.estado.id,
  });
};

exports.updateAnuncio = async (idAnuncio, anuncioData) => {
  return await anuncioRepository.updateAnuncio(idAnuncio, {
    nomAnunciante: anuncioData.nomAnunciante,
    idDistrito: anuncioData.distrito.idDistrito,
    idCategoria: anuncioData.categoria.id,
    idTipo: anuncioData.tipo.id,
    idJornada: anuncioData.jornada ? anuncioData.jornada.id : null,
    descCorta: anuncioData.descCorta,
    detallAnuncio: anuncioData.detallAnuncio,
    tiempoCreacion: anuncioData.tiempoCreacion,
    telCelular: anuncioData.telCelular,
    whatsappContacto: anuncioData.whatsappContacto,
    emailContacto: anuncioData.emailContacto,
    linkReferencia: anuncioData.linkReferencia,
    idUsuario: anuncioData.idUsuario,
    idEstado: anuncioData.estado.id,
  });
};
exports.confirmPayment = async (
  idAnuncio,
  nroOperacion,
  nomTitular,
  medioOperacion,
  imgComprobante,
  montoPago
) => {
  const anuncio = await anuncioRepository.getAnuncioById(idAnuncio);
  if (!anuncio) {
    throw new Error("Anuncio no encontrado");
  }

  if (nroOperacion) {
    const anuncioExistente = await anuncioRepository.findByNroOperacion(
      nroOperacion
    );
    if (anuncioExistente) {
      throw new Error(
        `El recibo con número de operación "${nroOperacion}" ya fue registrado en otro anuncio.`
      );
    }
  }

  return await anuncioRepository.confirmPayment(
    idAnuncio,
    nroOperacion,
    nomTitular,
    medioOperacion,
    imgComprobante,
    montoPago
  );
};

exports.getPaymentInfo = async (idAnuncio) => {
  const pago = await anuncioRepository.getPaymentInfo(idAnuncio);
  if (!pago) return null;
  return {
    nroOperacion: pago.nroOperacion,
    nomTitular: pago.nomTitular,
    medioOperacion: pago.medioOperacion,
    imgComprobante: pago.imgComprobante,
    idEstado: pago.idEstado,
    fechaPago: pago.fechaPago,
    fechaModificacion: pago.fechaModificacion,
    montoPago: pago.montoPago,
    motivoEstado: pago.motivoEstado,
  };
};

exports.expireAnuncios = async () => {
  const anuncios = await anuncioRepository.getAnunciosByEstado(1);

  const hoy = new Date();
  let totalExpirados = 0;

  for (const anuncio of anuncios) {
    if (anuncio.fechaVencimiento && new Date(anuncio.fechaVencimiento) < hoy) {
      await anuncioRepository.updateEstadoAnuncio(
        anuncio.idAnuncio,
        4,
        anuncio.fechaPublicacion,
        anuncio.fechaVencimiento,
        "Anuncio vencido automáticamente"
      );
      totalExpirados++;
    }
  }
  return totalExpirados;
};
