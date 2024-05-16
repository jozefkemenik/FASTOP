import { BaseFpapiRouter } from '../../../../lib/dist'
import { EApps } from '../../../../config/config'
import { GridsApi } from '../../../../lib/dist/api'
import { IDownloadCSVParams } from '../../../../lib/dist/fisc/grid'

import { SharedService } from '../../shared/shared.service'

export class GridsController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Properties /////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public readonly notAuthenticatedMessage = this.sharedService.notAuthenticatedMessage
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(public readonly appId: EApps, private readonly sharedService: SharedService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getGrids
     *********************************************************************************************/
    public async getGrids(params: IDownloadCSVParams): Promise<string> {
        const data = await GridsApi.getGridsCSV(this.appId, params)
        return this.renderTemplate(data)
    }

    /**********************************************************************************************
     * @method getIqyGridsContent
     *********************************************************************************************/
    public getIqyGridsContent(query: string): string {
        return this.sharedService.buildIqyContent(`${BaseFpapiRouter.HOST}/wq/${this.appId}/grids`, query)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method renderTemplate
     *********************************************************************************************/
    public renderTemplate(data: Array<Array<string | number>>): string {
        const renderFn = this.sharedService.getCompiledTemplate(`../templates/grids.pug`)

        return renderFn({
            lastRefresh: new Date().toLocaleString(),
            headers: data[0],
            rows: data.slice(1).map(row => (row.length ? [this.appId, ...row] : row)),
        })
    }
}
