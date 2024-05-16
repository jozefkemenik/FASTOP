import { EApps } from 'config'
import { EStatusRepo } from 'country-status'

import { EErrors, FastopError } from '../../../shared-lib/dist/prelib/error'
import { CountryStatusApi } from '../../../lib/dist/api/country-status.api'
import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { DfmApi } from '../../../lib/dist/api/dfm.api'
import { VectorService } from '../../../lib/dist'
import { catchAll } from '../../../lib/dist/catch-decorator'

import {
    ICopyFromFDMSStorage,
    IDBDeskUploadData,
    IDBIndicatorUpload,
    IDataUploadResult,
    IDeskUpload,
    IDeskUploadData,
    IFdmsCtyIndicatorScaleMap,
    IFdmsIndicator,
    IFdmsIndicatorMapping,
    IFdmsIndicatorUploadParam,
    IFdmsScale,
    IFileContent,
    IIndicatorDataUpload,
    IIndicatorResult,
    IIndicatorUpload,
    IIndicatorUploadData,
    IIndicatorsidData,
    IProviderUpload,
    ITceUpload,
    ITceUploadParam,
} from '.'
import { IDBIndicatorData } from '../report'
import { SharedService } from '../shared/shared.service'
import { UploadService } from './upload.service'

@catchAll(__filename)
export class UploadController {
    private static readonly OIL_PRICE_INDICATORS = [
        'OILPRC.1.0.99.0',
        'OILPRC.1.0.30.0',
        'OILPRC.6.0.99.0',
        'OILPRC.6.0.30.0',
    ]

    // cache
    private _countriesToArchive: string[]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly uploadService: UploadService,
        private readonly sharedService: SharedService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method copyFromFDMSStorage
     *********************************************************************************************/
    public async copyFromFDMSStorage(params: ICopyFromFDMSStorage, user: string) {
        const { roundSid, storageSid } = await DashboardApi.getCurrentRoundInfo(this.appId)
        const statuses = await CountryStatusApi.getCountryStatuses(this.appId, params.countryIds, {
            roundSid,
            storageSid,
        })

        if (
            !statuses.every(countryStatus =>
                [EStatusRepo.ACTIVE, EStatusRepo.REJECTED].includes(countryStatus.statusId),
            )
        ) {
            return EErrors.CTY_STATUS
        }
        const result = await this.uploadService.copyFromFDMSStorage(params)

        if (result > 0) {
            for (const countryId of params.countryIds) {
                await Promise.all(
                    params.providerIds.map(providerId =>
                        this.uploadService.setIndicatorDataUpload(roundSid, storageSid, providerId, countryId, user),
                    ),
                )
            }
        }
        return result
    }

    /**********************************************************************************************
     * @method getEerData
     *********************************************************************************************/
    public async getEerData(): Promise<IIndicatorDataUpload> {
        return this.uploadService.getEerData().then(res => {
            return res.reduce((acc, item) => {
                acc[item.countryId] = acc[item.countryId] ?? { indicatorData: [] }
                const pushItem: IIndicatorsidData = {
                    periodicityId: item.periodicityId,
                    indicatorSid: item.indicatorSid,
                    scaleSid: item.scaleSid,
                    seriesUnit: item.seriesUnit,
                    startYear: item.startYear,
                    code:item.code,
                    timeSerie: item.timeserieData.split(',').map(Number),     
                }
                acc[item.countryId].indicatorData.push(pushItem)
                return acc
            }, {})
        })
    }

    /**********************************************************************************************
     * @method getDeskUpload
     *********************************************************************************************/
    public async getDeskUpload(
        countryId: string,
        roundSid: number,
        storageSid: number,
        sendData: boolean,
    ): Promise<IDeskUpload> {
        return this.uploadService.getDeskUpload(countryId, roundSid, storageSid, sendData).then(
            // convert timeSeries strings to number arrays
            ({ annual, quarterly, ...restData }) => ({
                annual: annual?.map(this.convertDeskUploadData),
                quarterly: quarterly?.map(this.convertDeskUploadData),
                ...restData,
            }),
        )
    }

    /**********************************************************************************************
     * @method getOutputGapUpload
     *********************************************************************************************/
    public async getOutputGapUpload(
        providerId: string,
        roundSid: number,
        storageSid: number,
        sendData: boolean,
    ): Promise<IIndicatorUpload> {
        return this.uploadService
            .getProviderUpload(providerId, 'A', roundSid, storageSid, sendData)
            .then(this.convertDBIndicatorUpload)
    }

