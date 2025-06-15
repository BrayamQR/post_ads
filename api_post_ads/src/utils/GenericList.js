class GenericList {
  constructor(id, descripcion) {
    this.id = id;
    this.descripcion = descripcion;
  }

  getId() {
    return this.id;
  }

  setId(id) {
    this.id = id;
  }

  getDescripcion() {
    return this.descripcion;
  }

  setDescripcion(descripcion) {
    this.descripcion = descripcion;
  }
}

module.exports = GenericList;
