import { ICompressedData } from '../../../../fdms/src/report/shared-interfaces'
import { IRoundStorage } from '../../../../dashboard/src/config/shared-interfaces'

export interface IFdmsAddinData {
    roundStorage: IRoundStorage
    data: ICompressedData
}
