const env = process.env.NODE_ENV || 'local'
const maxRows = 100

const oracleSchema = (providerConfig) => ({provider: 'oracle', maxRows, providerConfig})
const mysqlSchema = (providerConfig) => ({provider: 'mysql', providerConfig})
const mongoSchema = (providerConfig) => ({provider: 'mongo', providerConfig})
const schemas = {
    fastop: oracleSchema({
        connectString: process.env.FASTOP_DB || "OLRDEV23.CC.CEC.EU.INT:1597/SCOPAX_ECFIN_02_D",
        user: "FASTOP",
        password: process.env.FASTOP_DB_PASSWORD,
        poolAlias: 'fastop',
        poolMin: 8,
        poolMax: 8,
        poolIncrement: 0,
        stmtCacheSize: 0,
    }),
    mongo_airflow: mongoSchema({
        uri: process.env.FASTOP_MONGO_DB,
        database: 'airflow',
        pipelinesCollection: '_fastop_pipelines'
    }),
    mongo_cosnap: mongoSchema({
        uri: process.env.COSNAP_MONGO_DB,
        database: 'cosnap'
    }),
    fgd: oracleSchema({
        connectString: process.env.FASTOP_DB || "OLRDEV23.CC.CEC.EU.INT:1597/SCOPAX_ECFIN_02_D",
        user: "FGD",
        password: process.env.FGD_DB_PASSWORD,
        poolAlias: 'fgd',
        poolMin: 8,
        poolMax: 8,
        poolIncrement: 0,
        stmtCacheSize: 0,
    }),
    spi: oracleSchema({
        connectString: process.env.SPI_DB || "OLRDEV18.CC.CEC.EU.INT:1597/SPI_ECFIN_01_D_TAF.cc.cec.eu.int",
        user: "SPI",
        password: process.env.SPI_DB_PASSWORD,
        poolAlias: 'spi',
        poolMin: 1,
        poolMax: 3,
        poolIncrement: 1,
        stmtCacheSize: 0,
    }),
    sum: oracleSchema({
        connectString: process.env.SECUNDA_DB || 'olrmcprod3.cc.cec.eu.int:1597/FP6_RTD_01_P',
        user: "CUD_ECFIN_LOADER",
        password: process.env.SECUNDA_DB_PASSWORD,
        poolAlias: 'sum',
        poolMin: 1,
        poolMax: 3,
        poolIncrement: 1,
        stmtCacheSize: 0,
    }),
    ameco: mysqlSchema({
        host: process.env.AMECO_DB_HOST || "AFFERAMOD.CC.CEC.EU.INT",
        port: 3306,
        user: process.env.AMECO_DB_USER || "ameco_user",
        password: process.env.AMECO_DB_PASSWORD,
        database : "ameco_internal",
        connectionLimit: 3,
    }),
    ameco_online: mysqlSchema({
        host: process.env.AMECO_ONLINE_DB_HOST || "CHREQUARKE.CC.CEC.EU.INT",
        port: 3306,
        user: "ameco_admin",
        password: process.env.AMECO_ONLINE_DB_PASSWORD,
        database : process.env.AMECO_ONLINE_DB_NAME || "ameco_online",
        connectionLimit: 3,
    }),
}

const secunda = {
    username: 'ecfin_fastop_user',
    password: process.env.SECUNDA_USER_PASSWORD,
    serviceUrl: process.env.SECUNDA_SERVICE_URL,
    useUM: process.env.SECUNDA_UM === 'true',
    //rest cfg
    secundaEndpoint: process.env.SECUNDA_APIGW_ENDPOINT,
    apiGatewayEndpoint: process.env.APIGW_ENDPOINT,
    consumerKey: process.env.CONSUMER_KEY,
    consumerSecret: process.env.CONSUMER_SECRET
}

const amecoToken = {
    apiGatewayEndpoint: process.env.AMECO_APIGW_ENDPOINT,
    consumerKey: process.env.AMECO_CONSUMER_KEY,
    consumerSecret: process.env.AMECO_CONSUMER_SECRET
}

const mailbox = {
    host: process.env.MAILBOX_HOST,
    port: process.env.MAILBOX_PORT,
    sender: process.env.MAILBOX_SENDER,
}

