import { EApps } from 'config'
import { IError } from '../../../lib/dist/error.service'

import { VintagesService } from './vintages.service'

export class VintagesController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private appId: EApps,
        private vintagesService: VintagesService) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getVintageData
     *********************************************************************************************/
    public async getVintageData(
        appId: string, year: number, isAdmin: boolean
    ) {
        const vData = await this.vintagesService.getVintageData(appId, year).catch(
            (err: IError) => {
                    err.method = 'VintagesController.getVintageData'
                    throw err
                }
        )
        const vAttrs = await this.getVtAppAttrs(appId, isAdmin).catch(
            (err: IError) => {
                    err.method = 'VintagesController.getVintageData.getVtAppAttrs'
                    throw err
                }
        )
        
        if (!isAdmin) {
            return vData.map(obj => {
                for (const k of Object.keys(obj)) {
                    if (!vAttrs.map(d => 'COL'+d.VINTAGE_ATTR_SID).includes(k)
                        && k !== 'ENTRY_SID') {
                        delete obj[k]
                    }
                    
                }
                return obj
            })
        } else {
            return vData
        }
    }

    /**********************************************************************************************
     * @method getVtAppAttrs
     *********************************************************************************************/
    public async getVtAppAttrs(
        appId: string, isAdmin: boolean
    ) {
        const vAttrs = await this.vintagesService.getVtAppAttrs(appId).catch(
            (err: IError) => {
                    err.method = 'VintagesController.getVtAppAttrs'
                    throw err
                }
        )
        return isAdmin ? vAttrs : vAttrs.filter(v => v.ADMIN_ONLY !== 1)

    }

    /**********************************************************************************************
     * @method getVintage
     *********************************************************************************************/
    public getVintage(
        vintageType: string, viewType: string
    ) {
        return this.vintagesService.getVintage(vintageType, viewType).catch(
            (err: IError) => {
                    err.method = 'VintagesController.getVintageDetails'
                    throw err
                }
        )

    }

    /**********************************************************************************************
     * @method getVintageViews
     *********************************************************************************************/
    public async getVintageViews(
        vintageType: string, viewType: string
    ) {
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const retDef: {default: any[]} = {default: []}
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const retAll: {all: any[]} = {all: []}
            const vintageCols = await this.vintagesService.getVintageColumns(vintageType, viewType).catch(
                (err: IError) => {
                        err.method = 'VintagesController.getVintageColumns'
                        throw err
                    }
            )

            for (const column of vintageCols) {
                const tempCol = {header: '', field: ''}
                tempCol.header = column.COL_DESCR
                tempCol.field = column.COL_NAME
                if (viewType === 'all') {
                    retAll.all.push(tempCol)
                }
                if (viewType === 'default') {
                    retDef.default.push(tempCol)
                }
            }

            if (viewType === 'all') {
                return retAll
            }
            if (viewType === 'default') {
                return retDef
            }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
