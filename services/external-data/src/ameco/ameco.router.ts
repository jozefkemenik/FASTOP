import { NextFunction, Request, Response, Router } from 'express'

import { AmecoController } from './ameco.controller'
import { AmecoInternalService } from './ameco-internal.service'
import { AmecoOnlineService } from './ameco-online.service'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'


export class AmecoRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(
        amecoDbService: DbService<DbProviderService>,
        amecoOnlineDbService: DbService<DbProviderService>,
    ): Router {
        return new AmecoRouter(amecoDbService, amecoOnlineDbService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: AmecoController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        amecoDbService: DbService<DbProviderService>,
        amecoOnlineDbService: DbService<DbProviderService>,
    ) {
        super()
        this.controller = new AmecoController(
            new AmecoInternalService(amecoDbService), new AmecoOnlineService(amecoOnlineDbService)
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/restricted/seriesData', this.getRestrictedSeriesDataHandler)
            .get('/restricted/lastUpdate', this.getRestrictedLastUpdateHandler)
            .get('/restricted', this.getAmecoRestrictedDataHandler)
            .get('/sdmx/data/restricted/:queryKey', this.getSdmxRestrictedDataHandler)
            .get('/internal/forecastPeriod', this.getAmecoInternalForecastPeriodHandler)
            .get('/internal/metadata/countries', this.getAmecoInternalMetadataCountriesHandler)
            .get('/internal/metadata/trn', this.getAmecoInternalMetadataTransformationsHandler)
            .get('/internal/metadata/agg', this.getAmecoInternalMetadataAggregationsHandler)
            .get('/internal/metadata/unit', this.getAmecoInternalMetadataUnitsHandler)
            .get('/internal/metadata/serie', this.getAmecoInternalMetadataSeriesHandler)
            .get('/internal/metadata/tree', this.getAmecoInternalMetadataTreeHandler)
            .get('/sdmx/data/:dataset/:queryKey', this.getSdmxDataHandler)
            .get('/:amecoType/countries', this.getCountriesHandler)
            .get('/:amecoType/series', this.getSeriesHandler)
            .get('/:amecoType/chapters', this.getChaptersHandler)
            .get('/:amecoType/seriesData', this.getSeriesDataHandler)
            .get('/:amecoType/lastUpdate', this.getLastUpdateHandler)
            .get('/:amecoType', this.getAmecoDataHandler)
            .post('/logStats', this.logStatsHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoDataHandler
     *********************************************************************************************/
    private getAmecoDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoData(
            this.amecoType(req),
            this.getArrayQueryParam(req.query.indicatorIds),
            this.getArrayQueryParam(req.query.countryIds),
            req.query.defaultCountries as string === 'Y',
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoRestrictedDataHandler
     *********************************************************************************************/
    private getAmecoRestrictedDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoData(
            AmecoType.RESTRICTED,
            this.getArrayQueryParam(req.query.indicatorIds),
            this.getArrayQueryParam(req.query.countryIds),
            req.query.defaultCountries as string === 'Y',
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getLastUpdateHandler
     *********************************************************************************************/
    private getLastUpdateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getLastUpdate(this.amecoType(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getRestrictedLastUpdateHandler
     *********************************************************************************************/
    private getRestrictedLastUpdateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getLastUpdate(AmecoType.RESTRICTED).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountries(this.amecoType(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSeriesHandler
     *********************************************************************************************/
    private getSeriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSeries(this.amecoType(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getChaptersHandler
     *********************************************************************************************/
    private getChaptersHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getChapters(this.amecoType(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSeriesDataHandler
     *********************************************************************************************/
    private getSeriesDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSeriesData(
            this.amecoType(req),
            req.query.countries as string,
            req.query.series as string,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getRestrictedSeriesDataHandler
     *********************************************************************************************/
    private getRestrictedSeriesDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSeriesData(
            AmecoType.RESTRICTED,
            req.query.countries as string,
            req.query.series as string,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSdmxDataHandler
     *********************************************************************************************/
    private getSdmxDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSdmxData(
            req.params.dataset, req.params.queryKey, req.query.startPeriod as string, req.query.endPeriod as string
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSdmxRestrictedDataHandler
     *********************************************************************************************/
    private getSdmxRestrictedDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSdmxData(
            'restricted', req.params.queryKey, req.query.startPeriod as string, req.query.endPeriod as string
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoInternalForecastPeriodHandler
     *********************************************************************************************/
    private getAmecoInternalForecastPeriodHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.isAmecoInternalForecastPeriod().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoInternalMetadataCountriesHandler
     *********************************************************************************************/
    private getAmecoInternalMetadataCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoInternalMetadataCountries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoInternalMetadataTransformationsHandler
     *********************************************************************************************/
    private getAmecoInternalMetadataTransformationsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoInternalMetadataTransformations().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoInternalMetadataAggregationsHandler
     *********************************************************************************************/
    private getAmecoInternalMetadataAggregationsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoInternalMetadataAggregations().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoInternalMetadataUnitsHandler
     *********************************************************************************************/
    private getAmecoInternalMetadataUnitsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoInternalMetadataUnits().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoInternalMetadataSeriesHandler
     *********************************************************************************************/
    private getAmecoInternalMetadataSeriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoInternalMetadataSeries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoInternalMetadataTreeHandler
     *********************************************************************************************/
    private getAmecoInternalMetadataTreeHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoInternalMetadataTree().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method amecoType
     *********************************************************************************************/
    private amecoType(req: Request) {
        return req.params.amecoType as AmecoType
    }

    /**********************************************************************************************
     * @method logStatsHandler
     *********************************************************************************************/
    private logStatsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.logStats(req.body).then(res.json.bind(res), next)
}
