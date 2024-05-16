import { DashboardApi, FdmsApi, FdmsStarApi } from '../../../lib/dist/api'
import { IError } from '../../../lib/dist/'

import { ConfigService } from './config.service'
import { SharedService } from '../shared/shared.service'

import { EApps } from 'config'
import { ICompliance } from '.'

export class ConfigController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    public appId : EApps
    constructor(_app: EApps, private configService: ConfigService, private sharedService: SharedService) {
        this.appId = _app
     }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getCountryIFI
     *********************************************************************************************/
    public getCountryIFI(
        countryId: string, monitoring: number
    ) {
        return this.sharedService.getCountryIFI(countryId, monitoring).catch(
            (err: IError) => {
                err.method = 'ConfigController.getCountryIFI'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getEditSteps
     *********************************************************************************************/
    public getEditSteps() {
        return this.sharedService.getEditSteps().catch(
            (err: IError) => {
                err.method = 'ConfigController.getEditSteps'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getNFRCompliance
     *********************************************************************************************/
    public async getNFRCompliance(
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        entrySid: number, periodSid: number, mode: string, countryId?: string
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        if (mode === 'options') {
            return this.configService.getComplianceOptions(entrySid, periodSid, roundInfo.roundSid,
                roundInfo.year, roundInfo.periodDescr).catch(
                (err: IError) => {
                    err.method = 'ConfigController.getComplianceOptions'
                    throw err
                }
            )
        } else {
            const ret: ICompliance[] = []
            // get compliance configuration for the entry
            //filter the cfg for the period
            const cfg = await (await this.configService.getComplianceCfg(entrySid)).filter( item => {
                return item.PERIOD_SID === periodSid
            })
            
            // for each cfg item, we need to get either IndicatorData (SCP,DBP) or LineData(AMECO)
            cfg.forEach(async cItem => {
                if (cItem.COMPLIANCE_SOURCE_ID === 'AMECO') {
                    const latestOffsetRound = await DashboardApi.getLatestOffsetRound(this.appId, roundInfo.roundSid, cItem.YEAR)
                    
                    const amecoIndicatorData = await FdmsApi.getProviderCountryIndicatorData(
                        'PRE_PROD',
                        'A',
                        [countryId],
                        [cItem.INDICATOR_ID],
                        latestOffsetRound,
                        6
                    )
                    amecoIndicatorData.filter( indItem => {
                        return indItem.COUNTRY_ID === countryId 
                    })
                    const latestRound = await DashboardApi.getLatestRound(EApps.DBP, roundInfo.roundSid)
                    const year = await DashboardApi.getRoundYear(latestRound)
                    const amecoValue = amecoIndicatorData[0].TIMESERIE_DATA.slice(year - 1, year)[0]
                    // eslint-disable-next-line no-console
                    console.log('amecoValue', amecoValue)
                    ret.push({COMPLIANCE_SOURCE_SID: cItem.COMPLIANCE_SOURCE_SID, VALUE: amecoValue})
                    
                } else if (cItem.COMPLIANCE_SOURCE_ID === 'DBP') {
                    const dbpIndicatorData = await FdmsStarApi.getLinesData(EApps.DBP, {
                        variables: [],
                        lines: [cItem.LINE_ID],
                        indicators: []
                    })
                    // eslint-disable-next-line no-console
                    console.log('dbpIndicatorData', dbpIndicatorData)
                    dbpIndicatorData.filter( indItem => {
                        return indItem.COUNTRY_ID === countryId &&
                                indItem.IS_LEVEL === cItem.IS_LEVEL && 
                                indItem.YEAR_VALUE === cItem.YEAR_VALUE
                            })
                    if (dbpIndicatorData) {
                        ret.push({COMPLIANCE_SOURCE_SID: cItem.COMPLIANCE_SOURCE_SID, VALUE: dbpIndicatorData[0].VALUE_CD})
                    }// return ret
                } else if (cItem.COMPLIANCE_SOURCE_ID === 'SCP1') {
                    
                    const scpIndicatorData = await FdmsStarApi.getLinesData(EApps.SCP, {
                        variables: [],
                        lines: [cItem.LINE_ID],
                        indicators: []
                    })
                    // eslint-disable-next-line no-console
                    console.log('scpIndicatorData', scpIndicatorData)
                    scpIndicatorData.filter( indItem => {
                        return indItem.COUNTRY_ID === countryId &&
                                indItem.IS_LEVEL === cItem.IS_LEVEL && 
                                indItem.YEAR_VALUE === cItem.YEAR_VALUE
                            })
                    if (scpIndicatorData) {
                        ret.push({COMPLIANCE_SOURCE_SID: cItem.COMPLIANCE_SOURCE_SID, VALUE: scpIndicatorData[0].VALUE_CD})
                    }
                } else if (cItem.COMPLIANCE_SOURCE_ID === 'ESTA1') {
                    const latestRound = await DashboardApi.getLatestOffsetRound(EApps.NFR, roundInfo.roundSid, cItem.YEAR)
                    const estatValues = await this.configService.getEstatValues(entrySid, periodSid, latestRound)
                    if (estatValues) ret.push(estatValues[0])
                }
            })
        // const provIndicatorData = await GridsApi.getIndicatorsForCSV()
        // const linesData = await FdmsStarApi.getLinesData()
            return ret
        }
        
    }

    /**********************************************************************************************
     * @method getUserRule
     *********************************************************************************************/
    public getUserRule(
        user: string
    ) {
        return this.configService.getUserRule(user).catch(
            (err: IError) => {
                err.method = 'ConfigController.getUserRule'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getUserApp
     *********************************************************************************************/
    public getUserApp(
        user: string
    ) {
        return this.configService.getUserApp(user).catch(
            (err: IError) => {
                err.method = 'ConfigController.getUserApp'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getIfis
     *********************************************************************************************/
    public getIfis() {
        return this.configService.getIfis().catch(
            (err: IError) => {
                err.method = 'ConfigController.getIfis'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getDefaultQuestSid
     *********************************************************************************************/
    public getDefaultQuestSid(): Promise<number> {
        return this.sharedService.menuService.getQuestionnaires().then(
            questionnaires => questionnaires[0]?.QUESTIONNAIRE_SID,
            (err: IError) => {
                err.method = 'ConfigController.getDefaultQuestSid'
                throw err
            }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
