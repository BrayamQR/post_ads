const anuncioService = require("../services/anuncioService");
const path = require("path");

exports.getAllAnuncios = async (req, res) => {
  try {
    const anuncios = await anuncioService.getAllAnuncios();
    res.status(200).json(anuncios);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAnuncioById = async (req, res) => {
  try {
    const anuncio = await anuncioService.getAnuncioById(req.params.id);
    if (!anuncio) {
      return res.status(404).json({ message: "Anuncio no encontrado" });
    }
    res.status(200).json(anuncio);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createAnuncio = async (req, res) => {
  try {
    const anuncio = await anuncioService.createAnuncio(req.body);
    res.status(201).json(anuncio);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAnunciosByEstado = async (req, res) => {
  try {
    const anuncios = await anuncioService.getAnunciosByEstado(
      req.params.idEstado
    );
    res.status(200).json(anuncios);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAnunciosByUsuario = async (req, res) => {
  try {
    const anuncios = await anuncioService.getAnunciosByUsuario(
      req.params.idUsuario
    );
    res.status(200).json(anuncios);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateEstadoAnuncio = async (req, res) => {
  try {
    const { idAnuncio } = req.params;
    const { idEstado, motivoEstado } = req.body;
    await anuncioService.updateEstadoAnuncio(idAnuncio, idEstado, motivoEstado);
    res.status(200).json({ message: "Estado actualizado correctamente" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateAnuncio = async (req, res) => {
  try {
    const { idAnuncio } = req.params;
    await anuncioService.updateAnuncio(idAnuncio, req.body);
    res.status(200).json({ message: "Anuncio actualizado correctamente" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.confirmPayment = async (req, res) => {
  try {
    const { idAnuncio } = req.params;
    const { nroOperacion, nomTitular, medioOperacion, montoPago } = req.body;
    const imgComprobante = req.file
      ? path
          .relative(path.join(__dirname, ".."), req.file.path)
          .replace(/\\/g, "/")
      : null;
    const montoPagoDecimal = montoPago ? Number(montoPago) : null;
    await anuncioService.confirmPayment(
      idAnuncio,
      nroOperacion,
      nomTitular,
      medioOperacion,
      imgComprobante,
      montoPagoDecimal
    );
    res.status(200).json({ message: "Pago confirmado correctamente" });
  } catch (error) {
    console.error("Error en confirmPayment:", error);
    res.status(500).json({ message: error.message });
  }
};

exports.getPaymentInfo = async (req, res) => {
  try {
    const { idAnuncio } = req.params;
    const paymentInfo = await anuncioService.getPaymentInfo(idAnuncio);
    if (!paymentInfo) {
      return res
        .status(404)
        .json({ message: "Información de pago no encontrada" });
    }
    res.status(200).json(paymentInfo);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.expireAnuncios = async (req, res) => {
  try {
    const total = await anuncioService.expireAnuncios();
    res
      .status(200)
      .json({ message: `Anuncios anulados automáticamente: ${total}` });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
