import * as https from 'https'
import * as pem from 'pem'

import { EApps } from 'config'
import { LoggingService } from '../../lib/dist/logging.service'
import { WebServer } from './server'
import { config } from '../../config/config'


const certificateProperties = {
    days: 1, // Validity in days
    selfSigned: true,
}

pem.createCertificate(certificateProperties, (error, keys) => {
    if (error) throw error

    const logs = new LoggingService(EApps.GATEWAY)
    https.createServer(
        { key: keys.serviceKey, cert: keys.certificate, },
        WebServer.getServer(logs, true).app
    ).listen(
        config.httpsPort,
        () => logs.log(`Express https server (INTRAGATE ${EApps.GATEWAY}) listening on port ${config.httpsPort}`)
    )
})
