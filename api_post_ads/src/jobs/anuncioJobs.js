const cron = require("node-cron");
const anuncioService = require("../services/anuncioService");

cron.schedule("0 0 * * *", async () => {
  const total = await anuncioService.expireAnuncios();
  console.log(`Anuncios anulados automáticamente: ${total}`);
});
