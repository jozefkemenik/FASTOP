import { EApps, IDbAppConfig } from 'config'
import { LoggingService } from '../../lib/dist'
import { WebServer } from './server'
import { config } from '../../config/config'


const appConfig = config.apps[EApps.COSNAP] as IDbAppConfig
const logs = new LoggingService(EApps.COSNAP)
const server = WebServer.getServer(appConfig.db, logs)

const port = config.apps[server.appId].port
server.app.listen(
    port,
    () => logs.log(`Express server (${server.appId}) listening on port ${port}`)
)
