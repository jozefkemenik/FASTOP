import { NextFunction, Request, Response } from 'express'

import { EApps } from 'config'
import { config } from '../../config/config'

import { ISPOptions, STRING } from './db'
import { Level, LoggingService } from './logging.service'
import { AuthzLibService } from '.'
import { DataAccessApi } from './api/data-access.api'

export interface IError extends Error {
    method: string
}

export class ApiKeyError extends Error {}
export class AuthzError extends Error {}
export class AuthnRequiredError extends Error {}
export class AuthWqError extends Error {}
export class AuthzWqError extends Error {}

export class ErrorService {
    /**********************************************************************************************
     * @method errorHandler
     *********************************************************************************************/
    public static errorHandler(logs: LoggingService, sendMail = true) {
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        return (err: IError, req: Request, res: Response, next: NextFunction) => {
            let forbiddenError: string
            let responseStatus = 403
            switch (true) {
                case err instanceof ApiKeyError:
                    forbiddenError = 'Invalid API key.'
                    break
                case err instanceof AuthzError:
                    forbiddenError =
                        err.message ||
                        `User ${req.get('authLogin')} in groups ${AuthzLibService.getUserGroups(req)}` +
                            ` is not authorised to perform this action.`
                    break
                case err instanceof AuthnRequiredError:
                    forbiddenError = err.message || 'Authentication required'
                    responseStatus = 401
                    res.set('WWW-Authenticate', 'Basic realm="Restricted Area"')
                    break
                case err instanceof AuthWqError:
                    res.send(err.message || 'User not authenticated')
                    return
                case err instanceof AuthzWqError:
                    res.send(`User ${req.get('authLogin')} is not authorised to run this web-query.`)
                    return
            }
            if (forbiddenError) {
                res.status(responseStatus).send(forbiddenError)
                logs.log(`${req.method} ${req.originalUrl}: ${forbiddenError}`, Level.WARNING)
            } else {
                const message = `${err.method}: ${err.toString()}${this.getErrorUser(req)}\ntrace: ${err.stack}`
                logs.log(message, Level.ERROR)

                if (config.mailNotifications && sendMail) {
                    this.errorMailNotification(logs.appId, message).catch(() =>
                        logs.log('Sending an error email has failed!', Level.ERROR),
                    )
                }
                res.status(500).send('Internal error')
            }
        }
    }

    /**********************************************************************************************
     * @method errorMailNotification
     *********************************************************************************************/
    public static errorMailNotification(appId: EApps, message: string): Promise<void> {
        const options: ISPOptions = {
            params: [
                { name: 'p_env', type: STRING, value: process.env.HOSTNAME },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_message', type: STRING, value: message },
                { name: 'p_recipients', type: STRING, value: config.errorMailRecipients },
            ],
        }
        return DataAccessApi.execSP('core_error.sendErrorEmail', options)
    }

    /**********************************************************************************************
     * @method getErrorUser
     *********************************************************************************************/
    public static getErrorUser(req: Request): string {
        const user = req.get('authLogin')
        return (user && ` (user: ${user})`) || ''
    }
}
