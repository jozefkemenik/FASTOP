import { EApps, IDbAppConfig } from 'config'
import { LoggingService } from '../../lib/dist'
import { WebServer } from './server'
import { config } from '../../config/config'

const appDbConfig = config.apps[EApps.FGD] as IDbAppConfig
startServer(EApps.FGD)

// wait for the db pool to initialize, so the next apps reuse the same pool
setTimeout(() => [EApps.NFR, EApps.IFI, EApps.MTBF, EApps.GBD, EApps.PIM].forEach(startServer), 3000)

function startServer(app) {
    const logs = new LoggingService(app)
    const server = WebServer.getServer(appDbConfig.db, logs)

    const port = config.apps[server.appId].port
    server.app.listen(
        port,
        () => logs.log(`Express server (${server.appId}) listening on port ${port}`)
    )
}
