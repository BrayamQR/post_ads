const locationService = require("../services/locationService");

exports.getAllDepartamentos = async (req, res) => {
  try {
    const departamentos = await locationService.getAllDepartamentos();
    res.status(200).json(departamentos);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getProvinciasByDepartamento = async (req, res) => {
  try {
    const { idDepartamento } = req.params;
    const provincias = await locationService.getProvinciasByDepartamento(
      idDepartamento
    );
    res.status(200).json(provincias);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getDistritosByProvincia = async (req, res) => {
  try {
    const { idProvincia } = req.params;
    const distritos = await locationService.getDistritosByProvincia(
      idProvincia
    );
    res.status(200).json(distritos);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getDistritosWithProvinciaAndDepartamento = async (req, res) => {
  try {
    const distritos =
      await locationService.getDistritosWithProvinciaAndDepartamento();
    const result = distritos.map((d) => ({
      idDistrito: d.idDistrito,
      descDistrito: d.descDistrito,
      provincia: {
        idProvincia: d.provincia.idProvincia,
        descProvincia: d.provincia.descProvincia,
        departamento: {
          idDepartamento: d.provincia.departamento.idDepartamento,
          descDepartamento: d.provincia.departamento.descDepartamento,
        },
      },
    }));
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
