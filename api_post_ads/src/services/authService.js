const userRepository = require("../repositories/userRepository");
const axios = require("axios");
const fs = require("fs");
const path = require("path");

async function downloadProfilePhoto(url, filename) {
  const folder = path.join(__dirname, "../uploads/photoperfil");
  if (!fs.existsSync(folder)) fs.mkdirSync(folder, { recursive: true });
  const filePath = path.join(folder, filename);

  const response = await axios.get(url, { responseType: "stream" });
  await new Promise((resolve, reject) => {
    const stream = response.data.pipe(fs.createWriteStream(filePath));
    stream.on("finish", resolve);
    stream.on("error", reject);
  });

  return `/uploads/photoperfil/${filename}`;
}

exports.findOrCreateGoogleUser = async (profile) => {
  try {
    let user = await userRepository.findByGoogleId(profile.id);

    if (!user) {
      const email = profile.emails?.[0]?.value || profile.email;
      user = await userRepository.findByEmail(email);

      // 3. Si existe por email, actualiza el usuario con googleId
      if (user) {
        await userRepository.updateUser(user.idUsuario, {
          googleId: profile.id,
        });
        user.googleId = profile.id;
      }
    }

    if (!user) {
      let fotoUsuario = null;
      if (profile.photos?.[0]?.value) {
        const ext = ".jpg";
        fotoUsuario = await downloadProfilePhoto(
          profile.photos[0].value,
          `${profile.id}${ext}`
        );
      }
      user = await userRepository.createUser({
        googleId: profile.id,
        nomUsuario: profile.name?.givenName || "Nombre",
        apeUsuario: profile.name?.familyName || "Apellido",
        emailUsuario: profile.emails?.[0]?.value || profile.email,
        fotoUsuario,
        emailVerified: true,
        passUsuario: null,
        idTipoUsuario: 0,
      });
    } else if (user.lvigente === false) {
      await userRepository.updateUser(user.idUsuario, { lvigente: true });
      user.lvigente = true;
    }

    return user;
  } catch (error) {
    console.error("❌ Error en findOrCreateGoogleUser:", error);
    throw error;
  }
};
