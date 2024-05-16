import { DashboardApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { IError } from '../../../lib/dist/'

import { IIndicesData } from '../shared'
import { IndicesService } from './indices.service'
import { SharedService } from '../shared/shared.service'

export class IndicesController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private indicesService: IndicesService
               ,private sharedService: SharedService
               ,private appId: EApps) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public async getIndicators(
        indexSid: number, multiEntry: number
    ) {
        return this.indicesService.getIndicators(indexSid, multiEntry).catch(
                    (err: IError) => {
                        err.method = 'IndicesController.getIndicators'
                        throw err
                    }
                )
    }

    /**********************************************************************************************
     * @method getIndiceData
     *********************************************************************************************/
     public async getIndiceData(
        countryId: string, indexSid: number, roundSid: number
    ) {
        const emptyIndiceData : IIndicesData[] = []
        /**Check indice creation before getting data */
        const existsIndices = await this.sharedService.checkIndiceCreation(indexSid, roundSid)
        if (existsIndices > 0) {
            return this.sharedService.getIndiceData(indexSid, roundSid, countryId)
        } else {
            return emptyIndiceData
        }
    }

    /**********************************************************************************************
     * @method getIndiceEntryData
     *********************************************************************************************/
    public async getIndiceEntryData(
        indexSid: number, year: number, countryId: string
    ) {
        return this.sharedService.getIndiceEntryData(indexSid, year, countryId)
    }

    /**********************************************************************************************
     * @method refreshIndView
     *********************************************************************************************/
     public async refreshIndView(
        indexSid: number, roundSid: number, countryId: string, entries: number[]
    ): Promise<number> {
        let res = 0
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        res = await this.indicesService.refreshIndView(indexSid, roundSid, countryId, roundInfo.year).catch(
            (err: IError) => {
                err.method = 'IndexesController.refreshView'
                throw err
            }
        )
        for (const entrySid of entries) {
            res = await this.sharedService.calcAllIndices(indexSid, roundSid, entrySid, countryId)
        }
        return res
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
