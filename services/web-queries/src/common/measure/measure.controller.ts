import { EApps } from 'config'

import { IArchiveParams, IMeasuresDenormalised } from '../../../../lib/dist/measure'
import { MeasureApi } from '../../../../lib/dist/api/measure.api'

import { SharedService } from '../../shared/shared.service'

export class MeasureController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Properties /////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public readonly notAuthenticatedMessage = this.sharedService.notAuthenticatedMessage

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(protected readonly sharedService: SharedService, private readonly appId: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getMeasures
     *********************************************************************************************/
    public async getMeasures(countryId: string, gdp: boolean, archive: IArchiveParams): Promise<string> {
        const denormalised = await MeasureApi.getMeasures(this.appId, countryId, gdp, archive)
        return this.renderTemplate(denormalised)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method renderTemplate
     *********************************************************************************************/
    public renderTemplate(denormalised: IMeasuresDenormalised): string {
        const renderFn = this.sharedService.getCompiledTemplate(`../templates/measures.pug`)

        return renderFn({
            lastRefresh: new Date().toLocaleString(),
            ...denormalised,
        })
    }
}
