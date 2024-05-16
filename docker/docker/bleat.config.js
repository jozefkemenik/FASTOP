const FASTOP = "/ec/prod/app/webroot/home/fastop";
const SERVICES = FASTOP + "/scopax/";
const APPS = [
  ["gateway", 2],
  ["dashboard", 2],
  ["sum", 2],
  ["da", 2, "data-access"],
  ["dfm", 2],
  ["drm", 2],
  ["dbp", 2],
  ["scp", 2],
  ["fgd", 2],
  ["og", 2, "output-gaps"]
];
const ENV = {
  FASTOP: FASTOP,
  NODE_ENV: "bleat",
  NODE_EXTRA_CA_CERTS: SERVICES + "gateway/config/ec.pem",
  LD_LIBRARY_PATH: "/ec/local/apache/oracle/instantclient_19_3",
  TNS_ADMIN: FASTOP + "/oracle",
  DEBUG: APPS.map(a => a[0]).join(' ')
};

module.exports = {
  apps: APPS.map(app => ({
    name: app[0],
    script: "index.js",
    cwd: SERVICES + (app[2] || app[0]) + "/dist",
    exec_mode: app[1] > 1 ? "cluster" : "fork",
    instances: app[1],
    env: ENV
  }))
};
