import { EStatusRepo } from 'country-status'
import { Request } from 'express'

import { BIND_OUT, CURSOR, ISPOptions } from '../../../db'
import { IDBSidType, IESACodes, IObjectSIDs, MeasureSharedService } from '../..'
import { AuthzLibService } from '../../../authzLib.service'
import { DataAccessApi } from '../../../api'
import { IDictionaries } from '.'
import { IFDMeasureDetails } from '../measure'

export abstract class FDSharedService extends MeasureSharedService {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    protected _dbpAdoptStatues: IObjectSIDs
    protected _dbpAccPrinciples: IObjectSIDs
    protected _reasons: { map: IObjectSIDs; array: IDBSidType[] }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getColumnValue
     *********************************************************************************************/
    public getColumnValue(column: string, row: IFDMeasureDetails, dictionaries: IDictionaries): string | number {
        switch (column) {
            case 'ACC_PRINCIP_DESCR':
                return dictionaries.dbpAccPrinciples[row.ACC_PRINCIP_SID]
            case 'ADOPT_STATUS_DESCR':
                return dictionaries.dbpAdoptStatues[row.ADOPT_STATUS_SID]
            default:
                return super.getColumnValue(column, row, dictionaries)
        }
    }

    /**********************************************************************************************
     * @method getDbpAccountingPrinciples
     *********************************************************************************************/
    public async getDbpAccountingPrinciples(): Promise<IObjectSIDs> {
        if (!this._dbpAccPrinciples) {
            const options: ISPOptions = {
                params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
            }
            const dbResult = await DataAccessApi.execSP('dbp_getters.getDbpAccountingPrinciples', options)
            this._dbpAccPrinciples = this.sidTypeToObject(dbResult.o_cur)
        }
        return this._dbpAccPrinciples
    }

    /**********************************************************************************************
     * @method getDbpAdoptionStatuses
     *********************************************************************************************/
    public async getDbpAdoptionStatuses(): Promise<IObjectSIDs> {
        if (!this._dbpAdoptStatues) {
            const options: ISPOptions = {
                params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
            }
            const dbResult = await DataAccessApi.execSP('dbp_getters.getDbpAdoptionStatuses', options)
            this._dbpAdoptStatues = this.sidTypeToObject(dbResult.o_cur)
        }
        return this._dbpAdoptStatues
    }

    /**********************************************************************************************
     * @method getDictionaries
     *********************************************************************************************/
    public async getDictionaries(roundSid: number): Promise<IDictionaries> {
        roundSid = roundSid || 0
        const [dbpAdoptStatues, dbpAccPrinciples, guaranteeReasons, rest] = await Promise.all([
            this.getDbpAdoptionStatuses(),
            this.getDbpAccountingPrinciples(),
            this.getGuaranteeReasons(),
            super.getDictionaries(roundSid),
        ])
        return { dbpAccPrinciples, dbpAdoptStatues, guaranteeReasons, ...rest }
    }

    /**********************************************************************************************
     * @method getESACodes
     *********************************************************************************************/
    public async getESACodes(): Promise<IESACodes> {
        if (!this._esaCodes.has(null)) {
            const options: ISPOptions = {
                params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
            }
            const dbResult = await DataAccessApi.execSP('dbp_getters.getESACodes', options)
            this._esaCodes.set(null, this.esaCodesToObject(dbResult.o_cur))
        }
        return this._esaCodes.get(null)
    }

    /**********************************************************************************************
     * @method getGuaranteeReasons
     *********************************************************************************************/
    public async getGuaranteeReasons(asArray = false): Promise<IObjectSIDs | IDBSidType[]> {
        if (!this._reasons) {
            const options: ISPOptions = {
                params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
            }
            const dbResult = await DataAccessApi.execSP('gd_guarantee.getGuaranteeReasons', options)
            this._reasons = {
                map: this.sidTypeToObject(dbResult.o_cur),
                array: dbResult.o_cur,
            }
        }
        return asArray ? this._reasons.array : this._reasons.map
    }

    /**********************************************************************************************
     * @method isEditable
     *********************************************************************************************/
    public isEditable(ctyStatusId: EStatusRepo, appStatusId: EStatusRepo, req: Request) {
        return (
            appStatusId !== EStatusRepo.CLOSED &&
            (ctyStatusId === EStatusRepo.ACTIVE ||
                (ctyStatusId === EStatusRepo.SUBMITTED && AuthzLibService.isCtyDesk(req)))
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
