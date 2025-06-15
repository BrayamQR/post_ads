import 'package:post_ads/models/generic_list.dart';
import 'package:post_ads/models/location.dart';

class Anuncio {
  int? idAnuncio;
  String nomAnunciante;
  Distrito? distrito;
  GenericList? categoria;
  GenericList? tipo;
  GenericList? jornada;
  String descCorta;
  String detallAnuncio;
  int tiempoPublicacion;
  DateTime? fechaCreacion;
  DateTime? fechaPublicacion;
  DateTime? fechaVencimiento;
  DateTime? fechaModificacion;
  String? telCelular;
  String? whatsappContacto;
  String? emailContacto;
  String? linkReferencia;
  String? nroOperacion;
  String? nomTitular;
  String? imgComprobante;
  String? medioOperacion;
  DateTime? fechaPago;
  double? montoPago;
  String? motivoEstado;
  int idUsuario;
  GenericList? estado;

  Anuncio({
    this.idAnuncio,
    required this.nomAnunciante,
    this.distrito,
    this.categoria,
    this.tipo,
    this.jornada,
    required this.descCorta,
    required this.detallAnuncio,
    required this.tiempoPublicacion,
    this.fechaCreacion,
    this.fechaPublicacion,
    this.fechaModificacion,
    this.fechaVencimiento,
    this.telCelular,
    this.whatsappContacto,
    this.emailContacto,
    this.linkReferencia,
    this.nroOperacion,
    this.nomTitular,
    this.medioOperacion,
    this.imgComprobante,
    this.fechaPago,
    this.montoPago,
    this.motivoEstado,
    required this.idUsuario,
    this.estado,
  });

  factory Anuncio.fromJson(Map<String, dynamic> json) {
    return Anuncio(
      idAnuncio: json['idAnuncio'],
      nomAnunciante: json['nomAnunciante'] ?? '',
      distrito:
          json['distrito'] != null ? Distrito.fromJson(json['distrito']) : null,
      categoria:
          json['categoria'] != null
              ? GenericList.fromJson(json['categoria'])
              : null,
      tipo: json['tipo'] != null ? GenericList.fromJson(json['tipo']) : null,
      jornada:
          json['jornada'] != null
              ? GenericList.fromJson(json['jornada'])
              : null,
      descCorta: json['descCorta'] ?? '',
      detallAnuncio: json['detallAnuncio'] ?? '',
      tiempoPublicacion:
          int.tryParse(json['tiempoPublicacion'].toString()) ?? 0,
      fechaCreacion:
          json['fechaCreacion'] != null
              ? DateTime.parse(json['fechaCreacion'])
              : null,
      fechaPublicacion:
          json['fechaPublicacion'] != null
              ? DateTime.parse(json['fechaPublicacion'])
              : null,
      fechaVencimiento:
          json['fechaVencimiento'] != null
              ? DateTime.parse(json['fechaVencimiento'])
              : null,
      fechaModificacion:
          json['fechaModificacion'] != null
              ? DateTime.parse(json['fechaModificacion'])
              : null,
      telCelular: json['telCelular'],
      whatsappContacto: json['whatsappContacto'],
      emailContacto: json['emailContacto'],
      linkReferencia: json['linkReferencia'],
      nroOperacion: json['nroOperacion'],
      nomTitular: json['nomTitular'],
      medioOperacion: json['medioOperacion'],
      imgComprobante: json['imgComprobante'],
      fechaPago:
          json['fechaPago'] != null ? DateTime.parse(json['fechaPago']) : null,
      montoPago:
          json['montoPago'] != null
              ? double.tryParse(json['montoPago'].toString())
              : null,
      motivoEstado: json['motivoEstado'],
      idUsuario: json['idUsuario'],
      estado:
          json['estado'] != null ? GenericList.fromJson(json['estado']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nomAnunciante': nomAnunciante,
      'distrito': distrito?.toJson(),
      'categoria': categoria?.toJson(),
      'tipo': tipo?.toJson(),
      'descCorta': descCorta,
      'detallAnuncio': detallAnuncio,
      'tiempoPublicacion': tiempoPublicacion,
      'telCelular': telCelular ?? '',
      'whatsappContacto': whatsappContacto ?? '',
      'emailContacto': emailContacto ?? '',
      'linkReferencia': linkReferencia ?? '',
      'nroOperacion,': nroOperacion ?? '',
      'nomTitular,': nomTitular ?? '',
      'medioOperacion,': medioOperacion ?? '',
      'imgComprobante,': imgComprobante ?? '',
      'montoPago': montoPago ?? 0.0,
      'motivoEstado': motivoEstado ?? '',
      'idUsuario': idUsuario,
      'estado': estado?.toJson(),
    };
    if (idAnuncio != null) {
      data['idAnuncio'] = idAnuncio;
    }
    if (jornada != null) {
      data['jornada'] = jornada!.toJson();
    }
    return data;
  }
}
