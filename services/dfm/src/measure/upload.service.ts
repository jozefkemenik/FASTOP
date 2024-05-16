import {
    IDictionary,
    IESACodes,
    ILibColumnConfig,
    ILibMeasureValue,
    ILibWorkbookConfig,
    IMeasureObject,
    IMeasuresRange,
    MeasureUploadService,
} from '../../../lib/dist/measure'
import { ELibColumn } from '../../../shared-lib/dist/prelib/wizard'

import { IMeasureDetails } from '.'
import { IOneOffPrinciples } from '../config'
import { SharedService } from '../shared/shared.service'

export class UploadService extends MeasureUploadService<IMeasureDetails> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly sharedService: SharedService) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDfmTemplateConfig
     * @override
     * Prepare the definitions of DFM upload excel template.
     *********************************************************************************************/
    protected async getTemplateConfig(
        countryId: string, roundSid: number, range: IMeasuresRange,
    ): Promise<ILibWorkbookConfig> {
        const dictionaries: IDictionaries = await Promise.all([
            this.convertToDictionary('A', this.sharedService.getStatuses()),
            this.convertToDictionary('B', this.sharedService.getOneOff()),
            this.convertToDictionary('C', this.sharedService.getRevExp()),
            this.convertToDictionary('D', this.sharedService.getESACodes(0),
                (data: IESACodes, item: number) => item !== -1 ? data[item].descr : null),
            this.convertToDictionary('E', this.sharedService.getOneOffTypes(0)),
            this.convertToDictionary('F', this.sharedService.getOneOffPrinciples(),
                (data: IOneOffPrinciples, item: number) => item !== -1 ? data[item].descr : null),
            this.convertToDictionary('G', this.sharedService.getMonths()),
            this.convertToDictionary('H', this.sharedService.getLabels().then(
                /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
                labels => Object.fromEntries(Object.entries(labels).filter(([key, _]) => Number(key) > 0))
            )),
            this.convertToDictionary('I', this.sharedService.getEuFunds()),
        ]).then(
            ([statuses, yesNo, revExp, esaCodes, oneOffTypes, oneOffPrinc, months, labels, euFunds]) =>
                ({ statuses, yesNo, revExp, esaCodes, oneOffTypes, oneOffPrinc, months, labels, euFunds })
        )

        const def: ILibColumnConfig[] = [
            {
                label: `Measure ID\n(Country: ${countryId})`,
                key: ELibColumn.SID,
                defaultValue: -1,
                width: 18
            },
            {
                label: 'Status',
                key: ELibColumn.STATUS,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.statuses, false, 'Status'),
                dictionary: dictionaries.statuses
            },
            {
                label: 'Needs additional research',
                key: ELibColumn.ADD_RESEARCH,
                width: 13,
                dataValidation: this.prepareListDataValidation(dictionaries.yesNo, true, 'Needs additional research'),
                dictionary: dictionaries.yesNo,
                defaultValue: -1
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
                width: 50,
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
                width: 30,
                dataValidation: {
                    type: 'textLength',
                    allowBlank: true,
                    operator: 'lessThanOrEqual',
                    formulae: [4000],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Description"',
                    error: 'The value must have max 4000 characters'
                }
            },
            {
                label: 'Source',
                key: ELibColumn.SOURCE,
                defaultValue: '',
                width: 30,
                dataValidation: {
                    type: 'textLength',
                    allowBlank: true,
                    operator: 'lessThanOrEqual',
                    formulae: [400],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Source"',
                    error: 'The value must have max 400 characters'
                }
            },
            {
                label: 'Year of adoption',
                key: ELibColumn.ADOPTION_YEAR,
                defaultValue: -1,
                width: 12,
                dataValidation: {
                    type: 'whole',
                    allowBlank: true,
                    operator: 'greaterThan',
                    formulae: [1950],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Year of adoption"',
                    error: 'The value must be a valid year'
                }
            },
            {
                label: 'Month of adoption',
                key: ELibColumn.ADOPTION_MONTH,
                width: 14,
                dataValidation: this.prepareListDataValidation(dictionaries.months, true, 'Month of adoption'),
                dictionary: dictionaries.months,
                defaultValue: -1
            },
            {
                label: 'General comments',
                key: ELibColumn.GEN_COMMENTS,
                defaultValue: '',
                width: 30,
                dataValidation: {
                    type: 'textLength',
                    allowBlank: true,
                    operator: 'lessThanOrEqual',
                    formulae: [4000],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "General comments"',
                    error: 'The value must have max 4000 characters'
                }
            },
            {
                label: 'Year of first budgetary impact',
                key: ELibColumn.IMPACT_YEAR,
                defaultValue: -1,
                width: 13,
                dataValidation: {
                    type: 'whole',
                    allowBlank: false,
                    operator: 'greaterThan',
                    formulae: [1950],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Year of first budgetary impact"',
                    error: 'The value must not be empty and must be a valid year',
                    showInputMessage: true,
                    promptTitle: 'Mandatory value.',
                    prompt: ' '
                }
            },
            {
                label: 'Rev/Exp',
                key: ELibColumn.REV_EXP,
                defaultValue: -1,
                width: 12,
                dataValidation: this.prepareListDataValidation(dictionaries.revExp, false, 'Rev/Exp'),
                dictionary: dictionaries.revExp
            },
            {
                label: 'ESA2010 code',
                key: ELibColumn.ESA_CODE,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.esaCodes, false, 'ESA2010 code'),
                dictionary: dictionaries.esaCodes
            },
            {
                label: 'Comments ESA2010 classification',
                key: ELibColumn.ESA_COMMENTS,
                defaultValue: '',
                width: 30,
                dataValidation: {
                    type: 'textLength',
                    allowBlank: true,
                    operator: 'lessThanOrEqual',
                    formulae: [4000],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Comments ESA2010 classification"',
                    error: 'The value must have max 4000 characters'
                }
            },
            {
                label: 'One-off',
                key: ELibColumn.ONE_OFF,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.yesNo, false, 'One-off'),
                dictionary: dictionaries.yesNo
            },
            {
                label: 'One-off type',
                key: ELibColumn.ONE_OFF_TYPE,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.oneOffTypes, true, 'One-off type',
                    'Value is mandatory when "One-off" is set to "Yes"'),
                dictionary: dictionaries.oneOffTypes
            },
            {
                label: 'Main principle for one-off classification',
                key: ELibColumn.MAIN_PRINCIPLE,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.oneOffPrinc, true, '',
                    'Value is mandatory when "One-off" is set to "Yes" and "One-off type" is "Other"'),
                dictionary: dictionaries.oneOffPrinc
            },
            {
                label: 'MS disagrees on one-off treatment',
                key: ELibColumn.MS_DISAGREES,
                defaultValue: -1,
                width: 13,
                dataValidation: this.prepareListDataValidation(dictionaries.yesNo, true,
                    'MS disagrees on one-off treatment'),
                dictionary: dictionaries.yesNo
            },
            {
                label: 'Comments on one-off treatment',
                key: ELibColumn.ONE_OFF_COMMENTS,
                defaultValue: '',
                width: 30,
                dataValidation: {
                    type: 'textLength',
                    allowBlank: true,
                    operator: 'lessThanOrEqual',
                    formulae: [4000],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Comments on one-off treatment"',
                    error: 'The value must have max 4000 characters',
                    showInputMessage: true,
                    promptTitle: 'Warning: follow business rule!',
                    prompt: 'Value is mandatory when "One-off" is set to "Yes" and "One-off type" is "Other"' +
                        ' or "MS disagrees on one-off treatment" is set to "Yes"'
                }
            },
            {
                label: 'Funded by EU transfers',
                key: ELibColumn.IS_EU_FUNDED,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.yesNo, false, 'Funded by EU transfers'),
                dictionary: dictionaries.yesNo
            },
            {
                label: 'EU fund',
                key: ELibColumn.EU_FUND,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.euFunds, true, 'EU fund',
                    'Value is mandatory when "Funded by EU transfers" is set to "Yes"'),
                dictionary: dictionaries.euFunds
            },
        ]

        const vectorConfig = this.getVectorConfig(range)

        for (let year = vectorConfig.startYear; year <= vectorConfig.endYear; year++) {
            def.push({
                label: year.toString(),
                key: this.getMeasureDataColumnKey(year),
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
                    error: 'The value must be a valid number'
                }
            })
        }

        def.push({
            label: 'Comments of additional budgetary impact',
            key: ELibColumn.BUDGET_IMPACT_COMMENTS,
            defaultValue: '',
            width: 30,
            dataValidation: {
                type: 'textLength',
                allowBlank: true,
                operator: 'lessThanOrEqual',
                formulae: [4000],
                showErrorMessage: true,
                errorTitle: 'Invalid "Comments of additional budgetary impact"',
                error: 'The value must have max 2000 characters'
            }
        })

        def.push({ label: 'ID hidden', key: ELibColumn.SID, defaultValue: -1, hidden: true },
                 { label: 'Country hidden', key: ELibColumn.COUNTRY, defaultValue: '', hidden: true })

        this.calculateColumnWidth(def)

        return {
            maxRows: 400,
            vectorConfig,
            worksheets: [
                {
                    title: 'Measures',
                    isRequired: true,
                    firstDataRow: 3,
                    columns: def
                }
            ]
        }
    }

    /**********************************************************************************************
     * @method convertToMeasureObject
     * Prepare DB procedure parameter
     *********************************************************************************************/
    protected convertToMeasureObject(roundSid: number, measureSid: number, values: ILibMeasureValue): IMeasureObject {
        return Object.assign(
            super.convertToMeasureObject(roundSid, measureSid, values),
            {
                STATUS_SID: +values[ELibColumn.STATUS],
                NEED_RESEARCH_SID: +values[ELibColumn.ADD_RESEARCH],
                INFO_SRC: values[ELibColumn.SOURCE],
                ADOPT_DATE_YR: +values[ELibColumn.ADOPTION_YEAR],
                ADOPT_DATE_MH: +values[ELibColumn.ADOPTION_MONTH],
                COMMENTS: values[ELibColumn.GEN_COMMENTS],
                REV_EXP_SID: +values[ELibColumn.REV_EXP],
                ESA_COMMENTS: values[ELibColumn.ESA_COMMENTS],
                ONE_OFF_SID: +values[ELibColumn.ONE_OFF],
                ONE_OFF_TYPE_SID: +values[ELibColumn.ONE_OFF_TYPE],
                ONE_OFF_DISAGREE_SID: +values[ELibColumn.MS_DISAGREES],
                ONE_OFF_COMMENTS: values[ELibColumn.ONE_OFF_COMMENTS],
                QUANT_COMMENTS: values[ELibColumn.BUDGET_IMPACT_COMMENTS],
                OO_PRINCIPLE_SID: +values[ELibColumn.MAIN_PRINCIPLE],
            }
        )
    }
}

interface IDictionaries {
    statuses: IDictionary
    yesNo: IDictionary
    revExp: IDictionary
    esaCodes: IDictionary
    oneOffTypes: IDictionary
    oneOffPrinc: IDictionary
    months: IDictionary
    labels: IDictionary
    euFunds: IDictionary
}
