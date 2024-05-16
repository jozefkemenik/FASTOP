import { EApps, IDbAppConfig } from 'config'
import { LoggingService } from '../../lib/dist'
import { WebServer } from './server'
import { config } from '../../config/config'

const appConfig = config.apps[EApps.MDA] as IDbAppConfig
const logs = new LoggingService(EApps.MDA)
const server = WebServer.getServer(appConfig.db, logs)

server.app.listen(
    appConfig.port,
    () => logs.log(`Express server (${server.appId}) listening on port ${appConfig.port}`)
)