const cns = {
    url: process.env.CNS_ENDPOINT || 'https://webgate.acceptance.ec.europa.eu/cns/services/rest/v1',
    auth: process.env.CNS_AUTH || 'S0VZLUZBU1RPUC1ydTJyNE1mc3RJOkZBU1RPUC1BQ0MtMjAyMy0yODlPQ0lxdFFRdng2OUZUbmZHTVp4YThnWDBJZ1VIQ3Bia1Nt'
}

const proxy = {
    http: process.env.HTTP_PROXY,
    https: process.env.HTTPS_PROXY
}

const ldap = {
    ldapHost: process.env.LDAP_HOST,
    ldapPort: process.env.LDAP_PORT,
    ldapUser: process.env.LDAP_USER,
    ldapPass: process.env.LDAP_PASS,
    ldapBase: process.env.LDAP_BASE
}

const getApps = function(nodeHost = '127.0.0.1', pythonHost = nodeHost, pythonPortsOffset = 0) {
    return {
        da: {
            host: nodeHost,
            port: 3101,
            db: {
                fastop: schemas.fastop,
            },
        },
        SUM: {
            host: nodeHost,
            port: 3102,
            intragateService: true,
            webgateService: false,
            secundaAuthz: true,
            db: {
                sum: schemas.sum,
            },
        },
        dashboard: {
            host: nodeHost,
            port: 3103,
            intragateService: true,
            webgateService: true,
        },
        outputGap: {
            host: nodeHost,
            port: 3104,
        },
        ctyStatus: {
            host: nodeHost,
            port: 3105,
        },
        webQuery: {
            host: nodeHost,
            port: 3106,
            intragateService: true,
            webgateService: true,
        },
        secunda: {
            host: nodeHost,
            port: 3107,
            intragateService: true,
            webgateService: true,
        },
        externalData: {
            host: nodeHost,
            port: 3108,
            intragateService: true,
            webgateService: true,
            db: {
                spi: schemas.spi,
                ameco: schemas.ameco,
                ameco_online:  schemas.ameco_online,
            },
        },
        stats: {
            host: nodeHost,
            port: 3109,
            intragateService: true,
            webgateService: true,
        },
        task: {
            host: nodeHost,
            port: 3110,
        },
        fpapi: {
            host: nodeHost,
            port: 3111,
            intragateService: true,
        },
        notification: {
            host: nodeHost,
            port: 3112,
            intragateService: true,
        },
        mda: {
            host: nodeHost,
            port: 3113,
            db: {
                airflow: schemas.mongo_airflow,
            },
            intragateService: true,
        },
        DFM: {
            host: nodeHost,
            port: 3210,
            intragateService: true,
            secundaAuthz: true
        },
        DRM: {
            host: nodeHost,
            port: 3220,
            intragateService: true,
            webgateService: true,
            secundaAuthz: true
        },
        DBP: {
            host: nodeHost,
            port: 3230,
            intragateService: true,
            webgateService: true,
            secundaAuthz: true
        },
        SCP: {
            host: nodeHost,
            port: 3240,
            intragateService: true,
            webgateService: true,
            secundaAuthz: true
        },
        FGD: {
            host: nodeHost,
            port: 3250,
            db: {
                fgd: schemas.fgd,
            },
        },
        NFR: {
            host: nodeHost,
            port: 3251,
            intragateService: true,
            webgateService: true,
            secundaAuthz: true,

        },
        IFI: {
            host: nodeHost,
            port: 3252,
            intragateService: true,
            webgateService: true,
            secundaAuthz: true
        },
        MTBF: {
            host: nodeHost,
            port: 3253,
            intragateService: true,
            webgateService: true,
            secundaAuthz: true
        },
        GBD: {
            host: nodeHost,
            port: 3254,
            intragateService: true,
            webgateService: true,
            secundaAuthz: true
        },
        PIM: {
            host: nodeHost,
            port: 3255,
            intragateService: true,
            webgateService: true,
            secundaAuthz: true
        },
        FDMS: {
            host: nodeHost,
            port: 3260,
            intragateService: true,
            secundaAuthz: true
        },
        FDMSIE: {
            host: nodeHost,
            port: 3261,
            intragateService: true,
            secundaAuthz: true
        },
        AUXTOOLS: {
            host: nodeHost,
            port: 3270,
            intragateService: true,
            secundaAuthz: true
        },
        ADDIN: {
            host: nodeHost,
            port: 3271,
            intragateService: true,
            secundaAuthz: true
        },
        FPADMIN: {
            host: nodeHost,
            port: 3272,
            intragateService: true,
            secundaAuthz: true
        },
        DSLOAD: {
            host: nodeHost,
            port: 3273,
            intragateService: true,
            secundaAuthz: true
        },
        COSNAP: {
            host: nodeHost,
            port: 3274,
            db: {
                cosnap: schemas.mongo_cosnap,
            },
            intragateService: true,
            secundaAuthz: true
        },
        AMECO: {
            host: nodeHost,
            port: 3280,
            intragateService: true,
            secundaAuthz: true
        },
        BCS: {
            host: nodeHost,
            port: 3290,
            intragateService: true,
            secundaAuthz: true
        },
        BCS_DA: {
            // this is just placeholder to indicate that port 3291 is taken by BCS data-access
            host: nodeHost,
            port: 3291,
        },
        sdmx: {
            host: pythonHost,
            port: pythonPortsOffset + 3501,
        },
        eucam: {
            host: pythonHost,
            port: pythonPortsOffset + 3502,
        },
        fdmsstar: {
            host: pythonHost,
            port: pythonPortsOffset + 3503,
        },
        hicp: {
            host: pythonHost,
            port: pythonPortsOffset + 3504,
        },
        amecodownload: {
            host: pythonHost,
            port: pythonPortsOffset + 3505,
        },
        bcsstar: {
            host: pythonHost,
            port: pythonPortsOffset + 3506,
        },
        neer: {
            host: pythonHost,
            port: pythonPortsOffset + 3507,
        },
        fpcalc: {
            host: pythonHost,
            port: pythonPortsOffset + 3508,
        },
        fplm: {
            host: pythonHost,
            port: pythonPortsOffset + 3510,
        },
        // FPLAKE on local env is simulating set of duck_db services
        // when deployed it will take range of ip addresses between 3700 and 3800 provided in database FPLAKES tables
        // and it will run on dedicated housing machine, so there will be no port conflict with standard python services
        fplake: {
            host: pythonHost,
            port: pythonPortsOffset + 3700,
        },
        // CORECOM service - just to indicate which port is taken
        corecomstar: {
            host: pythonHost,
            port: pythonPortsOffset + 3509,
        },
        // CORECOM services - just to indicate which ports are taken
        CORECOM: {
            // Cost Allocation Engine
            host: nodeHost,
            port: 4101,
            intragateService: true,
            secundaAuthz: true
        },
        CORECOM_DA: {
            host: nodeHost,
            port: 4102,
        }
    }
}
const apps = getApps()

