import { EApps } from 'config'
import { LoggingService } from '../../lib/dist'
import { WebServer } from './server'
import { config } from '../../config/config'

const logs = new LoggingService(EApps.DASHBOARD)
const server = WebServer.getServer(logs)

const port = config.apps[server.appId].port
server.app.listen(
    port,
    () => logs.log(`Express server (${server.appId}) listening on port ${port}`)
)
