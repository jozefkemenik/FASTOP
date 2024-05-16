import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'

import { AuthzLibService } from '../../../lib/dist'
import { ConfigController } from './config.controller'
import { ConfigService } from './config.service'

export class ConfigRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new ConfigRouter().buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: ConfigController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super()
        this.controller = new ConfigController(new ConfigService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/archiveRoundInfo/:appId/:year/:period/:storageId/:version?', this.archiveRoundInfoHandler)
            .get('/roundInfo/:appId/:roundSid/:storageSid', this.getRoundInfoHandler)
            .get('/currentRoundInfo/:appId', this.getCurrentRoundInfoHandler)
            .get('/currentStorage/:appId', this.getCurrentStorageHandler)
            .get('/rounds',this.getRoundsHandler)
            .get('/rounds/:roundSid',this.getRoundHandler)
            .get('/storages/:appId', this.getStoragesHandler)
            .get('/storage/:appId/:storageSid',this.getStorageHandler)
            .get('/geoAreas',this.getGeoAreasHandler)
            .get('/country/:countryId',this.getCountryHandler)
            .get('/countries/:countryIds',this.getCountriesHandler)
            .get('/countryGroupCountries/:countryGroupId',this.getCountryGroupCountriesHandler)
            .get('/countryGroupsWithCountries', this.getCountryGroupsWithCountriesHandler)
            .get('/geoAreaMappings',this.getGeoAreaMappingsHandler)
            .get('/roundStorage', this.getRoundStorageHandler)
            .get('/help', this.getHelpHandler)
            .get('/applicationCountries/:appId', this.getApplicationCountriesHandler)
            .get('/latestOffRound/:appId/:roundSid/:offset',
            AuthzLibService.checkAuthorisation('SU','ADMIN', 'CTY_DESK','MS', 'READ_ONLY'),
            this.getLatestOffsetRoundHandler)
            .get('/latestRound/:appId/:roundSid',
            AuthzLibService.checkAuthorisation('SU','ADMIN', 'CTY_DESK','MS', 'READ_ONLY'),
            this.getLatestRoundHandler)
            .get('/roundYear/:roundSid',
            AuthzLibService.checkAuthorisation('SU','ADMIN', 'CTY_DESK','MS', 'READ_ONLY'),
            this.getRoundYearHandler)
        }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method archiveRoundInfoHandler
     *********************************************************************************************/
    private archiveRoundInfoHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getPreviousRoundInfo(
            req.params.appId?.toUpperCase() as EApps,
            Number(req.params.year),
            req.params.period,
            req.params.storageId,
            Number(req.params.version)
        ).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getRoundInfoHandler
     *********************************************************************************************/
    private getRoundInfoHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getArchiveRoundInfo(
            req.params.appId?.toUpperCase() as EApps,
            Number(req.params.roundSid),
            Number(req.params.storageSid)
        ).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getCurrentRoundInfoHandler
     *********************************************************************************************/
    private getCurrentRoundInfoHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCurrentRoundInfo(
            req.params.appId?.toUpperCase() as EApps
        ).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getRoundsHandler
     *********************************************************************************************/
    private getRoundsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getRounds(
            (req.query.appId as string)?.toUpperCase() as EApps
        ).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getRoundHandler
     *********************************************************************************************/
    private getRoundHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getRoundInfo(Number(req.params.roundSid)).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getStoragesHandler
     *********************************************************************************************/
    private getStoragesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getStorages(req.params.appId?.toUpperCase() as EApps).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getStorageHandler
     *********************************************************************************************/
    private getStorageHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getStorage(
            req.params.appId?.toUpperCase() as EApps, Number(req.params.storageSid)
        ).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getGeoAreasHandler
     *********************************************************************************************/
    private getGeoAreasHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getGeoAreas().then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getCountryHandler
     *********************************************************************************************/
    private getCountryHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountry(req.params.countryId).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountries(this.getArrayQueryParam(req.params.countryIds)).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getCountryGroupCountriesHandler
     *********************************************************************************************/
    private getCountryGroupCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryGroupCountries(
            req.params.countryGroupId, req.query.inactive === 'true'
        ).then( res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryGroupsWithCountriesHandler
     *********************************************************************************************/
    private getCountryGroupsWithCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryGroupsWithCountries(
            this.getArrayQueryParam(req.query.ctyGroups)
        ).then( res.json.bind(res), next)

    /**********************************************************************************************
     * @method getGeoAreaMappingsHandler
     *********************************************************************************************/
    private getGeoAreaMappingsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getGeoAreaMappings(
            this.getArrayQueryParam(req.query.mappings)
        ).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getRoundStorageHandler
     *********************************************************************************************/
    private getRoundStorageHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getRoundStorage(
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            Number(req.query.textSid)
        ).then( res.json.bind(res), next )


    /**********************************************************************************************
     * @method getHelpHandler
     *********************************************************************************************/
    private getHelpHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getHelpLink().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCurrentStorageHandler
     *********************************************************************************************/
    private getCurrentStorageHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCurrentStorage(req.params.appId?.toUpperCase() as EApps).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getApplicationCountriesHandler
     *********************************************************************************************/
    private getApplicationCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getApplicationCountries(
            req.params.appId?.toUpperCase() as EApps
        ).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getLatestOffsetRoundHandler
     *********************************************************************************************/
    private getLatestOffsetRoundHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getLatestOffsetRound(
            req.params.appId?.toUpperCase() as EApps,
            Number(req.params.roundSid),
            Number(req.params.offset)
        ).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getLatestRoundHandler
     *********************************************************************************************/
    private getLatestRoundHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getLatestRound(
            req.params.appId?.toUpperCase() as EApps,
            Number(req.params.roundSid)
        ).then( res.json.bind(res), next )

    /**********************************************************************************************
     * @method getRoundYearHandler
     *********************************************************************************************/
    private getRoundYearHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getRoundYear(
            Number(req.params.roundSid)
        ).then( res.json.bind(res), next )

}