const commonRedisOptions = {
    showFriendlyErrorStack: true,
    keepAlive: 15 * 60 * 1000,  // 15 minutes
}

const redis = {
    local: Object.assign({}, commonRedisOptions, {
        host: 'redis',
        port: 6379,
    }),
    podman_dev: Object.assign({}, commonRedisOptions, {
        host: 'fp-etl-d.cc.cec.eu.int',
        port: 6379,
        connectTimeout: 10000,
    }),
    dev: Object.assign({}, commonRedisOptions, {
        sentinels: [
            { host: "redd31", port: 20333 },
            { host: "redd32", port: 20333 },
            { host: "redd33", port: 20333 },
            { host: "redd34", port: 20333 }
        ],
        name: "redd33_4333",
        password: process.env.REDIS_PASSPHRASE,
    }),
    prod: Object.assign({}, commonRedisOptions, {
        sentinels: [
            { host: "redp21", port: 20333 },
            { host: "redp22", port: 20333 },
            { host: "redp23", port: 20333 },
            { host: "redp24", port: 20333 }
        ],
        name: "redp21_5333",
        password: process.env.REDIS_PASSPHRASE,
    })
}

const common = {
    host: 'http://localhost',
    amecoPublicHost: process.env.AMECO_ONLINE_PUBLIC_URL,
    useHostPort: false,
    httpPort: 3100,
    httpsPort: 0, // 3443,
    intragatePort: 3099,
    secret: process.env.FASTOP_SECRET || 'AY9yX-IR2+aZ=M-qTacGI!T4mcZE?MHoj',
    apiKey: process.env.FASTOP_API_KEY || 'qgSZ],X9vHs49HM~|@u{"D8A[ae^fB',     // empty string turns off the check
    jwtSecret: process.env.FASTOP_JWT_SECRET || 'p6erw0Q+wxV@UY?J;pO=3|I)3SArP3fj=kJE6g',
    sessionTimeout:  15*60,    // 15 minutes in seconds
    accessCodeTimeout:  60 * 60 * 1000,    // 60 minutes in milliseconds
    JSONLimit: 150 * 1024,    // 150mb in kilobytes
    maxBodyLength: 150 * 1024 * 1024, // 150mb in bytes
    mailNotifications: false,
    errorMailRecipients: [
        'Hubert.Droulez@ec.europa.eu',
        'rafal.rokoszewski@ext.ec.europa.eu',
        'szymon.lubieniecki@ext.ec.europa.eu',
        'Constantin-Mihai.STEFAN@ext.ec.europa.eu',
        'Julien.CASTIAUX@ec.europa.eu',
    ],
    redis: redis.dev,
    apps,
    appServices: {
        webgate: Object.keys(apps).filter(app => apps[app].webgateService),
        intragate: Object.keys(apps).filter(app => apps[app].intragateService),
    },
    secundaApps: Object.keys(apps).filter(app => apps[app].secundaAuthz),
    secunda,
    proxy,
    amecoToken,
    mailbox,
    ldap,
    cns,
    excelService: process.env.EXCEL_SERVICE,
    fmr: process.env.FASTOP_FMR_URL || 'http://halmost.cc.cec.eu.int:8090/FusionRegistry/sdmx/v2'
}

