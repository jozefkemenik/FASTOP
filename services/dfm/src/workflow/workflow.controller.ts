import { EStatusRepo, ISetCountryStatus } from 'country-status'
import { EApps } from 'config'

import { CountryStatusApi } from '../../../lib/dist/api/country-status.api'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { IArchiveParams } from '../../../lib/dist/measure/shared'
import { LibWorkflowController } from '../../../lib/dist/workflow/workflow.controller'

import { ICustStorageText } from '../config'
import { WorkflowService } from './workflow.service'

export class WorkflowController extends LibWorkflowController<WorkflowService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps, service: WorkflowService) {
        super(service)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method archive
     *********************************************************************************************/
    public async archive(
        archive: IArchiveParams, countryIds: string[], userId: string, force: boolean
    ): Promise<number> {
        const checkSubmitted =
            force ||
            Boolean(archive.custTextSid) ||
            await CountryStatusApi.getCountryStatuses(this.appId, countryIds, archive)
                .then(statuses => statuses.every(
                    status => [EStatusRepo.SUBMITTED, EStatusRepo.ARCHIVED].includes(status.statusId)
                ))

        if (!checkSubmitted) return EErrors.ALL_SUBMITTED

        let archiveMeasuresResult: number
        return this.service.archiveMeasures(archive, userId, countryIds)
            .then(result => {
                archiveMeasuresResult = result
                const setCountryStatus: ISetCountryStatus = {
                    oldStatusId: null,
                    newStatusId: EStatusRepo.ARCHIVED,
                    roundKeys: archive,
                    userId
                }
                return CountryStatusApi.setManyCountriesStatus(this.appId, countryIds, setCountryStatus)
            }).then(
                () => archiveMeasuresResult,
                this.exceptionHandler('archive')
            )
    }

    /**********************************************************************************************
     * @method newCustomStorage
     *********************************************************************************************/
    public newCustomStorage(roundSid: number, storage: ICustStorageText): Promise<number> {
        return this.service.newCustomStorage(roundSid, storage)
            .catch(this.exceptionHandler('newCustomStorage'))
    }

    /**********************************************************************************************
     * @method openTransparencyReport
     *********************************************************************************************/
    public openTransparencyReport(): Promise<boolean> {
        return this.service.openTransparencyReport().then(
            result => result > 0,
            this.exceptionHandler('openTransparencyReport')
        )
    }

    /**********************************************************************************************
     * @method openTransparencyReport
     *********************************************************************************************/
    public async publishTransparencyReport(archive: IArchiveParams): Promise<boolean> {
        const checkTrSubmitted = await CountryStatusApi.getCountryStatuses(this.appId, [], archive)
                .then(statuses => statuses.every(s => s.statusId === EStatusRepo.TR_SUBMITTED))

        if (!checkTrSubmitted) return false

        return this.service.publishTransparencyReport(archive).then(
            result => result > 0,
            this.exceptionHandler('publishTransparencyReport')
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
