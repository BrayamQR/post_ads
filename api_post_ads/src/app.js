const express = require("express");
const session = require("express-session");
const passport = require("passport");
const cors = require("cors"); // Nuevo
const morgan = require("morgan"); // Nuevo
require("dotenv").config();

const sequelize = require("./config/db");
const userRoutes = require("./routes/userRoutes");
const authRoutes = require("./routes/authRoutes");
const genericListRoutes = require("./routes/genericListRoutes");
const locationRoutes = require("./routes/locationRoutes");
const anuncioRoutes = require("./routes/anuncioRoutes");
const models = require("./models");
require("./config/passportConfig");
require("./models/associations");
require("./jobs/anuncioJobs");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: process.env.FRONTEND_URL || "*", credentials: true })); // Nuevo
app.use(morgan("dev")); // Nuevo
app.use(express.json());

app.use(
  session({
    secret: process.env.SESSION_SECRET || "clave_segura",
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: process.env.NODE_ENV === "production",
      httpOnly: true,
      sameSite: "lax",
    },
  })
);

app.use(passport.initialize());
app.use(passport.session());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.get("/", (req, res) => {
  res.send("API funcionando");
});

app.use("/api/user/", userRoutes);
app.use("/api/auth/", authRoutes);
app.use("/api/genericList/", genericListRoutes);
app.use("/api/location/", locationRoutes);
app.use("/api/ad/", anuncioRoutes);

// Manejo global de errores
app.use((err, req, res, next) => {
  console.error("Error no gestionado:", err);
  res
    .status(500)
    .json({ success: false, message: "Error interno del servidor" });
});

sequelize
  .authenticate()
  .then(() => {
    console.log("✅ Conectado a la base de datos MySQL");
    return sequelize.sync();
  })
  .then(() => {
    app.listen(PORT, () => {
      console.log(`🚀 Servidor escuchando en http://localhost:${PORT}`);
    });
  })
  .catch((error) => {
    console.error("❌ Error al conectar con la base de datos:", error);
  });
