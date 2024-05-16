import { IWizardDefinition } from '../../measure/shared-interfaces'

export interface IGuarantee {
    GUARANTEE_SID: number
    COUNTRY_ID: string
    DESCR: string
    REASON_SID: number
    ADOPT_DATE_YR: number
    ADOPT_DATE_MH: number
    MAX_CONTINGENT_LIAB: number
    ESTIMATED_TAKE_UP: number
}

export interface IGuaranteesWizardTemplate extends IWizardDefinition {
    withData: boolean
    guarantees?: IGuarantee[]
}
