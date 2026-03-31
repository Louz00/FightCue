import dotenv from "dotenv";

import { buildApp, createDefaultUserStateStore } from "./app.js";

dotenv.config();

const port = Number(process.env.PORT || 3000);
const stateStore = await createDefaultUserStateStore();
const app = await buildApp({ stateStore });

app.listen({ port, host: "0.0.0.0" }).then(() => {
  app.log.info(
    `FightCue backend listening on ${port} using ${stateStore.backendLabel} persistence`,
  );
});
