export interface IProxyConfig {
    http: string
    https: string
}

export interface ISchemaConfigs {
    [schema: string]: IDbConfig
}

export interface IAppConfig {
    host: string
    port: number
    intragateService?: boolean
    webgateService?: boolean
    secundaAuthz?: boolean
}

export interface IDbAppConfig extends IAppConfig {
    db: ISchemaConfigs
}

export const enum EDbProviders {
    ORACLE = 'oracle',
    MYSQL = 'mysql',
    MONGO = 'mongo',
}

export interface IOracleConfig {
    connectString: string,
    user: string,
    password: string,
    poolAlias: string,
    poolMin: number,
    poolMax: number,
    poolIncrement: number,
    stmtCacheSize: number,
}

export interface IMySqlConfig {
    host: string,
    port: number,
    user: string,
    password: string,
    database : string,
    connectionLimit: number,
}

export interface IMongoConfig {
    uri: string
    database: string
    pipelinesCollection?: string
}

export type IDbProviderConfig = IOracleConfig | IMySqlConfig | IMongoConfig

export interface IDbConfig {
    provider: EDbProviders
    maxRows?: number
    providerConfig: IDbProviderConfig
}

export interface ISecunda {
    username: string
    password: string
    serviceUrl: string
    useUM?: boolean
    secundaEndpoint: string
    apiGatewayEndpoint: string
    consumerKey: string
    consumerSecret: string
}

export interface IAmecoToken {
    apiGatewayEndpoint: string
    consumerKey: string
    consumerSecret: string
}

export interface IMailboxConfig {
    host: string
    port: number
    sender: string
}

export interface ICnsConfig {
    url: string
    auth: string // base64(key:pass)
}

export interface IRedisBaseOptions {
    showFriendlyErrorStack?: boolean
}

export interface IRedisSentinel extends IRedisBaseOptions {
    host: string
    port: number
}

export interface IRedisFarm extends IRedisBaseOptions {
    sentinels: IRedisSentinel[]
    name: string
    password: string
}

export interface ILdapConfig {
    ldapHost: string
    ldapPort: string
    ldapUser: string
    ldapPass: string
    ldapBase: string
}

export type IRedisConfig = IRedisSentinel | IRedisFarm

export const enum EApps {
    GATEWAY = "gateway",
    DA = "da",
    MDA = "mda",
    SECUNDA = "secunda",
    DASHBOARD = "dashboard",
    STATS = "stats",
    OG = "outputGap",
    CS = "ctyStatus",
    TASK = "task",
    WQ = "webQuery",
    FPAPI = "fpapi",
    ED = "externalData",
    NOTIFICATION = "notification",
    EUCAM = "eucam",
    SDMX = "sdmx",
    SPI = "spi",
    HICP = "hicp",
    NEER = "neer",
    AD = "amecodownload",
    FPCALC = "fpcalc",
    FPLM = "fplm",
    DFM = "DFM",
    DRM = "DRM",
    DBP = "DBP",
    SCP = "SCP",
    FGD = "FGD",
    NFR = "NFR",
    IFI = "IFI",
    MTBF = "MTBF",
    GBD = "GBD",
    PIM = "PIM",
    FDMS = "FDMS",
    FDMSIE = "FDMSIE",
    AUXTOOLS = "AUXTOOLS",
    ADDIN = "ADDIN",
    DSLOAD = "DSLOAD",
    COSNAP = "COSNAP",
    AMECO = "AMECO",
    FPADMIN = "FPADMIN",
    SUM = "SUM",
    FDMSSTAR = "fdmsstar",
    BCS = "BCS",
    BCSSTAR = "bcsstar",
}

export interface IConfig {
    host: string
    useHostPort: boolean
    httpPort: number
    httpsPort: number
    intragatePort: number
    localDev?: boolean
    ecas: string
    ecasPassthru: string
    uploadDir: string
    secret: string
    apiKey: string
    jwtSecret: string
    sessionTimeout: number
    accessCodeTimeout: number
    JSONLimit: number
    maxBodyLength: number
    mailNotifications: boolean
    errorMailRecipients: string[]
    redis: IRedisConfig
    apps: {[app in EApps]: IAppConfig}
    appServices: {
        intragate: string[]
        webgate: string[]
    }
    secundaApps: EApps[]
    secunda: ISecunda
    amecoToken: IAmecoToken
    proxy: IProxyConfig
    webgateAdmin: boolean
    amecoPublicHost?: string
    mailbox: IMailboxConfig
    ldap: ILdapConfig
    cns: ICnsConfig
    excelService: string
    // custom url and port where redirection from ecas should come back
    ecasRedirect?: {
        host: string
        httpPort?: number
        httpsPort?: number
    },
    fmr: string
}

export const config: IConfig
export type DAType = EApps.DA
export type MDAType = EApps.MDA
