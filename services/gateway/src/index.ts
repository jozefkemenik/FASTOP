import * as http from 'http'

import { EApps } from 'config'
import { LoggingService } from '../../lib/dist/logging.service'
import { WebServer } from './server'
import { config } from '../../config/config'


const logs = new LoggingService(EApps.GATEWAY)

if (config.httpPort) {
    http.createServer(
        WebServer.getServer(logs).app
    ).listen(
        config.httpPort,
        () => logs.log(`Express http server (${EApps.GATEWAY}) listening on port ${config.httpPort}`)
    )
}

if (config.intragatePort) {
    http.createServer(
        WebServer.getServer(logs, true).app
    ).listen(
        config.intragatePort,
        () => logs.log(`Express http server (INTRAGATE ${EApps.GATEWAY}) listening on port ${config.intragatePort}`)
    )
}

if (config.localDev) {
    import('./index_local')
}