const localConf = {
    host: 'http://192.168.99.100',
    useHostPort: true,
    redis: redis.local,
    apps: {
        da: Object.assign({}, apps.da, {host: 'da'}),
        mda: Object.assign({}, apps.mda, {host: 'mda'}),
        dashboard: Object.assign({}, apps.dashboard, {host: 'dashboard'}),
        outputGap: Object.assign({}, apps.outputGap, {host: 'og'}),
        ctyStatus: Object.assign({}, apps.ctyStatus, {host: 'cs'}),
        secunda: Object.assign({}, apps.secunda, {host: 'secunda'}),
        externalData: Object.assign({}, apps.externalData, {host: 'ed'}),
        webQuery: Object.assign({}, apps.webQuery, {host: 'wq'}),
        stats: Object.assign({}, apps.stats, {host: 'stats'}),
        task: Object.assign({}, apps.task, {host: 'task'}),
        fpapi: Object.assign({}, apps.fpapi, {host: 'fpapi'}),
        notification: Object.assign({}, apps.notification, {host: 'ns'}),
        DFM: Object.assign({}, apps.DFM, {host: 'dfm'}),
        DRM: Object.assign({}, apps.DRM, {host: 'drm'}),
        DBP: Object.assign({}, apps.DBP, {host: 'dbp'}),
        SCP: Object.assign({}, apps.SCP, {host: 'scp'}),
        FGD: Object.assign({}, apps.FGD, {host: 'fgd'}),
        NFR: Object.assign({}, apps.NFR, {host: 'nfr'}),
        IFI: Object.assign({}, apps.IFI, {host: 'ifi'}),
        MTBF: Object.assign({}, apps.MTBF, {host: 'mtbf'}),
        GBD: Object.assign({}, apps.GBD, {host: 'gbd'}),
        PIM: Object.assign({}, apps.PIM, {host: 'pim'}),
        FDMS: Object.assign({}, apps.FDMS, {host: 'fdms'}),
        FDMSIE: Object.assign({}, apps.FDMSIE, {host: 'fdmsie'}),
        AUXTOOLS: Object.assign({}, apps.AUXTOOLS, {host: 'auxtools'}),
        ADDIN: Object.assign({}, apps.ADDIN, {host: 'addin'}),
        DSLOAD: Object.assign({}, apps.DSLOAD, {host: 'dsload'}),
        COSNAP: Object.assign({}, apps.COSNAP, {host: 'cosnap'}),
        FPADMIN: Object.assign({}, apps.FPADMIN, {host: 'fpadmin'}),
        BCS: Object.assign({}, apps.BCS, {host: 'bcs'}),
        SUM: Object.assign({}, apps.SUM, {host: 'sum'}),
        AMECO: Object.assign({}, apps.AMECO, {host: 'ameco'}),
        fdmsstar: Object.assign({}, apps.fdmsstar, {host: 'fdmsstar'}),
        eucam: Object.assign({}, apps.eucam, {host: 'eucam'}),
        sdmx: Object.assign({}, apps.sdmx, {host: 'sdmx'}),
        hicp: Object.assign({}, apps.hicp, {host: 'hicp'}),
        amecodownload: Object.assign({}, apps.amecodownload, {host: 'ad'}),
        bcsstar: Object.assign({}, apps.bcsstar, {host: 'bcsstar'}),
        neer: Object.assign({}, apps.neer, {host: 'neer'}),
        fpcalc: Object.assign({}, apps.fpcalc, {host: 'fpcalc'}),
        CORECOM: Object.assign({}, apps.CORECOM, {host: 'corecom'}),
        corecomstar: Object.assign({}, apps.corecomstar, {host: 'corecomstar'}),
    },
}

