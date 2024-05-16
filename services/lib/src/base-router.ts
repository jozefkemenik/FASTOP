import * as multer from 'multer'
import { NextFunction, Request, Response, Router, RouterOptions } from 'express'

import { AuthzError } from './error.service'
import { AuthzLibService } from '.'
import { CountryStatusApi } from './api/country-status.api'
import { DashboardApi } from './api/dashboard.api'
import { EApps } from 'config'
import { EErrors } from '../../shared-lib/dist/prelib/error'
import { EStatusRepo } from 'country-status'
import { IBinaryFile } from './template/shared-interfaces'
import { IUserAuthzs } from 'users'
import { config } from '../../config/config'


export abstract class BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(protected readonly appId?: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method buildRouter
     *********************************************************************************************/
    public buildRouter(options?: RouterOptions): Router {
        const router = this.configRoutes(Router(options))
        return this.configInternalRoutes(router.use(AuthzLibService.checkAuthorisation()))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method checkEditable
     *********************************************************************************************/
    protected checkEditable(
        predicate: (ctyStatusId: EStatusRepo, appStatusId: EStatusRepo, req?: Request) => boolean,
        countryGetter: (req: Request) => string = (req => req.params.countryId),
    ) {
        return (req: Request, res: Response, next: NextFunction): void => {
            const countryId = countryGetter(req)

            if (!countryId) next(new AuthzError())
            else {
                Promise.all([
                    CountryStatusApi.getCountryStatusId(this.appId, countryId),
                    DashboardApi.getApplicationStatus(this.appId),
                ]).then(statuses =>
                    predicate(...statuses, req) ? next() : res.json(EErrors.APP_CTY_STATUS)
                )
            }
        }
    }

    /**********************************************************************************************
     * @method configRoutes
     *********************************************************************************************/
    protected abstract configRoutes(router: Router): Router

    /**********************************************************************************************
     * @method configInternalRoutes
     *********************************************************************************************/
    protected configInternalRoutes(router: Router): Router {
        return router
    }

    /**********************************************************************************************
     * @method getUserId
     *********************************************************************************************/
    protected getUserId(req: Request): string {
        return req.get('authLogin')
    }

    /**********************************************************************************************
     * @method getUserUnit
     *********************************************************************************************/
    protected getUserUnit(req: Request): string {
        return req.get('authDept')
    }

    /**********************************************************************************************
     * @method getAllUserAuthorizations
     *********************************************************************************************/
    protected getAllUserAuthorizations(req: Request): IUserAuthzs {
        return req.get('allAuthz') ? JSON.parse(req.get('allAuthz')) : undefined
    }

    /**********************************************************************************************
     * @method getArrayQueryParam
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    protected getArrayQueryParam(queryParam: any): string[] {
        return queryParam?.split(',') || []
    }

    /**********************************************************************************************
     * @method isOnIntragate
     *********************************************************************************************/
     protected isOnIntragate(req: Request): boolean {
        return req.get('onIntragate') === 'true'
    }

    /**********************************************************************************************
     * @method getMulter
     *********************************************************************************************/
    protected getMulter(...fileExtensions: string[]) {
        const getFileExtension = (fileName: string) => {
            const tmp = fileName.split('.')
            return tmp[tmp.length - 1].toLowerCase()
        }

        const storage = multer.memoryStorage()
        return multer({
            storage,
            limits: {
                fileSize: config.maxBodyLength
            },
            fileFilter: (req, file, callback) => {
                if (fileExtensions.indexOf(getFileExtension(file.originalname)) === -1) {
                    callback(new Error('Unsupported file type!'))
                } else {
                    callback(null, true)
                }
            }
        })
    }

    /**********************************************************************************************
     * @method isForecastPublished
     *********************************************************************************************/
    protected isForecastPublished(appStatus: EStatusRepo, roundSid: number, currentRoundSid: number): boolean {
        return EStatusRepo.ST_CLOSED === appStatus  ||
              (!isNaN(roundSid) && !isNaN(currentRoundSid) && roundSid !== currentRoundSid)
    }

    /**********************************************************************************************
     * @method sendFile
     *********************************************************************************************/
    protected sendFile(file: IBinaryFile, res: Response) {
        if (file) {
            res.setHeader('Content-Disposition', `attachment;filename="${file.fileName}"`)
            res.setHeader('Content-Type', file.contentType)
            res.send(Buffer.from(file.content))
        } else {
            res.sendStatus(204)
        }
        return res.end()
    }
}
