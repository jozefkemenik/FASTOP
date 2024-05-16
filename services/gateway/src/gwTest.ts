import { Level, LoggingService } from '../../lib/dist/logging.service'
import { EApps } from 'config'
import { config } from '../../config/config'

import { EcasClient } from './ecasClient'

const logs = new LoggingService(EApps.GATEWAY)
const ecasClient = new EcasClient(config.host, 0, 0, logs,
    {
        requestedGroups: 'ECFIN*',
        debug: true,
        userDetails: true,
        acceptedStrengths: ['STRONG', 'CLIENT_CERT'],
    }
)
const req = {
    query: {}
}

/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
ecasClient.authenticate(req as any, false, 'test').then(
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    resp => logs.log('Successfully connected to EU Login', Level.INFO),
    reject => logs.log(`ECAS rejected: ${reject}`, Level.WARNING),
)
