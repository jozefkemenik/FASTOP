import 'chai/register-should.js'
import * as sinon from 'sinon'

import { BIND_OUT, BLOB, BUFFER, CURSOR, DATE, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { UploadService } from '../../src/upload/upload.service'

describe('UploadService test suite', function() {

    let execSPStub
    const appId = EApps.FDMS
    const uploadService = new UploadService(appId)

    beforeEach(function() {
        execSPStub = sinon.stub(DataAccessApi, 'execSP')
    })

    afterEach(function() {
        execSPStub.restore()
    })

    describe('copyFromFDMSStorage method', function() {

        it('should execute successfully', async function() {
            // given
            const params = {
                countryIds: ['PL', 'BE'],
                providerIds: ['AMECO_H', 'PRE_PROD'],
                indicatorIds: ['PMGN.6.1.0.0', 'ZCPIH.6.0.0.0'],
                roundSid: 23,
                storageSid: 3,
            }
            execSPStub.resolves({ o_res: 13 })

            // when
            const result = await uploadService.copyFromFDMSStorage(params)

            // then
            result.should.be.eql(13)
            execSPStub.calledWithExactly('fdms_indicator.copyFromFDMSStorage', {
                params: [
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                    { name: 'p_app_id', type: STRING, value: appId },
                    { name: 'p_country_ids', type: STRING, value: params.countryIds },
                    { name: 'p_provider_ids', type: STRING, value: params.providerIds },
                    { name: 'p_round_sid', type: NUMBER, value: params.roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: params.storageSid },
                    { name: 'p_indicator_ids', type: STRING, value: params.indicatorIds },
                ],
            }).should.be.true
        })
    })

    describe('getDeskUpload method', function() {

        it('should execute successfully', async function() {
            // given
            const countryId = 'PL'
            const roundSid = 56
            const storageSid = 5
            const sendData = true

            const dbData = {
                o_user: 'mnemonicj',
                o_date: '2021-12-03',
                o_cur_annual: {
                    INDICATOR_ID: 'PMGN.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2016,
                    TIMESERIE_DATA: '1.2, n/a, 0.002, 233.22'
                },
                o_cur_quarterly: {
                    INDICATOR_ID: 'ZUTN.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2015,
                    TIMESERIE_DATA: '-0.09, 1.0002, n/a, N/A, 33.445'
                }
            }
            execSPStub.resolves(dbData)

            // when
            const result = await uploadService.getDeskUpload(countryId, roundSid, storageSid, sendData)

            // then
            result.should.be.eql({
                user: dbData.o_user,
                date: dbData.o_date,
                annual: dbData.o_cur_annual,
                quarterly: dbData.o_cur_quarterly
            })
            execSPStub.calledWithExactly('fdms_upload.getDeskUpload', {
                params: [
                    { name: 'o_user', type: STRING, dir: BIND_OUT },
                    { name: 'o_date', type: DATE, dir: BIND_OUT },
                    { name: 'o_cur_annual', type: CURSOR, dir: BIND_OUT },
                    { name: 'o_cur_quarterly', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_country_id', type: STRING, value: countryId },
                    { name: 'p_send_data', type: NUMBER, value: Number(sendData) },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                ],
            }).should.be.true
        })
    })

    describe('getProviderUpload method', function() {

        it('should execute successfully', async function() {
            // given
            const providerId = 'PRE_PROD'
            const periodicity = 'Q'
            const roundSid = 13
            const storageSid = 6
            const sendData = false

            const dbData = {
                o_user: 'laskowikz',
                o_date: '2022-03-04',
                o_cur: [
                    { COUNTRY_ID: 'PL', COUNTRY_DESCR: 'Poland', SCALE_DESCR: 'Units' },
                    { COUNTRY_ID: 'BE', COUNTRY_DESCR: 'Belgium', SCALE_DESCR: 'Units' },
                ]
            }
            execSPStub.resolves(dbData)

            // when
            const result = await uploadService.getProviderUpload(providerId, periodicity, roundSid, storageSid, sendData)

            // then
            result.should.be.eql({
                user: dbData.o_user,
                date: dbData.o_date,
                data: dbData.o_cur,
            })
            execSPStub.calledWithExactly('fdms_upload.getProviderUpload', {
                params: [
                    { name: 'o_user', type: STRING, dir: BIND_OUT },
                    { name: 'o_date', type: DATE, dir: BIND_OUT },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_provider_id', type: STRING, value: providerId },
                    { name: 'p_periodicity', type: STRING, value: periodicity },
                    { name: 'p_send_data', type: NUMBER, value: Number(sendData) },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                ],
            }).should.be.true
        })
    })

    describe('getFdmsIndicators method', function() {

        const dbData = [{
            indicatorSid: 24,
            indicatorId: 'ESTAT_Q',
            periodicityId: 'Q',
            indicatorDescr: 'Eurostat quarterly'
        }]

        it('should return provider specific indicators', async function() {
            // given
            const providerId = 'ESTAT_Q'
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await uploadService.getFdmsIndicators(providerId)

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_indicator.getIndicators', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_provider_id', type: STRING, value: providerId },
                ],
            }).should.be.true
        })

        it('should return all providers indicators', async function() {
            // given
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await uploadService.getFdmsIndicators(null)

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_indicator.getIndicators', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('getFdmsScales method', function() {

        it('should return fdms scales', async function() {
            // given
            const dbData = [{
                scaleSid: 7,
                scaleId: 'BILLION',
                descr: 'Billions of national currency',
            }]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await uploadService.getFdmsScales()

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_getters.getScales', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('uploadFdmsIndData method', function() {

        it('should execute successfully', async function() {
            // given
            const roundSid = 34
            const storageSid = 4
            const params = {
                countryId: 'HR',
                indicatorSids: [34,53,12],
                scaleSids: [3,3,1],
                startYears: [1960,1965,1965],
                timeSeries: ['0.02,n/a,n/a',',,','3.44,3.0009, -0.0003']
            }
            const user = 'luckyl'
            execSPStub.resolves({ o_res: 2 })

            // when
            const result = await uploadService.uploadFdmsIndData(roundSid, storageSid, params, user)

            // then
            result.should.be.eql(2)
            execSPStub.calledWithExactly('fdms_indicator.setIndicatorData', {
                params: [
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                    { name: 'p_app_id', type: STRING, value: appId },
                    { name: 'p_country_id', type: STRING, value: params.countryId },
                    { name: 'p_indicator_sids', type: NUMBER, value: params.indicatorSids },
                    { name: 'p_scale_sids', type: NUMBER, value: params.scaleSids },
                    { name: 'p_start_years', type: NUMBER, value: params.startYears },
                    { name: 'p_time_series', type: STRING, value: params.timeSeries },
                    { name: 'p_user', type: STRING, value: user },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                ],
            }).should.be.true
        })
    })

    describe('setIndicatorDataUpload method', function() {

        const roundSid = 24
        const storageSid = 1
        const providerId = 'PRE_PROD'
        const user = 'chopinf'

        it('should execute successfully for specific country', async function() {
            // given
            const countryId = 'HR'
            execSPStub.resolves({ o_res: 7 })

            // when
            const result = await uploadService.setIndicatorDataUpload(roundSid, storageSid, providerId, countryId, user)

            // then
            result.should.be.eql(7)
            execSPStub.calledWithExactly('fdms_upload.setIndicatorDataUpload', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'p_provider_id', type: STRING, value: providerId },
                    { name: 'p_user', type: STRING, value: user },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                    { name: 'p_country_id', type: STRING, value: countryId },
                ],
            }).should.be.true
        })

        it('should execute successfully for all countries', async function() {
            // given
            execSPStub.resolves({ o_res: 100 })

            // when
            const result = await uploadService.setIndicatorDataUpload(roundSid, storageSid, providerId, undefined, user)

            // then
            result.should.be.eql(100)
            execSPStub.calledWithExactly('fdms_upload.setIndicatorDataUpload', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'p_provider_id', type: STRING, value: providerId },
                    { name: 'p_user', type: STRING, value: user },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('getIndicatorDataUploads method', function() {

        it('should return indicator data uploads info', async function() {
            // given
            const roundSid = 87
            const storageSid = 5
            const dbData = [{
                providerId: 'AMCO_H',
                providerDescr: 'Ameco historical',
                lastUpdated: new Date('2022-06-01'),
                updatedBy: 'moniuszs'
            }]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await uploadService.getIndicatorDataUploads(roundSid, storageSid)

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_upload.getIndicatorDataUploads', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('setTceMatrix method', function() {

        it('should execute successfully', async function() {
            // given
            const roundSid = 24
            const providerId = 'PRE_PROD'
            const storageSid = 5
            execSPStub.resolves({ o_res: 5 })

            // then
            const result = await uploadService.setTceMatrix(providerId, roundSid, storageSid)

            //when
            result.should.be.eql(5)
            execSPStub.calledWithExactly('fdms_tce.setTceMatrix', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'p_provider_id', type: STRING, value: providerId },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('uploadTceMatrixData method', function() {

        it('should execute successfully', async function(){
            // given
            const params = {
                matrixSid: 3,
                expCtyId: 'BE',
                expLineNr: 15,
                prntCtyIds: ['HR', 'FR'],
                prntColNrs: [2,4],
                values: ['23.22', '34.21']
            }
            execSPStub.resolves({ o_res: 3 })

            // when
            const result = await uploadService.uploadTceMatrixData(params)

            // then
            result.should.be.eql({ BE: 3 })
            execSPStub.calledWithExactly('fdms_tce.setTceMatrixData', {
                params: [
                    { name: 'p_matrix_sid', type: NUMBER, value: params.matrixSid },
                    { name: 'p_exp_cty_id', type: STRING, value: params.expCtyId },
                    { name: 'p_exp_line_nr', type: NUMBER, value: params.expLineNr },
                    { name: 'p_prnt_cty_ids', type: STRING, value: params.prntCtyIds },
                    { name: 'p_prnt_col_nbrs', type: NUMBER, value: params.prntColNrs },
                    { name: 'p_values', type: STRING, value: params.values },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('uploadFile method', function() {

        it('should upload file', async function() {
            // given
            const countryId = 'PT'
            const providerId = 'DESK'
            const roundSid = 76
            const storageSid = 2
            const custTextSid = 2
            const fileName = 'pt_forecast.xlsx'
            const mimeType = 'excel/xml'
            const fileContent = null
            const user = 'kimonof'
            execSPStub.resolves({ o_res: 1 })

            // when
            const result = await uploadService.uploadFile(
                countryId, providerId, roundSid, storageSid, custTextSid, fileName, mimeType, fileContent, user
            )

            // then
            result.should.be.eql(1 )
            execSPStub.calledWithExactly('fdms_upload.uploadFile', {
                params: [
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                    { name: 'p_app_id', type: STRING, value: appId },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'p_cust_text_sid', type: NUMBER, value: custTextSid },
                    { name: 'p_country_id', type: STRING, value: countryId },
                    { name: 'p_provider_id', type: STRING, value: providerId },
                    { name: 'p_file_name', type: STRING, value: fileName },
                    { name: 'p_content_type', type: STRING, value: mimeType },
                    { name: 'p_content', type: BLOB, value: fileContent },
                    { name: 'p_last_change_user', type: STRING, value: user },
                ]
            }).should.be.true
        })
    })

    describe('getFiles method', function() {

        it('should return uploaded files', async function() {
            // given
            const roundSid = 12
            const storageSid = 1
            const custTextSid = 42
            const dbData = [{
                fileSid: 2,
                fileName: 'forecast_upload.xlsx',
                country: 'PT',
                changeDate: new Date('2022-06-06'),
                changeUser: 'droulezh',
                providerName: 'DESK'
            }]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await uploadService.getFiles(roundSid, storageSid, custTextSid)

            // then
            result.should.be.eql(dbData )
            execSPStub.calledWithExactly('fdms_upload.getFiles', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_app_id', type: STRING, value: appId },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'p_cust_text_sid', type: NUMBER, value: custTextSid },
                ]
            }).should.be.true
        })
    })

    describe('downloadFile method', function() {

        it('should return buffer content', async function() {
            // given
            const fileSid = 245
            const dbData = 'Wlazł kotek na płotek'
            execSPStub.resolves({ o_cur: [dbData] })

            // when
            const result = await uploadService.downloadFile(fileSid)

            // then
            result.should.be.eql(dbData )
            execSPStub.calledWithExactly('fdms_upload.downloadFile', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_file_sid', type: NUMBER, value: fileSid },
                ],
                fetchInfo: {
                    content: { type: BUFFER }
                }
            }).should.be.true
        })
    })

    describe('getCtyIndicatorScales method', function() {

        it('should return country indicator scales', async function() {
            // given
            const providerId = 'AMECO_H'
            const dbData = [
                { CTY_IND: 'PL', SCALE_SID: 3 },
                { CTY_IND: 'BE', SCALE_SID: 2 },
            ]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await uploadService.getCtyIndicatorScales(providerId)

            // then
            result.should.be.eql(dbData )
            execSPStub.calledWithExactly('fdms_indicator.getCtyIndicatorScales', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_provider_id', type: STRING, value: providerId },
                ]
            }).should.be.true
        })
    })
})

