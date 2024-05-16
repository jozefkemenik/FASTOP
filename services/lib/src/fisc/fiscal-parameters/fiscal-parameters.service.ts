import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'
import { EApps } from 'config'
import { SharedLibService } from '../shared/shared-lib.service'

import {
    IDBFPWorksheet,
    IDBFPWorksheetIndicatorData,
    IFPTemplateDB,
    IFPUploadParamsDB,
    IFPWorksheetDefinition
} from '.'

export class FiscalParametersService extends SharedLibService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getWorksheetDefinitions
     *********************************************************************************************/
    public async getWorksheetDefinitions(getData = false): Promise<IFPWorksheetDefinition[]> {
        const tpl: IFPTemplateDB[] = await this.getTemplateDefinitions()

        const wMap: Map<number, IFPWorksheetDefinition> = new Map<number, IFPWorksheetDefinition>()
        let worksheetIndData$ = Promise.resolve({} as {[key: number]: IDBFPWorksheetIndicatorData[]})
        if (getData) {
            const uniqWorksheetSids: number[] = [...new Set(tpl.map(w => w.WORKSHEET_SID))]
            worksheetIndData$ = uniqWorksheetSids.reduce(
                async (acc$, wSid) => {
                    const acc = await acc$
                    acc[wSid] = await this.getWorksheetIndicatorData(wSid)
                    return acc
                },
                worksheetIndData$
            )
        }
        const worksheetIndData = await worksheetIndData$

        return tpl.reduce<IFPWorksheetDefinition[]>((acc, value) => {
            let def: IFPWorksheetDefinition = wMap.get(value.WORKSHEET_SID)
            if (!def) {
                def = {
                    worksheetName: value.WORKSHEET_NAME,
                    startYear: value.START_YEAR,
                    endYear: value.END_YEAR,
                    headerTitle: value.WORKSHEET_HEADER ? value.WORKSHEET_HEADER : undefined,
                    indicators: []
                }
                wMap.set(value.WORKSHEET_SID, def)
                acc.push(def)
            }
            def.indicators.push({
                indicatorId: value.INDICATOR_ID,
                indicatorSid: value.INDICATOR_SID,
                excelTitle: value.EXCEL_IND_TITLE ? value.EXCEL_IND_TITLE : undefined,
                glossary: !value.GLOSSARY_DESC ? undefined : {
                    description: value.GLOSSARY_DESC,
                    where: value.GLOSSARY_LOCATION,
                    explanation: value.GLOSSARY_EXPLANATION
                },
                data: !worksheetIndData[value.WORKSHEET_SID] ? [] : worksheetIndData[value.WORKSHEET_SID]
                    .filter(d => d.indicatorSid === value.INDICATOR_SID)
                    .map(d => ({
                        countryId: d.countryId,
                        startYear: d.startYear,
                        vector: d.vector
                    }))
            })

            return acc
        }, [])
    }

    /**********************************************************************************************
     * @method getWorksheets
     *********************************************************************************************/
    public async getWorksheets(): Promise<IDBFPWorksheet[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_fiscal_params.getWorksheets', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getWorksheetIndicatorData
     *********************************************************************************************/
    public async getWorksheetIndicatorData(
        worksheetSid: number, roundSid?: number
    ): Promise<IDBFPWorksheetIndicatorData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_worksheet_sid', type: NUMBER, value: worksheetSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_app_id', type: STRING, value: this.appId },
            ],
        }

        const dbResult = await DataAccessApi.execSP('idr_fiscal_params.getWorksheetIndicatorData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method storeFiscalParameters
     *********************************************************************************************/
    public async storeFiscalParameters(params: IFPUploadParamsDB): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: params.roundSid },
                { name: 'p_last_change_user', type: STRING, dir: BIND_IN, value: params.lastChangeUser },
                { name: 'p_indicator_sids', type: NUMBER, dir: BIND_IN, value: params.indicators },
                { name: 'p_country_ids', type: STRING, dir: BIND_IN, value: params.countries },
                { name: 'p_start_years', type: NUMBER, dir: BIND_IN, value: params.startYears },
                { name: 'p_vectors', type: STRING, dir: BIND_IN, value: params.vectors },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_fiscal_params.storeIndicators', options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTemplateDefinitions
     *********************************************************************************************/
    private async getTemplateDefinitions(): Promise<IFPTemplateDB[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_fiscal_params.getTemplateDefinitions', options)
        return dbResult.o_cur
    }
}
