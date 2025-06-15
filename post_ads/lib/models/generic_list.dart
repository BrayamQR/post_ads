class GenericList {
  final int id;
  final String? description;

  GenericList({required this.id, this.description});

  factory GenericList.fromJson(Map<String, dynamic> json) {
    return GenericList(id: json['id'], description: json['descripcion']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenericList &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
