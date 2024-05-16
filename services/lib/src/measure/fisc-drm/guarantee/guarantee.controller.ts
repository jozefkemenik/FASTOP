import { IArchiveParams, IColumn, IWizardDefinition } from '../..'
import { IGuarantee, IGuaranteesWizardTemplate } from '.'
import { GuaranteeService } from './guarantee.service'
import { IError } from '../../..'

export class GuaranteeController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly guaranteeService: GuaranteeService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method deleteGuarantee
     *********************************************************************************************/
    public async deleteGuarantee(countryId: string, guaranteeSid: number): Promise<number> {
        return this.guaranteeService.deleteGuarantee(countryId, guaranteeSid).catch((err: IError) => {
            err.method = 'GridController.deleteGuarantee'
            throw err
        })
    }

    /**********************************************************************************************
    * @method getGuaranteeColumns
    *********************************************************************************************/
    public async getGuaranteeColumns(): Promise<Array<Omit<IColumn, 'views'>>> {
        return [
            { field: 'REASON_DESCR', header: '', width: 65, isGrouped: true },
            { field: 'GUARANTEE_SID', header: 'ID', width: 65 },
            { field: 'DESCR', header: 'Description' },
            { field: 'ADOPT_DATE_YR', header: 'Adoption year' },
            { field: 'ADOPT_DATE_MH_DESCR', header: 'Adoption month' },
            {
                field: 'MAX_CONTINGENT_LIAB',
                header: 'Maximum amount of contingent liabilities (% of GDP)', isNumeric: true,
            },
            { field: 'ESTIMATED_TAKE_UP', header: 'Estimated take-up (% of GDP)', isNumeric: true },
        ]
    }

    /**********************************************************************************************
    * @method getGuarantee
    *********************************************************************************************/
    public async getGuarantee(guaranteeSid: number, countryId: string): Promise<IGuarantee> {
        return this.guaranteeService.getGuarantee(guaranteeSid, countryId).catch((err: IError) => {
            err.method = 'GridController.getGuarantee'
            throw err
        })
    }

    /**********************************************************************************************
    * @method getGuarantees
    *********************************************************************************************/
    public async getGuarantees(countryId: string, archive: Partial<IArchiveParams>): Promise<IGuarantee[]> {
        return this.guaranteeService.getGuarantees(countryId, archive).catch((err: IError) => {
            err.method = 'GridController.getGuarantees'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getWizardDefinition
     *********************************************************************************************/
    public async getWizardDefinition(countryId: string, roundSid: number): Promise<IWizardDefinition> {
        return this.guaranteeService.getWizardDefinition(countryId, roundSid)
    }

    /**********************************************************************************************
     * @method getWizardTemplate
     *********************************************************************************************/
    public async getWizardTemplate(
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        countryId: string, roundSid: number, withData: boolean, dataHistoryOffset: number
    ): Promise<IGuaranteesWizardTemplate> {
        return {
            workbookConfig: await this.guaranteeService.getTemplateConfig(countryId, roundSid),
            withData,
            guarantees: withData ? await this.getGuarantees(countryId, {roundSid}) : undefined
        }
    }

    /**********************************************************************************************
     * @method saveGuarantee
     *********************************************************************************************/
    public async saveGuarantee(guarantee: IGuarantee): Promise<number> {
        return this.guaranteeService.saveGuarantee(guarantee).catch((err: IError) => {
            err.method = 'GridController.saveGuarantee'
            throw err
        })
    }

    /**********************************************************************************************
     * @method uploadGuarantees
     *********************************************************************************************/
    public async uploadGuarantees(countryId: string, guarantees: IGuarantee[]): Promise<number> {
        return this.guaranteeService.saveGuarantees(
            guarantees.map(g => (g.COUNTRY_ID = countryId, g))
        ).catch((err: IError) => {
            err.method = 'GridController.uploadGuarantees'
            throw err
        })
    }
}
