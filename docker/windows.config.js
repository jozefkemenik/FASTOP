const NODE_APPS = [
  ["gateway", 1],
  ["dashboard", 1],
  ["stats", 1],
  ["cs", 1, "country-status"],
  ["task", 1, "task"],
  ["secunda", 1],
  ["da", 1, "data-access", {UV_THREADPOOL_SIZE: 10}],
  ["dfm", 1],
  ["drm", 1],
  ["dbp", 1],
  ["scp", 1],
  ["fgd", 1],
  ["fdms", 1],
  ["auxtools", 1],
  ["addin", 1],
  ["fpadmin", 1],
  ["dsload", 1],
  ["cosnap", 1],
  ["ameco", 1],
  ["sum", 1, "sum", {UV_THREADPOOL_SIZE: 3}],
  ["og", 1, "output-gaps"],
  ["wq", 1, "web-queries"],
  ["ed", 1, "external-data", {UV_THREADPOOL_SIZE: 3}],
  ["fpapi", 1],
  ["ns", 1, "notification"],
  ["mda", 1, "mongo-data-access"],
];
const PYTHON_APPS = [
  // ["fdmsstar", 1],
  // ["eucam", 1],
  // ["sdmx", 1],
  // ["hicp", 1],
  ["ad", 1, "amecodownload"],
  ["neer", 1],
  ["fpcalc", 1],
  ["fplake", 1],
  ["fplm", 1],
]
const ENV = {
};

module.exports = {
  apps: NODE_APPS.map(app => ({
    name: app[0],
    script: "index.js",
    cwd: '../services/' + (app[2] || app[0]) + "/dist",
    exec_mode: app[1] > 1 ? "cluster" : "fork",
    instances: app[1],
    watch: true,
    watch_delay: 3000,
    env: Object.assign({}, ENV, app[3])
  })).concat(PYTHON_APPS.map(app => ({
    name: app[0],
    script: "start-service.sh",
    cwd: '../python/' + (app[2] || app[0]),
    exec_mode: app[1] > 1 ? "cluster" : "fork",
    instances: app[1],
    watch_delay: 4000,
    watch: true,
    ignore_watch: ['cache', 'outputs', 'input', 'data'],
    env: Object.assign({}, ENV, app[3])
  })))
};
