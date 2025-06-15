class PaymentInfo {
  final String? nroOperacion;
  final String? nomTitular;
  final String? medioOperacion;
  final String? imgComprobante;
  final int? idEstado;
  final String? fechaPago;
  final String? fechaModificacion;
  final double? montoPago;

  PaymentInfo({
    this.nroOperacion,
    this.nomTitular,
    this.medioOperacion,
    this.imgComprobante,
    this.idEstado,
    this.fechaPago,
    this.fechaModificacion,
    this.montoPago,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      nroOperacion: json['nroOperacion'],
      nomTitular: json['nomTitular'],
      medioOperacion: json['medioOperacion'],
      imgComprobante: json['imgComprobante'],
      idEstado: json['idEstado'],
      fechaPago: json['fechaPago'],
      fechaModificacion: json['fechaModificacion'],
      montoPago:
          json['montoPago'] != null
              ? double.tryParse(json['montoPago'].toString())
              : null,
    );
  }
}
