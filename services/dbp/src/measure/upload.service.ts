import { EApps } from 'config'

import {
    IDictionary,
    ILibColumnConfig,
    ILibMeasureValue,
    ILibVectorConfig,
    ILibWorkbookConfig,
    IMeasureObject,
    IMeasuresRange,
    IRoundPeriod,
    MeasureUploadService,
} from '../../../lib/dist/measure/'
import { ELibColumn } from '../../../shared-lib/dist/prelib/wizard'

import { IScaleConfig, IWizardMeasureDetails } from '.'
import { SharedService } from '../shared/shared.service'

export class UploadService extends MeasureUploadService<IWizardMeasureDetails> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private appId: EApps,
        private sharedService: SharedService,
    ) {
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
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        countryId: string, roundSid: number, range: IMeasuresRange,
    ): Promise<ILibWorkbookConfig> {
        const roundPeriod: IRoundPeriod = await this.sharedService.getRoundPeriod(this.appId)
        if (roundSid !== roundPeriod.roundSid) {
            throw new Error('Invalid round!')
        }

        const scalesArray = await this.sharedService.getScales()

        const dictionaries: IDictionaries = await Promise.all([
            this.convertToDictionary('A', this.sharedService.getDbpEsaRevenueCodes()),
            this.convertToDictionary('B', this.sharedService.getDbpEsaExpenditureCodes()),
            this.convertToDictionary('C', this.sharedService.getDbpAccountingPrinciples()),
            this.convertToDictionary('D', this.sharedService.getDbpAdoptionStatuses()),
            this.convertToDictionary('E', this.getScalesAsObjectSIDs(scalesArray)),
            this.convertToDictionary('F', this.sharedService.getDbpSources())
        ]).then( ([revenue, expenditure, accPrinc, adoptionStatus, scales, sources]) =>
            ({ revenue, expenditure, accPrinc, adoptionStatus, scales, sources })
        )

        const def1: ILibColumnConfig[] = [
            {
                label: `Measure ID\n(Country: ${countryId})`,
                key: ELibColumn.SID,
                defaultValue: -1,
                width: 18
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
                label: 'Source',
                key: ELibColumn.DBP_SOURCE,
                width: 30,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.sources, true, 'Source'),
                dictionary: dictionaries.sources
            },
            { label: 'ID hidden', key: ELibColumn.SID, defaultValue: -1, hidden: true },
            { label: 'Country hidden', key: ELibColumn.COUNTRY, defaultValue: '', hidden: true },
        ]

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
                dataValidation: this.prepareListDataValidation(dictionaries.adoptionStatus, true, 'Adoption status'),
                dictionary: dictionaries.adoptionStatus
            },
        ]

        const vectorConfig: ILibVectorConfig = {
            startYear: roundPeriod.year - 3,
            endYear: roundPeriod.year + 7
        }

        const vectorDef: ILibColumnConfig[] = []
        for (let year = vectorConfig.startYear; year <= vectorConfig.endYear; year++) {
            vectorDef.push({
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
                    error: 'The value must be a valid number',
                    showInputMessage: false,
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
            dbpScale: await this.sharedService.getDbpScale(countryId, roundSid),
        }

        return {
            maxRows: 400,
            vectorConfig,
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
            }
        )
    }
}

enum EMeasureFilteringKey {
    REV = '1',
    EXP = '2'
}

interface IDictionaries {
    revenue: IDictionary
    expenditure: IDictionary
    accPrinc: IDictionary
    adoptionStatus: IDictionary
    scales: IDictionary
    sources: IDictionary
}
