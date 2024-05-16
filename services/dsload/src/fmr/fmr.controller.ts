import * as XLSX from 'xlsx'

import { IDBLogUpload, IStatusTransition } from './index'
import { IFpDataflow, IFpDatastructure, ILogUploadDataset, ILogUploadUpdate, eLogStatus } from './shared-interfaces'
import { IXlsxFile, IXlsxRow, IXlsxSheet } from './shared-interfaces'
import { FmrApi } from '../../../lib/dist/api/fmr.api'
import { FmrService } from './fmr.service'
import { FplmApi } from '../../../lib/dist/api/fplm.api'
import { ILogUpload } from './shared-interfaces'
import { LoggingService } from '../../../lib/dist'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class FMRController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private fmrService: FmrService, private logs: LoggingService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDataflows
     *********************************************************************************************/
    public async getDataflows(): Promise<IFpDataflow[]> {
        return Promise.all([
            FmrApi.getDataflows(),
            FplmApi.getDataflows().then(
                dataflows => new Set<string>(dataflows.map(df => df.toUpperCase()))
            )
        ]).then(
            ([fmrDataflows, lakeDataflows]) => fmrDataflows.filter(
                df => lakeDataflows.has(df.id.toUpperCase())
            )
        )
    }

    /**********************************************************************************************
     * @method getDatastructure
     *********************************************************************************************/
    public async getDatastructure(id: string): Promise<IFpDatastructure> {
        return FmrApi.getDatastructure(id)
    }

    /**********************************************************************************************
     * @method generateXslTemplate
     *********************************************************************************************/
    public async generateXslTemplate(dataFolwId: string): Promise<IXlsxFile> {
        try {
            const data = await FmrApi.getDatastructure(dataFolwId)
            if (data) {
                const observations = data.attributes?.observation ?? []
                const strDims = data.dimensions.join()
                const timeSeries = data.attributes?.series.filter(s => s.dimensions.join() === strDims).map(s => s.id)

                const rows: IXlsxRow[] = []
                const sheets: IXlsxSheet[] = ['data', 'attr_dims'].map((sheetName, index) => {
                    const header: string[] =
                        index == 0
                            ? ['KEY', ...data.timeDimensions, data.measure, ...observations]
                            : ['KEY', ...(timeSeries ?? [])]
                    return { header, rows, name: sheetName }
                })

                return { sheets: sheets, name: data.name }
            } else {
                throw new Error('no data')
            }
        } catch (e) {
            throw new Error(e)
        }
    }

    /**********************************************************************************************
     * @method makeExcel
     *********************************************************************************************/
    public makeExcel(sheets: IXlsxSheet[]): Buffer {
        const sheetNames = sheets.map(sheet => sheet.name)
        const xlsSheets: { [sheet: string]: XLSX.Sheet } = sheets.reduce(
            (acc, { name, rows, header }) => ((acc[name] = XLSX.utils.json_to_sheet(rows, { header })), acc),
            {},
        )
        const workbook = { Sheets: xlsSheets, SheetNames: sheetNames }
        return XLSX.write(workbook, { bookType: 'xlsx', type: 'buffer' })
    }

    /**********************************************************************************************
     * @method setLogUpload
     * @returns upload sid
     *********************************************************************************************/
    public async setLogUpload(data: ILogUploadDataset, user: string) {

        const logUpload: ILogUpload = await this.getLogUpload(user, undefined)
        if (!logUpload) {
            return this.fmrService.createUpload(user, data.provider, data.dataset)
        } else {
            const transition: IStatusTransition = await this.getStatusTransition(logUpload.status)
            this.checkStatusTransition(logUpload.status, eLogStatus.DATASET, transition.validStatuses)
            await this.fmrService.changeDataset(logUpload.uploadSid, data.provider, data.dataset)
            return logUpload.uploadSid
        }
    }

    /**********************************************************************************************
     * @method getLogUpload
     *********************************************************************************************/
    public async getLogUpload(user: string, uploadSid: number): Promise<ILogUpload> {
        return this.fmrService.getLogUpload(user, uploadSid).then(this.mapLogUpload)
    }

    /**********************************************************************************************
     * @method updateLogUpload
     *********************************************************************************************/
    public async updateLogUpload(uploadSid: number, data: ILogUploadUpdate) {
        const logUpload: ILogUpload = await this.getLogUpload(undefined, uploadSid)

        if (!logUpload) throw Error('Upload not found! It is already in final state: cancelled or finished!')

        const transition: IStatusTransition = await this.getStatusTransition(logUpload.status)
        if (transition) {
            // check if the transition to a new status is allowed
            this.checkStatusTransition(logUpload.status, data.status, transition.validStatuses)

            // check if the state change is allowed in current status
            if (data.state && !transition.canChangeState) {
                throw Error(`Modification of state is not allowed in current status: ${logUpload.status}`)
            }
        }

        return this.fmrService.updateUpload(uploadSid, data.status, data.state ? JSON.stringify(data.state) : null)
    }

    /**********************************************************************************************
     * @method finishHandler
     *********************************************************************************************/
    public async finishHandler(uploadSid: number) {
        return FplmApi.finishUpload(uploadSid)
    }

    /**********************************************************************************************
     * @method cancelHandler
     *********************************************************************************************/
    public async cancelHandler(uploadSid: number) {
        return FplmApi.cancelUpload(uploadSid)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method mapLogUpload
     *********************************************************************************************/
    private mapLogUpload(raw: IDBLogUpload): ILogUpload {
        return raw ? {
            uploadSid: raw.UPLOAD_SID,
            userId: raw.USER_ID,
            latestDate: raw.LATEST_DATE,
            dataset: raw.DATASET,
            provider: raw.PROVIDER,
            status: raw.STATUS,
            folder: raw.FOLDER,
            state: raw.STATE ? JSON.parse(raw.STATE) : undefined,
        } : undefined
    }

    /**********************************************************************************************
     * @method getStatusTransition
     *********************************************************************************************/
    private async getStatusTransition(status: string): Promise<IStatusTransition> {
        return this.fmrService.getStatusTransition(status).then(raw => {
            if (!raw) return undefined
            return {
                status: raw.STATUS_ID,
                canChangeState: raw.STATE_CHANGE > 0,
                validStatuses: raw.VALID_STATUSES ? new Set<string>(raw.VALID_STATUSES.split(',')) : undefined
            }
        })
    }

    /**********************************************************************************************
     * @method checkStatusTransition
     *********************************************************************************************/
    private checkStatusTransition(currentStatus: string, newStatus: string, validStatuses: Set<string>) {
        if (newStatus && currentStatus != newStatus && (!validStatuses || !validStatuses.has(newStatus))) {
            const expectedStatuses = Array.from(validStatuses || []).join(', ')
            throw Error(
                `Invalid upload status: ${currentStatus}, expected: ${expectedStatuses}!'`
            )
        }
    }
}
