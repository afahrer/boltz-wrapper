import { types as T, healthUtil } from "../deps.ts";

export const health: T.ExpectedExports.health = {
  async "web-ui"(effects, duration) {
    return healthUtil.checkWebUrl("http://boltz.embassy:80")(effects, duration).catch(healthUtil.catchError(effects))
  },
};
