import { EApps } from 'config'

import { ELibColumn, ELibExercise } from '../../../shared-lib/dist/prelib/wizard'
import {
    IDictionary,
    ILibColumnConfig,
    ILibMeasureValue,
    ILibVectorConfig,
    ILibWorkbookConfig,
    IMeasureObject,
    IMeasuresRange,
    IObjectPIDs,
    IObjectSIDs,
    IRoundPeriod,
    MeasureUploadService,
} from '../../../lib/dist/measure'

import { IScaleConfig, IWizardMeasureDetails } from '.'
import { SharedService } from '../shared/shared.service'

export class UploadService extends MeasureUploadService<IWizardMeasureDetails> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps, private readonly sharedService: SharedService) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTemplateConfig
     * @override
     * Prepare the definitions of DFM upload excel template.
     *********************************************************************************************/
    protected async getTemplateConfig(
        countryId: string, roundSid: number, range: IMeasuresRange,
    ): Promise<ILibWorkbookConfig> {
        const roundPeriod: IRoundPeriod = await this.sharedService.getRoundPeriod(this.appId)
        if (roundSid !== roundPeriod.roundSid) {
            throw new Error('Invalid round!')
        }

        const exercisesPIDs: IObjectPIDs = await this.sharedService.getExercises()
        const isDrmOnlyPeriod: boolean = (await this.sharedService.isApplicationInRound(EApps.DBP, roundSid)) === false
        const scalesArray = await this.sharedService.getScales()

        const exerciseConversionFunction = (data: IObjectPIDs, item: number) => item !== -1 ? data[item].DESCRIPTION
                                                                                            : null
        const dictionaries: IDictionaries = await Promise.all([
            this.convertToDictionary('A', Promise.resolve(exercisesPIDs), exerciseConversionFunction),
            this.convertToDictionary('B', this.sharedService.getDbpEsaRevenueCodes()),
            this.convertToDictionary('C', this.sharedService.getDbpEsaExpenditureCodes()),
            this.convertToDictionary('D', this.sharedService.getOneOff()),
            this.convertToDictionary('E', this.sharedService.getOneOffTypes(0)),
            this.convertToDictionary('F', this.sharedService.getDbpAccountingPrinciples()),
            this.convertToDictionary('G', this.sharedService.getDbpAdoptionStatuses()),
            isDrmOnlyPeriod ? undefined : this.convertToDictionary('H', this.sharedService.getDbpSources()),
            this.convertToDictionary('I', this.sharedService.getEuFunds()),
            this.convertToDictionary('J', this.sharedService.getLabels().then(
                /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
                labels => Object.fromEntries(Object.entries(labels).filter(([key, _]) => Number(key) > 0))
            )),
            this.convertToDictionary('K', this.getScalesAsObjectSIDs(scalesArray)),
        ]).then( ([
            exercises, revenue, expenditure, yesNo, oneOffTypes, accPrinc, adopStatus, sources, euFunds, labels, scales
        ]) => ({
            exercises, revenue, expenditure, yesNo, oneOffTypes, accPrinc, adopStatus, sources, euFunds, labels, scales
        }) )

        const def1: ILibColumnConfig[] = [
            {
                label: `Measure ID\n(Country: ${countryId})`,
                key: ELibColumn.SID,
                defaultValue: -1,
                width: 18
            },
            {
                label: 'To be included',
                key: ELibColumn.EXERCISE,
                defaultValue: -1,
                width: 20,
                dataValidation: this.prepareListDataValidation(dictionaries.exercises, false, 'To be included'),
                dictionary: dictionaries.exercises
            },
            {
                label: 'Labels',
                key: ELibColumn.LABELS,
                width: 15,
                dataValidation: this.prepareMultiListDataValidation(dictionaries.labels, true, 'Labels'),
                dictionary: dictionaries.labels,
                defaultValue: []
            },
            {
                label: 'Title',
                key: ELibColumn.TITLE,
                defaultValue: '',
                width: 25,
                dataValidation: {
                    type: 'textLength',
                    truncate: true,
                    allowBlank: false,
                    operator: 'lessThanOrEqual',
                    formulae: [100],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Title"',
                    error: 'The value cannot be empty and must have max 100 characters',
                    showInputMessage: true,
                    promptTitle: 'Mandatory value.',
                    prompt: ' '
                }
            },
            {
                label: 'Description',
                key: ELibColumn.DESCRIPTION,
                defaultValue: '',
                width: 60,
                dataValidation: {
                    type: 'textLength',
                    allowBlank: true,
                    operator: 'lessThanOrEqual',
                    formulae: [4000],
                    showErrorMessage: true,
                    showInputMessage: true,
                    errorTitle: 'Invalid "Description"',
                    error: 'The value must have max 4000 characters',
                }
            },
            {
                label: 'Year of first budgetary impact',
                key: ELibColumn.IMPACT_YEAR,
                exercise: ELibExercise.DRM,
                defaultValue: -1,
                width: 13,
                dataValidation: {
                    type: 'whole',
                    allowBlank: true,
                    operator: 'greaterThan',
                    formulae: [1950],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Year of first budgetary impact"',
                    error: 'The value must not be empty and must be a valid year',
                    showInputMessage: true,
                    promptTitle: 'Mandatory only for DRM.',
                    prompt: ' '
                }
            },
            { label: 'ID hidden', key: ELibColumn.SID, defaultValue: -1, hidden: true },
            { label: 'Country hidden', key: ELibColumn.COUNTRY, defaultValue: '', hidden: true },
        ]

        if (isDrmOnlyPeriod === false) {
            def1.push({
                    label: 'Source',
                    key: ELibColumn.DBP_SOURCE,
                    exercise: ELibExercise.DBP,
                    width: 30,
                    defaultValue: -1,
                    dataValidation: this.prepareListDataValidation(dictionaries.sources, true, 'Source',
                        'Mandatory only for DBP.'),
                    dictionary: dictionaries.sources
                },
            )
        }

        const revDefs: ILibColumnConfig[] = [
            {
                label: 'ESA',
                key: ELibColumn.ESA_CODE,
                width: 60,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.revenue, false, 'ESA'),
                dictionary: dictionaries.revenue
            },
        ]

        const expDef: ILibColumnConfig[] = [
            {
                label: 'ESA',
                key: ELibColumn.ESA_CODE,
                width: 60,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.expenditure, false, 'ESA'),
                dictionary: dictionaries.expenditure
            },
        ]

        const def2: ILibColumnConfig[] = [
            {
                label: 'One-off',
                key: ELibColumn.ONE_OFF,
                exercise: ELibExercise.DRM,
                width: 10,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.yesNo, true, 'One-off',
                                                               'Mandatory only for DRM.'),
                dictionary: dictionaries.yesNo
            },
            {
                label: 'One-off type',
                key: ELibColumn.ONE_OFF_TYPE,
                exercise: ELibExercise.DRM,
                width: 45,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.oneOffTypes, true, 'One-off type',
                                                               'Mandatory only for DRM.'),
                dictionary: dictionaries.oneOffTypes
            },
            {
                label: 'Funded by EU transfers',
                key: ELibColumn.IS_EU_FUNDED,
                exercise: ELibExercise.DRM,
                width: 10,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(
                    dictionaries.yesNo, false, 'Funded by EU transfers', 'Mandatory only for DRM.'
                ),
                dictionary: dictionaries.yesNo
            },
            {
                label: 'EU fund',
                key: ELibColumn.EU_FUND,
                exercise: ELibExercise.DRM,
                width: 15,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.euFunds, true, 'EU fund',
                    'Value is mandatory when "Funded by EU transfers" is set to "Yes"'),
                dictionary: dictionaries.euFunds
            },
            {
                label: 'Accounting principle',
                key: ELibColumn.ACCOUNTING_PRINCIPLE,
                width: 30,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.accPrinc, true, 'Accounting principle'),
                dictionary: dictionaries.accPrinc
            },
            {
                label: 'Adoption status',
                key: ELibColumn.ADOPTION_STATUS,
                width: 40,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.adopStatus, true, 'Adoption status'),
                dictionary: dictionaries.adopStatus
            },
        ]

        const drmVectorConfig: ILibVectorConfig = {
            startYear: roundPeriod.year - 3,
            endYear: roundPeriod.year + 7
        }
        const vectorConfig = this.getVectorConfig(range)

        const vectorDef: ILibColumnConfig[] = []
        for (let year = vectorConfig.startYear; year <= vectorConfig.endYear; year++) {
            const drmOnly: boolean = year < (roundPeriod.year - 1)
            const optionalYear: boolean = year < drmVectorConfig.startYear || year > drmVectorConfig.endYear
            vectorDef.push({
                label: year.toString(),
                color: optionalYear ? 'B2A9A9A9' : undefined,
                key: this.getMeasureDataColumnKey(year),
                exercise: drmOnly ? ELibExercise.DRM : undefined,
                defaultValue: '',
                width: 8,
                yearData: year,
                dataValidation: {
                    type: 'decimal',
                    allowBlank: true,
                    operator: 'between',
                    formulae: [Number.MIN_SAFE_INTEGER, Number.MAX_SAFE_INTEGER],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Measure data"',
                    error: 'The value must be a valid number',
                    showInputMessage: drmOnly || optionalYear ? true : false,
                    promptTitle: optionalYear ? 'This value is outside default vector range' :
                                                (drmOnly ? 'Mandatory only for DRM.' : undefined),
                    prompt: drmOnly || optionalYear ? ' ' : undefined,
                }
            })
        }

        const revenueColumns = def1.concat(revDefs, def2, vectorDef)
        const expenditureColumns = def1.concat(expDef, def2, vectorDef)
        this.calculateColumnWidth(revenueColumns)
        this.calculateColumnWidth(expenditureColumns)

        const scaleConfig: IScaleConfig = {
            dataColumn: 3,
            dataRow: 3,
            dictionary: dictionaries.scales,
            isDrmOnlyPeriod,
            dbpScale: await this.sharedService.getDbpScale(countryId, roundSid),
            drmScale: await this.sharedService.getDrmScale(countryId)
        }

        return {
            maxRows: 400,
            vectorConfig,
            roundPeriod: Object.assign( { isDrmOnlyPeriod,
                                          exerciseSidToPid: this.convertExerciseToMap(exercisesPIDs) }, roundPeriod),
            worksheets: [
                {
                    title: 'Revenues',
                    key: EMeasureFilteringKey.REV,
                    isRequired: false,
                    firstDataRow: 4,
                    globalDataConfig: scaleConfig,
                    columns: revenueColumns
                },
                {
                    title: 'Expenditures',
                    key: EMeasureFilteringKey.EXP,
                    isRequired: false,
                    firstDataRow: 3,
                    columns: expenditureColumns
                }
            ]
        }
    }

    /**********************************************************************************************
     * @method convertToMeasureObject
     * Prepare DB procedure parameter
     *********************************************************************************************/
    protected convertToMeasureObject(roundSid: number, measureSid: number, values: ILibMeasureValue): IMeasureObject {
        return Object.assign(super.convertToMeasureObject(roundSid, measureSid, values),
            {
                SOURCE_SID: +values[ELibColumn.DBP_SOURCE],
                ACC_PRINCIP_SID: +values[ELibColumn.ACCOUNTING_PRINCIPLE],
                ADOPT_STATUS_SID: +values[ELibColumn.ADOPTION_STATUS],
                ONE_OFF_SID: +values[ELibColumn.ONE_OFF],
                ONE_OFF_TYPE_SID: +values[ELibColumn.ONE_OFF_TYPE],
                EXERCISE_SID: +values[ELibColumn.EXERCISE],
            }
        )
    }

    /**********************************************************************************************
     * @method convertExerciseToMap
     * Return map key = SID, value = PID
     *********************************************************************************************/
    private convertExerciseToMap(exercises: IObjectPIDs): IObjectSIDs {
        const keys = Object.getOwnPropertyNames(exercises)
        return keys.reduce((acc, key) => {
            acc[key] = exercises[key].PID
            return acc
        }, {})
    }
}

export enum EMeasureFilteringKey {
    REV = '1',
    EXP = '2'
}

interface IDictionaries {
    exercises: IDictionary
    revenue: IDictionary
    expenditure: IDictionary
    yesNo: IDictionary
    oneOffTypes: IDictionary
    accPrinc: IDictionary
    adopStatus: IDictionary
    scales: IDictionary
    sources: IDictionary
    euFunds: IDictionary
    labels: IDictionary
}
