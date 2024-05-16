import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'
import { EStatusRepo } from 'country-status'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'
import { GridVersionType } from '../../../../shared-lib/dist/prelib/fisc-grids'
import { HelpMsgType } from '../help/shared-interfaces'
import { IDownloadCSVParams } from '.'

import { FiscGridController } from './grid.controller'
import { FiscGridService } from './grid.service'

export abstract class FiscGridRouter<
    S extends FiscGridService, C extends FiscGridController<S>
> extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(appId: EApps, protected readonly controller: C) {
        super(appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configLocalRoutes routes configuration for FiscGridsRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/indicators/:source?', this.getIndicatorsHandler)
            .get('/datatypes/', this.getDataTypeHandler)
            .get('/helpMessages/:helpMsgTypeId', this.getHelpMessagesHandler)
            .get('/country/:gridId', this.getCountryGridHandler)
            .get('/lines/byRounds/:roundSids', this.getLinesByRoundsHandler)
            .get('/lines/:roundGridSid', this.getLinesHandler)
            .get('/cols/:roundGridSid', this.getColsHandler)
            .get('/templateDef/:gridId?', this.getGridsTemplateDefinitionsHandler)
            .get('/exportDef/:countryId/:gridVersionType/:gridId?',
                this.checkAuthorisationForCountryDeskVersion(),
                AuthzLibService.checkCountryAuthorisation(),
                this.getGridsExportDefHandler)
            .put('/country/:countryId/:fromVersion/:toVersion/:ctyGridSid?',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'MS'),
                this.checkAuthorisationForCountryDeskVersion(
                    (req: Request) =>
                        req.params.fromVersion === GridVersionType.COUNTRY_DESK ||
                        req.params.toVersion === GridVersionType.COUNTRY_DESK
                ),
                AuthzLibService.checkCountryAuthorisation(),
                this.checkEditable(this.areGridsEditable),
                this.copyVersionHandler)
            .get('/ctyDefinitions/:countryId/:gridId?', this.getCountryGridsDefinitionsHandler)
            .get('/ctyVersions/:countryId/:roundSid',
                AuthzLibService.checkCountryAuthorisation(),
                this.getCountryVersionsHandler)
            .get('/downloadCSV',
                AuthzLibService.checkCountryAuthorisation(req => req.query.countryIds as string),
                this.getDownloadCSVHandler)
            .get('/indicatorsForCSV',
                AuthzLibService.checkAuthorisation('SU', 'ADMIN', 'CTY_DESK', 'MS', 'READ_ONLY'),
                this.getIndicatorsForCSVHandler)
            .get('/:roundSid', this.getGridsHandler)
            .get('/scale/:ctyGridSid', this.getCountryRoundScaleHandler)
            .put('/scale/:countryId/:roundSid', 
                this.checkAuthorisationForCountryDeskVersion(),
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'MS'),
                this.checkEditable(this.areGridsEditable),
                this.saveCountryRoundScaleHandler)

        router.route('/country/:countryId/:ctyGridSid/:gridVersionType')
            .all(AuthzLibService.checkCountryAuthorisation(),
                this.checkAuthorisationForCountryDeskVersion())
            .get(this.getCountryGridDataHandler)
            .patch(
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'MS'),
                this.checkEditable(this.areGridsEditable),
                this.patchCountryGridDataHandler)

        router.route('/ctyVersion/:countryId')
            .get(this.getCurrentCountryVersionHandler)
            .post(AuthzLibService.checkAuthorisation('ADMIN'), this.newCountryVersionHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method areGridsEditable
     *********************************************************************************************/
    private areGridsEditable(ctyStatusId: EStatusRepo, appStatusId: EStatusRepo, req: Request) {
        return appStatusId !== EStatusRepo.CLOSED &&
            (ctyStatusId === EStatusRepo.ACTIVE ||
                (ctyStatusId === EStatusRepo.SUBMITTED && AuthzLibService.isCtyDesk(req)))
    }

    /**********************************************************************************************
     * @method checkAuthorisationForCountryDeskVersion
     *********************************************************************************************/
    private checkAuthorisationForCountryDeskVersion(
        performCheck: (req: Request) => boolean =
            (req: Request) => req.params.gridVersionType === GridVersionType.COUNTRY_DESK) {
        return (req: Request, res: Response, next: NextFunction) => {
            if (performCheck(req)) {
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'C1')(req, res, next)
            } else next()
        }
    }

    /**********************************************************************************************
     * @method copyVersionHandler
     *********************************************************************************************/
    private copyVersionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.copyCtyGridVersion(
            req.params.countryId,
            Number(req.params.ctyGridSid),
            req.params.fromVersion,
            req.params.toVersion
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getColsHandler
     *********************************************************************************************/
    private getColsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getGridCols(Number(req.params.roundGridSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryGridDataHandler
     *********************************************************************************************/
    private getCountryGridDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryGridData(
            req.params.countryId,
            Number(req.params.ctyGridSid),
            req.params.gridVersionType as GridVersionType,
            AuthzLibService.isCtyDesk(req),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryGridHandler
     *********************************************************************************************/
    private getCountryGridHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryGrid(
            req.query.countryId as string,
            req.params.gridId,
            Number(req.query.roundSid),
            Number(req.query.ctyVersion),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryGridsDefinitionsHandler
     *********************************************************************************************/
    private getCountryGridsDefinitionsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryGridsDefinitions(req.params.countryId, req.params.gridId)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCurrentyCountryVersionHandler
     *********************************************************************************************/
    private getCurrentCountryVersionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCurrentCountryVersion(req.params.countryId)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryVersionsHandler
     *********************************************************************************************/
    private getCountryVersionsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryVersions(req.params.countryId, Number(req.params.roundSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDownloadCSVHandler
     *********************************************************************************************/
    private getDownloadCSVHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.downloadCSV(this.processDownloadCSVParams(req.query))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getGridsTemplateDefinitionsHandler
     *********************************************************************************************/
    private getGridsTemplateDefinitionsHandler = (req: Request, res: Response, next: NextFunction) =>
            this.controller.getTemplateGridDefinition(req.params.gridId).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getGridsExportDefHandler
     *********************************************************************************************/
    private getGridsExportDefHandler = (req: Request, res: Response, next: NextFunction) =>
            this.controller.getGridsExportDefinition(
                req.params.countryId,
                req.params.gridVersionType as GridVersionType,
                req.params.gridId,
                Number(req.query.roundSid),
            ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getGridsHandler
     *********************************************************************************************/
    private getGridsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getGrids(Number(req.params.roundSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorsHandler
     *********************************************************************************************/
    private getIndicatorsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicators(req.params.source)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDataTypesHandler
     *********************************************************************************************/
    private getDataTypeHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDataTypes()
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getHelpMessagesHandler
     *********************************************************************************************/
    private getHelpMessagesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getHelpMessages(req.params.helpMsgTypeId as HelpMsgType)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getLinesByRoundsHandler
     *********************************************************************************************/
    private getLinesByRoundsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getRoundsLines(
            req.params.roundSids.split(',').map(Number),
            req.query.allColumns === 'true'
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getLinesHandler
     *********************************************************************************************/
    private getLinesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getGridLines(Number(req.params.roundGridSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryRoundScaleHandler
     *********************************************************************************************/
    private getCountryRoundScaleHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryRoundScale(Number(req.params.ctyGridSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorsForCSVHandler
     *********************************************************************************************/
    private getIndicatorsForCSVHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorsForCSV(this.processDownloadCSVParams(req.query))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method saveCountryRoundScaleHandler
     *********************************************************************************************/
    private saveCountryRoundScaleHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.saveCountryRoundScale(req.params.countryId, Number(req.params.roundSid), req.body.scaleId)
            .then(res.json.bind(res), next)
            
    /**********************************************************************************************
     * @method newCountryVersionHandler
     *********************************************************************************************/
    private newCountryVersionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.newCountryVersion(req.params.countryId)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method patchCountryGridDataHandler
     *********************************************************************************************/
    private patchCountryGridDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.patchCountryGridData(
            req.params.countryId,
            Number(req.params.ctyGridSid),
            req.params.gridVersionType as GridVersionType,
            req.body,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method processDownloadCSVParams
     *********************************************************************************************/
    private processDownloadCSVParams(params: object): IDownloadCSVParams {
        return Object.entries(params).reduce((acc, [key, value]: [string, string]) => {
            acc[key] = value.split(',').map(v => key === 'roundSids' ? Number(v) : v)
            return acc
        }, {} as IDownloadCSVParams)
    }
}
