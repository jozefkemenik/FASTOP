import { EApps } from 'config'

import { BIND_OUT, CURSOR, GUARANTEEARRAY, GUARANTEEOBJECT, ISPOptions, NUMBER, STRING } from '../../../db'
import {
    IArchiveParams,
    IDictionary,
    ILibColumnConfig,
    ILibWorkbookConfig,
    IRoundPeriod,
} from '../..'
import { DataAccessApi } from '../../../api'
import { ELibColumn } from '../../../../../shared-lib/dist/prelib/wizard'
import { FDSharedService } from '../shared/fd-shared.service'
import { IGuarantee } from '.'
import { LibUploadService } from '../../upload/lib-upload.service'

export class GuaranteeService extends LibUploadService {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps, private readonly sharedService: FDSharedService) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method deleteGuarantee
     *********************************************************************************************/
    public async deleteGuarantee(countryId: string, guaranteeSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_guarantee_sid', type: NUMBER, value: guaranteeSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_guarantee.deleteGuarantee', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getGuarantee
     *********************************************************************************************/
    public async getGuarantee(guaranteeSid: number, countryId: string): Promise<IGuarantee> {
        const options: ISPOptions = {
            params: [
                { name: 'p_guarantee_sid', type: NUMBER, value: guaranteeSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_guarantee.getGuarantee', options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method getGuarantees
     *********************************************************************************************/
    public async getGuarantees(countryId: string, archive: Partial<IArchiveParams>): Promise<IGuarantee[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_round_sid', type: NUMBER, value: archive.roundSid ?? null },
                { name: 'p_version', type: NUMBER, value: archive.ctyVersion ?? null },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_guarantee.getGuarantees', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method saveGuarantee
     *********************************************************************************************/
    public async saveGuarantee(guarantee: IGuarantee): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_guarantee', type: GUARANTEEOBJECT, value: guarantee },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_guarantee.saveGuarantee', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method saveGuarantees
     *********************************************************************************************/
    public async saveGuarantees(guarantees: IGuarantee[]): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_guarantees', type: GUARANTEEARRAY, value: guarantees },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_guarantee.saveGuarantees', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getTemplateConfig
     * @override
     * Prepare the definitions of the upload guarantees excel template.
     *********************************************************************************************/
    public async getTemplateConfig(countryId: string, roundSid: number): Promise<ILibWorkbookConfig> {
        const roundPeriod: IRoundPeriod = await this.sharedService.getRoundPeriod(this.appId)
        if (roundSid !== roundPeriod.roundSid) {
            throw new Error('Invalid round!')
        }

        const dictionaries: IDictionaries = await Promise.all([
            this.convertToDictionary('A', this.sharedService.getGuaranteeReasons()),
            this.convertToDictionary('B', this.sharedService.getMonths()),
        ]).then(([reasons, months]) => ({ reasons, months }))

        const columns: ILibColumnConfig[] = [
            {
                label: `Guarantee ID\n(Country: ${countryId})`,
                key: ELibColumn.GUARANTEE_SID,
                defaultValue: -1,
                width: 18,
            },
            {
                label: 'Reason',
                key: ELibColumn.REASON,
                width: 20,
                defaultValue: -1,
                dataValidation: this.prepareListDataValidation(dictionaries.reasons, false, 'Reason'),
                dictionary: dictionaries.reasons,
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
                },
            },
            {
                label: 'Year of adoption',
                key: ELibColumn.ADOPTION_YEAR,
                defaultValue: null,
                width: 10,
                dataValidation: {
                    type: 'whole',
                    allowBlank: true,
                    operator: 'greaterThan',
                    formulae: [1950],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Year of adoption"',
                    error: 'The value must be a valid year',
                },
            },
            {
                label: 'Month of adoption',
                key: ELibColumn.ADOPTION_MONTH,
                width: 12,
                dataValidation: this.prepareListDataValidation(dictionaries.months, true, 'Month of adoption'),
                dictionary: dictionaries.months,
                defaultValue: -1,
            },
            {
                label: 'Maximum amount of contingent liabilities (% of GDP)',
                key: ELibColumn.MAX_CONTINGENT_LIAB,
                defaultValue: null,
                width: 18,
                dataValidation: {
                    type: 'decimal',
                    allowBlank: true,
                    operator: 'between',
                    formulae: [Number.MIN_SAFE_INTEGER, Number.MAX_SAFE_INTEGER],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Maximum amount of contingent liabilities"',
                    error: 'The value must be a valid number',
                    showInputMessage: false,
                },
            },
            {
                label: 'Estimated take-up (% of GDP)',
                key: ELibColumn.ESTIMATED_TAKE_UP,
                defaultValue: null,
                width: 16,
                dataValidation: {
                    type: 'decimal',
                    allowBlank: true,
                    operator: 'between',
                    formulae: [Number.MIN_SAFE_INTEGER, Number.MAX_SAFE_INTEGER],
                    showErrorMessage: true,
                    errorTitle: 'Invalid "Estimated take-up"',
                    error: 'The value must be a valid number',
                    showInputMessage: false,
                },
            },
            { label: 'ID hidden', key: ELibColumn.GUARANTEE_SID, defaultValue: -1, hidden: true },
            { label: 'Country hidden', key: ELibColumn.COUNTRY, defaultValue: '', hidden: true },
        ]

        this.calculateColumnWidth(columns)

        return {
            maxRows: 400,
            vectorConfig: { startYear: 0, endYear: 0 },
            worksheets: [
                {
                    title: 'Guarantees',
                    isRequired: true,
                    firstDataRow: 3,
                    columns,
                },
            ],
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}

interface IDictionaries {
    reasons: IDictionary
    months: IDictionary
}
