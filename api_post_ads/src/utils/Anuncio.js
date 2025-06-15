class Anuncio {
  constructor({
    idAnuncio,
    nomAnunciante,
    distrito,
    categoria,
    tipo,
    jornada,
    descCorta,
    detallAnuncio,
    tiempoPublicacion,
    fechaCreacion,
    fechaPublicacion,
    fechaVencimiento,
    fechaModificacion,
    telCelular,
    whatsappContacto,
    emailContacto,
    linkReferencia,
    nroOperacion,
    nomTitular,
    medioOperacion,
    imgComprobante,
    fechaPago,
    montoPago,
    motivoEstado,
    idUsuario,
    estado,
  }) {
    this.idAnuncio = idAnuncio;
    this.nomAnunciante = nomAnunciante;
    this.distrito = distrito;
    this.categoria = categoria;
    this.tipo = tipo;
    this.jornada = jornada;
    this.descCorta = descCorta;
    this.detallAnuncio = detallAnuncio;
    this.tiempoPublicacion = tiempoPublicacion;
    this.fechaCreacion = fechaCreacion;
    this.fechaPublicacion = fechaPublicacion;
    this.fechaVencimiento = fechaVencimiento;
    this.fechaModificacion = fechaModificacion;
    this.telCelular = telCelular;
    this.whatsappContacto = whatsappContacto;
    this.emailContacto = emailContacto;
    this.linkReferencia = linkReferencia;
    this.nroOperacion = nroOperacion;
    this.nomTitular = nomTitular;
    this.medioOperacion = medioOperacion;
    this.imgComprobante = imgComprobante;
    this.fechaPago = fechaPago;
    this.montoPago = montoPago;
    this.motivoEstado = motivoEstado;
    this.idUsuario = idUsuario;
    this.estado = estado;
  }
}

module.exports = Anuncio;
