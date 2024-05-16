import { Session, SessionData } from 'express-session'
import { Redis } from 'ioredis'
import { Request } from 'express'
import { randomBytes } from 'crypto'

import { IAccessToken } from 'users'
import { LoggingService } from '../../lib/dist/logging.service'
import { config } from '../../config/config'

export class AccessTokenClient {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method generateToken
     *********************************************************************************************/
    public static generateToken(req: Request, redis: Redis, logs: LoggingService, ipBased = false): Promise<IAccessToken> {
        const session = req.session
        const accessCode = randomBytes(4).toString('hex')
        const key = ipBased ? req.ip : Buffer.from(`${session.user.ecas.userId}:${accessCode}`).toString('base64')
        const tokenType = ipBased ? 'IP based' : 'Access Code'
        logs.log(`Generating ${tokenType} WQ token for user ${session.user.ecas.userId}`)
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        const { cookie, csrfSecret, ...wqSession } = session
        return redis
                .multi()
                .set(key, JSON.stringify(wqSession))
                .pexpire(key, config.accessCodeTimeout)
                .exec()
                .then(() => ({
                    token: !ipBased ? accessCode : undefined,
                    timeout: config.accessCodeTimeout
                }))
    }

    /**********************************************************************************************
     * @method getUserSessionFromToken
     *********************************************************************************************/
    public static async getUserSessionFromToken(req: Request, redis: Redis): Promise<Session & Partial<SessionData>> {
        let session: string
        if (req.headers.authorization) {
            const key = req.headers.authorization.split(' ')[1]
            if (key) session = await redis.get(key)
        }
        if (!session) session = await redis.get(req.ip)
        
        if (session) delete req.headers.authorization

        return JSON.parse(session)
    }
}