    /**********************************************************************************************
     * @method getCommoditiesUpload
     *********************************************************************************************/
    public async getCommoditiesUpload(
        providerId: string,
        roundSid: number,
        storageSid: number,
        sendData: boolean,
    ): Promise<IIndicatorUpload> {
        return this.uploadService
            .getProviderUpload(providerId, 'Q', roundSid, storageSid, sendData)
            .then(this.convertDBIndicatorUpload)
    }

    /**********************************************************************************************
     * @method getOutputGapResult
     *********************************************************************************************/
    public async getOutputGapResult(roundSid: number, storageSid: number): Promise<IIndicatorResult> {
        return this.sharedService
            .getProvidersIndicatorData(['PRE_PROD'], [], [], 'A', true, roundSid, storageSid)
            .then(data => ({ annual: this.convertDBIndicatorData(data) }))
    }

    /**********************************************************************************************
     * @method getCommoditiesResult
     *********************************************************************************************/
    public async getCommoditiesResult(roundSid: number, storageSid: number): Promise<IIndicatorResult> {
        return Promise.all([
            this.sharedService.getProvidersIndicatorData(
                ['PRE_PROD'],
                ['WORLD'],
                UploadController.OIL_PRICE_INDICATORS,
                'A',
                false,
                roundSid,
                storageSid,
            ),
            this.sharedService.getProvidersIndicatorData(
                ['PRE_PROD'],
                ['WORLD'],
                UploadController.OIL_PRICE_INDICATORS,
                'Q',
                false,
                roundSid,
                storageSid,
            ),
        ]).then(([annualData, quarterlyData]) => ({
            annual: this.convertDBIndicatorData(annualData),
            quarterly: this.convertDBIndicatorData(quarterlyData),
        }))
    }

    /**********************************************************************************************
     * @method getIndicatorDataUploads
     *********************************************************************************************/
    public async getIndicatorDataUploads(roundSid: number, storageSid: number): Promise<IProviderUpload[]> {
        return this.uploadService.getIndicatorDataUploads(roundSid, storageSid)
    }

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public getIndicators(providerId: string): Promise<IFdmsIndicator[]> {
        return this.uploadService.getFdmsIndicators(providerId)
    }

    /**********************************************************************************************
     * @method getIndicatorsMappings
     *********************************************************************************************/
    public getIndicatorsMappings(providerId: string): Promise<IFdmsIndicatorMapping[]> {
        return this.uploadService.getFdmsIndicatorsMappings(providerId)
    }

    /**********************************************************************************************
     * @method getScales
     *********************************************************************************************/
    public getScales(): Promise<IFdmsScale[]> {
        return this.uploadService.getFdmsScales()
    }

    /**********************************************************************************************
     * @method uploadIndicatorData
     *********************************************************************************************/
    public async uploadIndicatorData(
        roundSid: number,
        storageSid: number,
        providerId: string,
        countryIds: string[],
        data: IIndicatorDataUpload,
        user: string,
    ): Promise<IDataUploadResult> {
        return countryIds
            ? Promise.all(
                  countryIds.map(countryId =>
                      this.uploadCountryIndicatorData(roundSid, storageSid, providerId, countryId, data, user),
                  ),
              ).then(results => results.reduce((acc, r) => Object.assign(acc, r), {}))
            : this.uploadCountryIndicatorData(roundSid, storageSid, providerId, null, data, user)
    }

    /**********************************************************************************************
     * @method uploadTceDataHandler
     *********************************************************************************************/
    public async uploadTceDataHandler(
        roundSid: number,
        storageSid: number,
        providerId: string,
        data: ITceUpload[],
        user: string,
    ): Promise<IDataUploadResult> {
        const matrixSid: number = await this.uploadService.setTceMatrix(providerId, roundSid, storageSid)
        if (matrixSid <= 0) throw new Error('Internal error preparing tce upload matrix')

        const params: ITceUploadParam[] = this.prepareTceUploadParams(matrixSid, data)

        return this.uploadInChunks(
            roundSid,
            storageSid,
            providerId,
            null,
            user,
            params,
            this.uploadTceMatrixData.bind(this),
        )
    }

    /**********************************************************************************************
     * @method uploadFile
     *********************************************************************************************/
    public uploadFile(
        countryId: string,
        providerId: string,
        roundSid: number,
        storageSid: number,
        custTextSid: number,
        file: Express.Multer.File,
        user: string,
    ): Promise<number> {
        return this.uploadService.uploadFile(
            countryId,
            providerId,
            roundSid,
            storageSid,
            custTextSid,
            file.originalname,
            file.mimetype,
            file.buffer,
            user,
        )
    }

