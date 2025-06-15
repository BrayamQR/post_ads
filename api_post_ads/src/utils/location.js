class Departamento {
  constructor(idDepartamento, descDepartamento) {
    this.idDepartamento = idDepartamento;
    this.descDepartamento = descDepartamento;
  }
}

class Provincia {
  constructor(idProvincia, descProvincia, departamento) {
    this.idProvincia = idProvincia;
    this.descProvincia = descProvincia;
    this.departamento = departamento;
  }
}

class Distrito {
  constructor(idDistrito, descDistrito, provincia) {
    this.idDistrito = idDistrito;
    this.descDistrito = descDistrito;
    this.provincia = provincia;
  }
}

module.exports = { Distrito, Provincia, Departamento };
