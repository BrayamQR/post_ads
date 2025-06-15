class Usuario {
  final int idUsuario;
  final String? googleId;
  final String nomUsuario;
  final String? apeUsuario;
  final String? userName;
  final String emailUsuario;
  final String? passUsuario;
  final String? fotoUsuario;
  final bool emailVerified;
  final int idTipoUsuario;
  final bool lvigente;

  Usuario({
    required this.idUsuario,
    this.googleId,
    required this.nomUsuario,
    this.apeUsuario,
    this.userName,
    required this.emailUsuario,
    this.passUsuario,
    this.fotoUsuario,
    required this.emailVerified,
    required this.idTipoUsuario,
    required this.lvigente,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      googleId: json['googleId'],
      nomUsuario: json['nomUsuario'] ?? '',
      apeUsuario: json['apeUsuario'] ?? '',
      userName: json['userName'] ?? '',
      emailUsuario: json['emailUsuario'] ?? '',
      passUsuario: json['passUsuario'] ?? '',
      fotoUsuario: json['fotoUsuario'],
      emailVerified: json['emailVerified'] ?? false,
      idTipoUsuario: json['idTipoUsuario'] ?? false,
      lvigente: json['lvigente'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'googleId': googleId,
      'nomUsuario': nomUsuario,
      'apeUsuario': apeUsuario,
      'userName': userName,
      'emailUsuario': emailUsuario,
      'passUsuario': passUsuario,
      'fotoUsuario': fotoUsuario,
      'emailVerified': emailVerified,
      'idTipoUsuario': idTipoUsuario,
    };
  }
}