    /**********************************************************************************************
     * @method getFiles
     *********************************************************************************************/
    public getFiles(roundSid: number, storageSid: number, custTextSid: number) {
        return this.uploadService.getFiles(roundSid, storageSid, custTextSid)
    }

    /**********************************************************************************************
     * @method downloadFile
     *********************************************************************************************/
    public downloadFile(fileSid: number): Promise<IFileContent> {
        return this.uploadService.downloadFile(fileSid)
    }

    /**********************************************************************************************
     * @method getCtyIndicatorScales
     *********************************************************************************************/
    public getCtyIndicatorScales(providerId: string): Promise<IFdmsCtyIndicatorScaleMap> {
        return this.uploadService.getCtyIndicatorScales(providerId).then(ctyIndicators =>
            ctyIndicators.reduce((curr, val) => {
                curr[val.CTY_IND] = val.SCALE_SID
                return curr
            }, {}),
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method uploadCountryIndicatorData
     *********************************************************************************************/
    private async uploadCountryIndicatorData(
        roundSid: number,
        storageSid: number,
        providerId: string,
        countryId: string,
        data: IIndicatorDataUpload,
        user: string,
    ): Promise<IDataUploadResult> {
        try {
            const params: IFdmsIndicatorUploadParam[] = this.prepareFdmsIndicatorUploadParams(data, countryId)

            if (countryId) {
                const status = await CountryStatusApi.getCountryStatusId(this.appId, countryId, {
                    roundSid,
                    storageSid,
                })
                if (![EStatusRepo.ACTIVE, EStatusRepo.REJECTED].includes(status)) {
                    throw new FastopError(EErrors.CTY_STATUS)
                }
            }

            return this.uploadInChunks(
                roundSid,
                storageSid,
                providerId,
                countryId,
                user,
                params,
                this.uploadFdmsIndicatorData.bind(this),
            ).then(
                res => res,
                err => this.handleCountryIndicatorUploadError(countryId, err),
            )
        } catch (err) {
            return this.handleCountryIndicatorUploadError(countryId, err)
        }
    }

    /**********************************************************************************************
     * @method handleCountryIndicatorUploadError
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private handleCountryIndicatorUploadError(countryId: string, error: any): IDataUploadResult {
        if (countryId) {
            const result: IDataUploadResult = {}
            result[countryId] = error.code || -1
            return result
        } else throw error
    }

    /**********************************************************************************************
     * @method uploadInChunks
     *********************************************************************************************/
    private async uploadInChunks<T>(
        roundSid: number,
        storageSid: number,
        providerId: string,
        countryId: string,
        user: string,
        params: T[],
        uploadFunction: (
            params: T,
            roundSid?: number,
            storageSid?: number,
            user?: string,
        ) => Promise<IDataUploadResult>,
    ): Promise<IDataUploadResult> {
        const results: IDataUploadResult = {}
        const maxRequests = 8
        let index = 0
        // Reshape params array into array of arrays of size maxRequest
        const paramsChunks: T[][] = params.reduce((acc, param) => {
            if (!acc[index]) acc.push([])
            acc[index].push(param)
            if (acc[index].length >= maxRequests) index++
            return acc
        }, [])

        // Execs SPs in chunks of size maxRequest, to avoid blocking for too long
        for (const chunk of paramsChunks) {
            const res: IDataUploadResult[] = await Promise.all(
                chunk.map(param => uploadFunction(param, roundSid, storageSid, user)),
            )

            res.reduce((acc, value) => Object.assign(acc, value), results)
        }

        if (Object.values(results).every(v => v > 0)) {
            // If there are no error, we register the uploaded data
            const registerUploadResult = await this.uploadService.setIndicatorDataUpload(
                roundSid,
                storageSid,
                providerId,
                countryId,
                user,
            )

            if (registerUploadResult < 0) {
                throw new Error('Internal error registering upload')
            }

            if (providerId === 'DESK' && this.appId === EApps.FDMS) {
                this._countriesToArchive =
                    this._countriesToArchive ??
                    (await DashboardApi.getCountryGroupCountries('EU').then(cs => cs.map(c => c.COUNTRY_ID)))

                if (this._countriesToArchive.includes(countryId)) {
                    const res = await DfmApi.archiveCountryMeasures(countryId, user, { roundSid, storageSid })
                    if (res.result !== EErrors.IGNORE && res.result < 0) {
                        throw new Error(`Internal error archiving DFM: ${res.result}`)
                    }
                }
            }
        }

        return results
    }

    /**********************************************************************************************
     * @method uploadFdmsIndicatorData
     *********************************************************************************************/
    private uploadFdmsIndicatorData(
        params: IFdmsIndicatorUploadParam,
        roundSid: number,
        storageSid: number,
        user: string,
    ): Promise<IDataUploadResult> {
        return this.uploadService.uploadFdmsIndData(roundSid, storageSid, params, user).then(result => {
            switch (result) {
                case -1:
                    result = EErrors.IDR_SCALE_INVALID
                    break
                case -2:
                    result = EErrors.IDR_SCALE_DIFFERENT
                    break
                case -3:
                    result = EErrors.ROUND_KEYS
                    break
                case -4:
                    result = EErrors.IDR_DUPLICATE
                    break
            }
            const ret = {}
            ret[params.countryId] = result
            return ret
        })
    }

    /**********************************************************************************************
     * @method uploadTceMatrixData
     *********************************************************************************************/
    private uploadTceMatrixData(params: ITceUploadParam): Promise<IDataUploadResult> {
        return this.uploadService.uploadTceMatrixData(params)
    }

    /**********************************************************************************************
     * @method prepareFdmsIndicatorUploadParams
     *********************************************************************************************/
    private prepareFdmsIndicatorUploadParams(
        data: IIndicatorDataUpload,
        countryId?: string,
    ): IFdmsIndicatorUploadParam[] {
        return Object.keys(data)
            .filter(key => !countryId || key.toUpperCase() === countryId.toUpperCase())
            .map(indCountryId => {
                const indicatorData = data[indCountryId].indicatorData
                const [startYears, indicatorSids, scaleSids, timeSeries] = indicatorData.reduce(
                    ([years, indSids, scales, series], indicator) => {
                        years.push(indicator.startYear)
                        indSids.push(indicator.indicatorSid)
                        scales.push(indicator.scaleSid)
                        // frontend sends array of numbers (with nulls). Conversion from null to 'na' happens here
                        series.push(indicator.timeSerie.map(v => (this.isNumber(`${v}`) ? v : 'na')).join(','))
                        return [years, indSids, scales, series]
                    },
                    [[], [], [], []],
                )
                return {
                    countryId: indCountryId,
                    startYears,
                    indicatorSids,
                    scaleSids,
                    timeSeries,
                }
            })
    }

    /**********************************************************************************************
     * @method isNumber
     *********************************************************************************************/
    private isNumber(data: string): boolean {
        return data !== undefined && data !== null && `${data}`.trim() !== '' && !isNaN(Number(data))
    }

    /**********************************************************************************************
     * @method convertDeskUploadData
     *********************************************************************************************/
    private convertDeskUploadData: (data: IDBDeskUploadData) => IDeskUploadData = ({ TIMESERIE_DATA, ...rest }) => ({
        timeSerie: this.timeSerieStringToArray(TIMESERIE_DATA),
        ...rest,
    })

    /**********************************************************************************************
     * @method convertDBIndicatorUpload
     *********************************************************************************************/
    private convertDBIndicatorUpload: (dbUpload: IDBIndicatorUpload) => IIndicatorUpload = ({ data, ...restData }) => ({
        data: data?.map(({ TIMESERIE_DATA, ...rest }) => ({
            timeSerie: this.timeSerieStringToArray(TIMESERIE_DATA),
            ...rest,
        })),
        ...restData,
    })

    /**********************************************************************************************
     * @method convertDBIndicatorData
     *********************************************************************************************/
    private convertDBIndicatorData: (dbIndData: IDBIndicatorData[]) => IIndicatorUploadData[] = data =>
        data?.map(({ TIMESERIE_DATA, ...rest }) => ({
            timeSerie: this.timeSerieStringToArray(TIMESERIE_DATA),
            ...rest,
        }))

    /**********************************************************************************************
     * @method timeSerieStringToArray
     *********************************************************************************************/
    private timeSerieStringToArray(timeSerie: string): number[] {
        return VectorService.stringToVector(timeSerie)
    }

    /**********************************************************************************************
     * @method prepareTceUploadParams
     *********************************************************************************************/
    private prepareTceUploadParams(matrixSid: number, data: ITceUpload[]): ITceUploadParam[] {
        return data.map(d => ({
            matrixSid,
            expCtyId: d.expCtyId,
            expLineNr: d.expLineNr,
            prntCtyIds: d.partners.map(p => p.prtCtyId),
            prntColNrs: d.partners.map(p => p.prtColNr),
            values: d.partners.map(p => (this.isNumber(`${p.value}`) ? `${p.value}` : 'na')),
        }))
    }
}
