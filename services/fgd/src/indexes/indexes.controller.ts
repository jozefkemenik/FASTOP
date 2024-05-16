import { DashboardApi } from '../../../lib/dist/api'
import { IError } from '../../../lib/dist'

import { ICountryIdxCalcStageMapping, IDBCountryIdxCalcStage, IHorizontalStage } from '.'
import { IndexesService } from './indexes.service'
import { SharedService } from '../shared/shared.service'

import { EApps } from 'config'

export class IndexesController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private indexesService: IndexesService,
        private sharedService: SharedService,
        private appId: EApps) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getCountryStages
     *********************************************************************************************/
    public getCountryStages(
        indexSid: number, countryId: string, roundSid: number
    ): Promise<ICountryIdxCalcStageMapping> {
        return this.indexesService.getCountryStages(indexSid, countryId, roundSid).then(
            (stages: IDBCountryIdxCalcStage[]) => {
                return stages.reduce((acc, stage) => {
                    acc[stage.STAGE_SID] = stage
                    return acc
                }, {})
            },
            (err: IError) => {
                err.method = 'IndexesController.getCountryStages'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getHorizontalStages
     *********************************************************************************************/
    public async getHorizontalStages(
        indexSid: number, roundSid: number
    ): Promise<IHorizontalStage[]> {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.indexesService.getHorizontalStages(this.appId, indexSid, roundSid, roundInfo.year).catch(
            (err: IError) => {
                err.method = 'IndexesController.getHorizontalStages'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method refreshHorizView
     *********************************************************************************************/
     public async refreshHorizView(
        indexSid: number, roundSid: number
    ): Promise<number> {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.indexesService.refreshHorizView(this.appId, indexSid, roundSid, roundInfo.year).catch(
            (err: IError) => {
                err.method = 'IndexesController.refreshView'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getHorizontalColumns
     *********************************************************************************************/
    public getHorizontalColumns(
        indexSid: number, roundSid: number
    ) {
        return this.indexesService.getHorizontalColumns(indexSid, roundSid).catch(
            (err: IError) => {
                err.method = 'IndexesController.getHorizontalColumns'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method reopenIndexCalculationStage
     *********************************************************************************************/
    public reopenIndexCalculationStage(
        indexSid: number, countryId: string, roundSid: number, stageSid: number
    ) {
        return this.indexesService.deleteCountryIdxCalculationStage(indexSid, countryId, roundSid, stageSid).catch(
            (err: IError) => {
                err.method = 'IndexesController.reopenIndexCalculationStage'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method setAutomaticScores
     *********************************************************************************************/
    public async setAutomaticScores(
        indexSid: number, countryId: string, roundSid: number, user: string, department: string,
        recalculateRules: number[] = []
    ) {
        return this.sharedService.setAutomaticScores(
            indexSid, countryId, roundSid, user, department, recalculateRules
        ).catch(
            (err: IError) => {
                err.method = 'IndexesController.setAutomaticScores'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method completeIndexCalculationStage
     *********************************************************************************************/
    public async completeIndexCalculationStage(
        indexSid: number,
        countryId: string,
        roundSid: number,
        stageSid: number,
        user: string,
        department: string,
        isMS: boolean,
        recalculateEntries: number[] = []
    ) {
        let iteration = ''
        if (isMS) {
            iteration = 'MS'
        } else {
            const stages = (await this.sharedService.getIndexCalculationStages(indexSid)).filter(stage => {
                if (isMS) {
                    return (stage.SCORE_VERSION_SID === stageSid && stage.ITERABLE === 1 && stage.MS_SHARED === 1)
                } else {
                    return (stage.SCORE_VERSION_SID === stageSid && stage.ITERABLE === 1)
                }
            })
            if (stages.length) {
                const disagreed =
                    await this.sharedService.getDisagreedCriteria(0, roundSid, stageSid, indexSid, countryId)
                if (disagreed.length) iteration = 'ECFIN'
            }
        }

        const ret = await this.sharedService.setCountryIdxCalculationStage(
            indexSid, countryId, roundSid, stageSid, iteration, user, department
        )
            let res = 0
            //check if indices table exists and if not create it
            const existsIndices = await this.sharedService.checkIndiceCreation(indexSid, roundSid)

            if (existsIndices > 0) {
                
                for (const entrySid of recalculateEntries) {
                    res = await this.sharedService.calcAllIndices(indexSid, roundSid, entrySid, countryId)
                    if (res < 0 ) {
                        return res
                    }
                }
            }
        

        if (ret > 0 && iteration === 'ECFIN') return 0
        return ret
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
