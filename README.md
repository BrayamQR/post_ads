Post Ads

**Post Ads** es una plataforma para publicar anuncios de todo tipo, incluyendo:

- Ofertas de empleo
- Alquiler y venta de inmuebles
- Compra y venta de productos
- Y más...

Este proyecto está desarrollado con **Flutter** para el frontend y **Node.js** para el backend. Permite a los usuarios navegar, buscar y publicar anuncios de forma rápida y sencilla.

---

## 🛠 Tecnologías utilizadas

- 💙 **Flutter** — Aplicación móvil (Frontend)
- 🟢 **Node.js** — API REST (Backend)
- 🐬 **MySQL** — Base de datos relacional
- 🔐 **JWT + Google Auth** — Sistema de autenticación
- 🌐 **Ngrok** — Exposición del backend en desarrollo

---

## 🚀 Requisitos previos

Asegúrate de tener lo siguiente instalado:

### 📱 Frontend (Flutter)

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio o Visual Studio Code
- Emulador o dispositivo físico con Android/iOS

### 💻 Backend (Node.js)

- [Node.js (versión recomendada)](https://nodejs.org/)
- [npm](https://www.npmjs.com/)
- [MySQL](https://www.mysql.com/) instalado y ejecutándose localmente o en un servidor

### 🌐 Ngrok (opcional, para desarrollo con Google Auth)

- [Ngrok CLI](https://ngrok.com/download)

---

## 📦 Instalación

Asumimos la siguiente estructura del proyecto:

cd api_post_ads
npm install

cd post_ads
flutter pub get

# Google console
Agregar las credenciales de atenticacion en el google console y agregar la ruta obtenida el ngrok en las rutas

# Variables de entorno

# Configuración de MySQL
DB_HOST=localhost
DB_USER=Tu_USUARIO
DB_PASSWORD=Tu_PASSWORD
DB_NAME=Tu_NOMBRE_BASE_DE_DATOS
DB_PORT=3306

# Configuración del servidor
PORT=3000

# Autenticación con Google
GOOGLE_CLIENT_ID=Tu_CLIENT_ID
GOOGLE_CLIENT_SECRET=Tu_CLIENT_SECRET
GOOGLE_REDIRECT_URI=Tu_REDIRECT_URI

# Seguridad y sesión
SESSION_SECRET=Tu_SESSION_SECRET
JWT_SECRET=Tu_JWT_SECRET

# Configuración de correo electrónico
EMAIL_USER=Tu_CORREO
EMAIL_PASS=Tu_CONTRASEÑA_APP

# Instala Ngrok y ejecuta:

ngrok http 3000

# En la carpeta backend
npm run dev

# En la carpeta frontend
modificar la ruta base por la ruta obtenida en el ngrok
flutter run