const conf = {
    local: localConf,
    windows: {
        host: 'http://' + process.env.COMPUTERNAME,
        localDev: true,
        httpsPort: 3443,
        useHostPort: true,
        ecas: 'https://ecas.ec.europa.eu',
        redis: redis.podman_dev,
    },
    PODMAN_DEV: {
            host: 'http://0.0.0.0',
            localDev: true,
            httpsPort: 3443,
            useHostPort: true,
            ecas: 'https://ecas.ec.europa.eu',
            redis: redis.podman_dev,
            ecasRedirect: {
                host: 'http://fp-dev-srv.cc.cec.eu.int',
                httpPort: process.env.PODMAN_HTTP_PORT,
                httpsPort: process.env.PODMAN_HTTPS_PORT,
            }
    },
    AZURE: Object.assign({}, localConf,
        {
            ecas: 'https://ecas.ec.europa.eu',
            host: 'https://vmdataorbis.westeurope.cloudapp.azure.com/fastop',
            useHostPort: false,
            httpPort: 0,
    }),
    DEV: {
        host: 'https://intragate.development.ec.europa.eu/fastop',
        ecas: 'https://ecas.ec.europa.eu',
        apps: getApps('localhost', 'halmost'),
    },
    TEST_INTRAGATE: {
        host: 'https://intragate.test.ec.europa.eu/fastop',
        ecas: 'https://ecas.ec.europa.eu',
        apps: getApps('localhost', 'famproppea'),
    },
    TRAINING_INTRAGATE: {
        host: 'https://intragate.training.ec.europa.eu/fastop',
        ecas: 'https://ecas.ec.europa.eu',
        apps: getApps('localhost', 'milloncent'),
    },
    ACCEPTANCE_INTRAGATE: {
        host: 'https://intragate.acceptance.ec.europa.eu/fastop',
        ecas: 'https://ecasa.cc.cec.eu.int:7002',
        apps: Object.assign(getApps('localhost', 'belizat'), {
            BCS: {
                host: 'bassedea',
                port: 3290,
                intragateService: true,
                secundaAuthz: true,
            },
        }),
    },
    ACCEPTANCE_WEBGATE: {
        host: 'https://webgate.acceptance.ec.europa.eu/fastop',
        ecas: 'https://ecas.acceptance.ec.europa.eu',
        apps: getApps('localhost', 'belizat'),
    },
    PRODUCTION_INTRAGATE: {
        host: 'https://intragate.ec.europa.eu/fastop',
        ecas: 'https://ecas.ec.europa.eu',
        apps: Object.assign(getApps('localhost', 'pashese'), {
            BCS: {
                host: 'purniftene',
                port: 3290,
                intragateService: true,
                secundaAuthz: true,
            },
        }),
        redis: redis.prod,
    },
    PRODUCTION_WEBGATE: {
        host: 'https://webgate.ec.europa.eu/fastop',
        ecas: 'https://ecas.ec.europa.eu',
        apps: getApps('localhost', 'pashese'),
        redis: redis.prod,
    },
}

exports.config = Object.assign(common, conf[env])
