// Cloudflare Worker entry point
import { fetch } from "../build/dev/javascript/server/server.mjs";
import { GameRoom } from "./server_ffi.mjs";

export default { fetch };
export { GameRoom };
