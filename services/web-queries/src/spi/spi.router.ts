import * as swaggerJsdoc from 'swagger-jsdoc'
import { NextFunction, Request, Response, Router } from 'express'
import { Query } from 'express-serve-static-core'

import { IWQMatrixParams, IWQSpiParams, PrecisionType, QueryType } from '.'
import { SharedService } from '../shared/shared.service'
import { SpiController } from './spi.controller'
import { WqRouter } from '../shared/wq.router'

export class SpiRouter extends WqRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService): Router {
        return new SpiRouter(sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: SpiController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super()
        this.controller = new SpiController(sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configFpapiRoutes(router: Router): Router {
        return router
            .get('/iqy/domain', this.getDomainIqyHandler)
            .get('/iqy/geo', this.getGeoIqyHandler)
            .get('/iqy/matrix', this.getMatrixIqyHandler)
            .post('/domain', this.getDomainHandler)
            .post('/geo', this.getGeoHandler)
            .post('/matrix', this.getMatrixHandler)
    }

    /**********************************************************************************************
     * @method getSwaggerOptions
     *********************************************************************************************/
    protected getSwaggerOptions(): swaggerJsdoc.Options {

        return {
            definition: {
                openapi: this.getOpenapiVersion(),
                info: {
                    title: 'SPI API',
                    description: 'SPI web-queries',
                    version: this.getVersion(),
                },
                servers: [{ url: this.getApiUrl('/spi'), }]
            },
            apis: [this.getSwaggerFilePath('/spi.yaml')],
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDomainIqyHandler
     *********************************************************************************************/
    private getDomainIqyHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getSpiIqy(
            QueryType.DOMAIN,
            Object.assign(this.getSpiWQParams(req.query), { destor: null}),
        ).then(
            content => res.status(200)
                          .attachment(`spi-${QueryType.DOMAIN}-webquery.iqy`)
                          .type('txt')
                          .send(content)
          , next
        )
    }

    /**********************************************************************************************
     * @method getGeoIqyHandler
     *********************************************************************************************/
    private getGeoIqyHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getSpiIqy(
            QueryType.GEO,
            this.getSpiWQParams(req.query)
        ).then(
            content => res.status(200)
                .attachment(`spi-${QueryType.GEO}-webquery.iqy`)
                .type('txt')
                .send(content)
            , next
        )
    }

    /**********************************************************************************************
     * @method getMatrixIqyHandler
     *********************************************************************************************/
    private getMatrixIqyHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getSpiIqy(
            QueryType.MATRIX,
            this.getSpiMatrixParams(req.query)
        ).then(
            content => res.status(200)
                .attachment(`spi-${QueryType.MATRIX}-webquery.iqy`)
                .type('txt')
                .send(content)
            , next
        )
    }

    /**********************************************************************************************
     * @method getDomainHandler
     *********************************************************************************************/
    private getDomainHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getSpiData(QueryType.DOMAIN, req.body).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getGeoHandler
     *********************************************************************************************/
    private getGeoHandler = (req: Request, res: Response, next: NextFunction) => {
        const params: IWQSpiParams = req.body
        if (['EXTERNALGEO', 'TRADEGEO'].includes(params.domain.toUpperCase())) {
            return this.controller.getSpiData(QueryType.GEO, params).then(res.send.bind(res), next)
        } else {
            next(Error(`Domain "${params.domain}" does not support this method!`))
        }
    }

    /**********************************************************************************************
     * @method getMatrixHandler
     *********************************************************************************************/
    private getMatrixHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getSpiMatrixData(req.body).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getSpiWQParams
     *********************************************************************************************/
    private getSpiWQParams(query: Query): IWQSpiParams {
        return {
            domain: query.domain as string,
            indicator: query.indicator as string,
            country: query.country as string,
            year: query.year as string,
            start_year: Number(query.start_year),
            end_year: Number(query.end_year),
            nomenclature: query.nomenclature as string,
            nomenclature_code: query.nomenclature_code as string,
            no_nomenclature_code: query.no_nomenclature_code as string,
            destor: query.destor as string,
            decimal: this.getPrecisionType(query.decimal),
        }
    }

    /**********************************************************************************************
     * @method getPrecisionType
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private getPrecisionType(param: any): PrecisionType {
        let precision: PrecisionType = param
        if (param !== 'None' && precision !== 'All') {
            precision = Number(param)
            if (isNaN(precision) || precision < 0) precision = 'All'
        }
        return precision
    }

    /**********************************************************************************************
     * @method getSpiMatrixParams
     *********************************************************************************************/
    private getSpiMatrixParams(query: Query): IWQMatrixParams {
        return {
            country: query.country as string,
            indicator: query.indicator as string,
            industry: query.industry as string,
            product: query.product as string,
            year: query.year as string,
            start_year: Number(query.start_year),
            end_year: Number(query.end_year),
            decimal: this.getPrecisionType(query.decimal),
        }
    }
}
