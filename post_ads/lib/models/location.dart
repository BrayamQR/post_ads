class Departamento {
  final int idDepartamento;
  final String departamento;

  Departamento({required this.idDepartamento, required this.departamento});

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      idDepartamento: json['idDepartamento'],
      departamento: json['descDepartamento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'idDepartamento': idDepartamento, 'descDepartamento': departamento};
  }
}

class Provincia {
  final int idProvincia;
  final String provincia;
  final Departamento departamento;

  Provincia({
    required this.idProvincia,
    required this.provincia,
    required this.departamento,
  });

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(
      idProvincia: json['idProvincia'],
      provincia: json['descProvincia'], // <-- mapea aquí
      departamento: Departamento.fromJson(json['departamento']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProvincia': idProvincia,
      'descProvincia': provincia,
      'departamento': departamento.toJson(),
    };
  }
}

class Distrito {
  final int idDistrito;
  final String distrito;
  final Provincia provincia;

  Distrito({
    required this.idDistrito,
    required this.distrito,
    required this.provincia,
  });

  factory Distrito.fromJson(Map<String, dynamic> json) {
    return Distrito(
      idDistrito: json['idDistrito'],
      distrito: json['descDistrito'], // <-- mapea aquí
      provincia: Provincia.fromJson(json['provincia']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDistrito': idDistrito,
      'descDistrito': distrito,
      'provincia': provincia.toJson(),
    };
  }
}
