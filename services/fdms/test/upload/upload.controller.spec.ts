import 'chai/register-should.js'
import * as sinon from 'sinon'
import { should } from 'chai'

import { CountryStatusApi, DashboardApi, DfmApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { EStatusRepo } from 'country-status'
import { SharedService } from '../../src/shared/shared.service'
import { UploadController } from '../../src/upload/upload.controller'
import { UploadService } from '../../src/upload/upload.service'

describe('UploadController test suite', function() {

    const appId = EApps.FDMS
    const uploadServiceStub = sinon.createStubInstance(UploadService)
    const sharedServiceStub = sinon.createStubInstance(SharedService)
    const uploadController = new UploadController(appId, uploadServiceStub, sharedServiceStub)

    // test data
    const roundInfo = {
        roundSid: 1540,
        year: 2022,
        roundDescr: 'Spring 2022',
        periodDescr: 'Spring',
        periodId: 'SPR',
        storageSid: 6,
        storageDescr: 'Final',
        storageId: 'FINAL',
        textSid: null,
        textTitle: null,
        textDescr: null,
        version: 2,
    }

    // stubs
    let getCurrentRoundInfoStub

    beforeEach(function() {
        getCurrentRoundInfoStub = sinon.stub(DashboardApi, 'getCurrentRoundInfo').resolves(roundInfo)
    })

    afterEach(function() {
        getCurrentRoundInfoStub.restore()
    })


    describe('copyFromFDMSStorage method', function() {

        // test data
        const params = {
            countryIds: ['PL', 'BE', 'FR'],
            providerIds: ['PRE_PROD'],
            indicatorIds: ['XNE.1.0.99.0'],
            roundSid: 321,
            storageSid: 5,
        }
        const user = 'andersonn'

        // stubs
        let getCountryStatusesStub

        beforeEach(function() {
            getCountryStatusesStub = sinon.stub(CountryStatusApi, 'getCountryStatuses')
        })

        afterEach(function() {
            getCountryStatusesStub.restore()
            uploadServiceStub.copyFromFDMSStorage.reset()
            uploadServiceStub.setIndicatorDataUpload.reset()
        })

        it('should return CTY_STATUS error', async function() {
            // given
            getCountryStatusesStub.resolves([
                {
                    countryId: 'BE',
                    countryDescr: 'Belgium',
                    lastChangeDate: '2022-02-07',
                    lastChangeUser: 'zelensky',
                    statusSid: 3,
                    statusId: EStatusRepo.ACTIVE,
                    statusDescr: 'Open',
                    statusTrDescr: 'TR Open',
                },
                {
                    countryId: 'FR',
                    countryDescr: 'France',
                    lastChangeDate: '2022-08-05',
                    lastChangeUser: 'drulez',
                    statusSid: 2,
                    statusId: EStatusRepo.REJECTED,
                    statusDescr: 'Accepted',
                    statusTrDescr: 'TR accepted',
                },
                {
                    countryId: 'PL',
                    countryDescr: 'France',
                    lastChangeDate: '2022-08-05',
                    lastChangeUser: 'drulez',
                    statusSid: 2,
                    statusId: EStatusRepo.OPENED,
                    statusDescr: 'Accepted',
                    statusTrDescr: 'TR accepted',
                }
            ])

            // when
            const result = await uploadController.copyFromFDMSStorage(params, user)

            // then
            result.should.be.eql(EErrors.CTY_STATUS)
            getCountryStatusesStub.calledOnceWithExactly(
                appId, params.countryIds, { roundSid: roundInfo.roundSid, storageSid: roundInfo.storageSid }
            ).should.be.true
            uploadServiceStub.copyFromFDMSStorage.called.should.be.false
            uploadServiceStub.setIndicatorDataUpload.called.should.be.false
        })

        it('should not copy fdms data', async function() {
            // given
            getCountryStatusesStub.resolves([
                {
                    countryId: 'BE',
                    countryDescr: 'Belgium',
                    lastChangeDate: '2022-02-07',
                    lastChangeUser: 'zelensky',
                    statusSid: 3,
                    statusId: EStatusRepo.ACTIVE,
                    statusDescr: 'Open',
                    statusTrDescr: 'TR Open',
                },
                {
                    countryId: 'FR',
                    countryDescr: 'France',
                    lastChangeDate: '2022-08-05',
                    lastChangeUser: 'drulez',
                    statusSid: 2,
                    statusId: EStatusRepo.ACTIVE,
                    statusDescr: 'Accepted',
                    statusTrDescr: 'TR accepted',
                },
                {
                    countryId: 'PL',
                    countryDescr: 'France',
                    lastChangeDate: '2022-08-05',
                    lastChangeUser: 'drulez',
                    statusSid: 2,
                    statusId: EStatusRepo.REJECTED,
                    statusDescr: 'Accepted',
                    statusTrDescr: 'TR accepted',
                }
            ])
            uploadServiceStub.copyFromFDMSStorage.resolves(0)

            // when
            const result = await uploadController.copyFromFDMSStorage(params, user)

            // then
            result.should.be.eql(0)
            getCountryStatusesStub.calledOnceWithExactly(
                appId, params.countryIds, { roundSid: roundInfo.roundSid, storageSid: roundInfo.storageSid }
            ).should.be.true
            uploadServiceStub.copyFromFDMSStorage.calledOnceWithExactly(params).should.be.true
            uploadServiceStub.setIndicatorDataUpload.called.should.be.false
        })

        it('should copy fdms data and set upload info', async function() {
            // given
            getCountryStatusesStub.resolves([
                {
                    countryId: 'BE',
                    countryDescr: 'Belgium',
                    lastChangeDate: '2022-02-07',
                    lastChangeUser: 'zelensky',
                    statusSid: 3,
                    statusId: EStatusRepo.ACTIVE,
                    statusDescr: 'Open',
                    statusTrDescr: 'TR Open',
                },
                {
                    countryId: 'FR',
                    countryDescr: 'France',
                    lastChangeDate: '2022-08-05',
                    lastChangeUser: 'drulez',
                    statusSid: 2,
                    statusId: EStatusRepo.ACTIVE,
                    statusDescr: 'Accepted',
                    statusTrDescr: 'TR accepted',
                },
                {
                    countryId: 'PL',
                    countryDescr: 'France',
                    lastChangeDate: '2022-08-05',
                    lastChangeUser: 'drulez',
                    statusSid: 2,
                    statusId: EStatusRepo.REJECTED,
                    statusDescr: 'Accepted',
                    statusTrDescr: 'TR accepted',
                }
            ])
            uploadServiceStub.copyFromFDMSStorage.resolves(1)
            uploadServiceStub.setIndicatorDataUpload.resolves(1)

            // when
            const result = await uploadController.copyFromFDMSStorage(params, user)

            // then
            result.should.be.eql(1)
            getCountryStatusesStub.calledOnceWithExactly(
                appId, params.countryIds, { roundSid: roundInfo.roundSid, storageSid: roundInfo.storageSid }
            ).should.be.true
            uploadServiceStub.copyFromFDMSStorage.calledOnceWithExactly(params).should.be.true

            for (const countryId of params.countryIds) {
                for (const providerId of params.providerIds) {
                    uploadServiceStub.setIndicatorDataUpload.calledWithExactly(
                        roundInfo.roundSid, roundInfo.storageSid, providerId, countryId, user
                    ).should.be.true
                }
            }
        })
    })

    describe('getDeskUpload method', function() {

        after(function() {
            uploadServiceStub.getDeskUpload.reset()
        })

        it('should return desk upload info', async function() {
            // given
            const countryId = 'PL'
            const roundSid = 321
            const storageSid = 5
            const sendData = false
            uploadServiceStub.getDeskUpload.resolves({
                user: 'brosm',
                date: '2022-06-08',
                annual: [{
                    INDICATOR_ID: 'ZCPIH.6.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1990,
                    TIMESERIE_DATA: '0.2, 0.0002, n/a, -0.001, 1.232',
                }],
                quarterly: [{
                    INDICATOR_ID: 'AVGDGP.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1992,
                    TIMESERIE_DATA: 'n/a,N/A,,,0.0001, 0.9, 2222.212123',
                }]
            })

            // when
            const result = await uploadController.getDeskUpload(countryId, roundSid, storageSid, sendData)

            // then
            result.should.be.eql(
            {
                annual: [{
                    timeSerie: [0.2,0.0002,NaN,-0.001,1.232],
                    INDICATOR_ID: 'ZCPIH.6.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR:1990
                }],
                quarterly: [{
                    timeSerie: [NaN,NaN,NaN,NaN,0.0001,0.9,2222.212123],
                    INDICATOR_ID: 'AVGDGP.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1992
                }],
                user: 'brosm',
                date: '2022-06-08'
            })
            uploadServiceStub.getDeskUpload.calledOnceWithExactly(countryId, roundSid, storageSid, sendData).should.be.true
        })
    })

    describe('getOutputGapUpload method', function() {

        after(function() {
            uploadServiceStub.getProviderUpload.reset()
        })

        it('should return OG upload info', async function() {
            // given
            const providerId = 'OG_UPLOAD'
            const roundSid = 68
            const storageSid = 1
            const sendData = true
            uploadServiceStub.getProviderUpload.resolves({
                user: 'ramobj',
                date: '2022-06-07',
                data: [{
                    COUNTRY_ID: 'IT',
                    COUNTRY_DESCR: 'Italy',
                    SCALE_DESCR: 'Units',
                    TIMESERIE_DATA: '1.2, N/A, 2.32, 13',
                    INDICATOR_ID: 'HWCDW.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2000,
                }]
            })

            // when
            const result = await uploadController.getOutputGapUpload(providerId, roundSid, storageSid, sendData)

            // then
            result.should.be.eql({
                data: [{
                    timeSerie: [1.2,NaN,2.32,13],
                    COUNTRY_ID: 'IT',
                    COUNTRY_DESCR: 'Italy',
                    SCALE_DESCR: 'Units',
                    INDICATOR_ID: 'HWCDW.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR:2000
                }],
                user: 'ramobj',
                date: '2022-06-07'
            })
            uploadServiceStub.getProviderUpload.calledOnceWithExactly(
                providerId, 'A', roundSid, storageSid, sendData
            ).should.be.true
        })
    })

    describe('getCommoditiesUpload method', function() {

        after(function() {
            uploadServiceStub.getProviderUpload.reset()
        })

        it('should return commodities upload info', async function() {
            // given
            const providerId = 'COMM_OIL'
            const roundSid = 762
            const storageSid = 2
            const sendData = false
            uploadServiceStub.getProviderUpload.resolves({
                user: 'deppj',
                date: '2022-06-05',
                data: [{
                    INDICATOR_ID: 'RVGDE.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1997,
                    COUNTRY_ID: 'PL',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Unit',
                    TIMESERIE_DATA: '0.0002,N/A,0,-1.22,,2'
                }]
            })

            // when
            const result = await uploadController.getCommoditiesUpload(providerId, roundSid, storageSid, sendData)

            // then
            result.should.be.eql({
                data: [{
                    timeSerie: [0.0002,NaN,0,-1.22,NaN,2],
                    INDICATOR_ID: 'RVGDE.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1997,
                    COUNTRY_ID: 'PL',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Unit'
                }],
                user: 'deppj',
                date: '2022-06-05'
            })
            uploadServiceStub.getProviderUpload.calledOnceWithExactly(
                providerId, 'Q', roundSid, storageSid, sendData
            ).should.be.true
        })
    })

    describe('getOutputGapResult method', function() {

        after(function() {
            sharedServiceStub.getProvidersIndicatorData.reset()
        })

        it('should return OG result', async function() {
            // given
            const roundSid = 23
            const storageSid = 3
            sharedServiceStub.getProvidersIndicatorData.resolves([{
                COUNTRY_ID: 'PL',
                INDICATOR_ID: 'ZCPIH.6.0.0.0',
                SCALE_ID: 'UNIT',
                START_YEAR: 1999,
                PERIODICITY_ID: 'A',
                COUNTRY_DESCR: 'Poland',
                SCALE_DESCR: 'Unit',
                DATA_SOURCE: 'FDMS*',
                UPDATE_DATE: new Date('2022-05-03'),
                TIMESERIE_DATA: '0.0001, -0.1, 3, #N/A'
            }])

            // when
            const result = await uploadController.getOutputGapResult(roundSid, storageSid)

            // then
            result.should.be.eql({
                annual: [{
                    timeSerie: [0.0001,-0.1,3,NaN],
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'ZCPIH.6.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1999,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-03'),
                }]
            })
            sharedServiceStub.getProvidersIndicatorData.calledOnceWithExactly(
                ['PRE_PROD'], [], [], 'A', true, roundSid, storageSid
            ).should.be.true
        })
    })

    describe('getCommoditiesResult method', function() {

        after(function() {
            sharedServiceStub.getProvidersIndicatorData.reset()
        })

        it('should return commodities result', async function() {
            // given
            const roundSid = 12
            const storageSid = 6
            sharedServiceStub.getProvidersIndicatorData.onFirstCall().resolves([{
                COUNTRY_ID: 'PL',
                INDICATOR_ID: 'OUTT.6.1.0.0',
                SCALE_ID: 'MILLION',
                START_YEAR: 2002,
                PERIODICITY_ID: 'A',
                COUNTRY_DESCR: 'Poland',
                SCALE_DESCR: 'Millions',
                DATA_SOURCE: 'FDMS*',
                UPDATE_DATE: new Date('2022-06-01'),
                TIMESERIE_DATA: '12.4,13.55,23.45323,n/a,0.1',
            }])
            sharedServiceStub.getProvidersIndicatorData.onSecondCall().resolves([{
                COUNTRY_ID: 'PL',
                INDICATOR_ID: 'OUTT.6.1.0.0',
                SCALE_ID: 'MILLION',
                START_YEAR: 2002,
                PERIODICITY_ID: 'Q',
                COUNTRY_DESCR: 'Poland',
                SCALE_DESCR: 'Millions',
                DATA_SOURCE: 'FDMS*',
                UPDATE_DATE: new Date('2022-06-02'),
                TIMESERIE_DATA: '-0.124,0.1355,0.2345323,n/a,0.0001, 2.4',
            }])

            // when
            const result = await uploadController.getCommoditiesResult(roundSid, storageSid)

            // then
            result.should.be.eql({
                annual: [{
                    timeSerie: [12.4,13.55,23.45323,NaN,0.1],
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'OUTT.6.1.0.0',
                    SCALE_ID: 'MILLION',
                    START_YEAR: 2002,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Millions',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-06-01')
                }],
                quarterly: [{
                    timeSerie: [-0.124,0.1355,0.2345323,NaN,0.0001,2.4],
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'OUTT.6.1.0.0',
                    SCALE_ID: 'MILLION',
                    START_YEAR: 2002,
                    PERIODICITY_ID: 'Q',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Millions',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-06-02')
                }]
            })
            const oil_indicators = ['OILPRC.1.0.99.0', 'OILPRC.1.0.30.0', 'OILPRC.6.0.99.0', 'OILPRC.6.0.30.0']
            sharedServiceStub.getProvidersIndicatorData.firstCall.calledWithExactly(
                ['PRE_PROD'], ['WORLD'], oil_indicators, 'A', false, roundSid, storageSid
            ).should.be.true
            sharedServiceStub.getProvidersIndicatorData.secondCall.calledWithExactly(
                ['PRE_PROD'], ['WORLD'], oil_indicators, 'Q', false, roundSid, storageSid
            ).should.be.true
        })
    })

    describe('uploadIndicatorData method', function() {

        // test data
        const roundSid = 34
        const storageSid = 3
        const providerId = 'AMECO_H'
        const user = 'zelenskyv'
        const data = {
            'BG':{
                'indicatorData':[{
                    'startYear':2019,
                    'indicatorSid':3504,
                    'timeSerie':[
                        1.955800000000007,
                        1.955800000000007,
                        1.955800000000007,
                        1.955800000000007,
                        1.955800000000007
                    ],
                    'scaleSid':1
                }]
            },
            'CZ':{
                'indicatorData':[{
                    'startYear':2019,
                    'indicatorSid':3504,
                    'timeSerie':[
                        25.66927969348657,
                        26.456404580152668,
                        25.64619923371648,
                        24.49456730769219,
                        24.444499999999888
                    ],
                    'scaleSid':1
                }]
            },
            'DK':{
                'indicatorData':[{
                    'startYear':2019,
                    'indicatorSid':3504,
                    'timeSerie':[
                        7.466104214559384,
                        7.454324809160309,
                        7.437049808429125,
                        7.438800423076879,
                        7.4381699999999595
                    ],
                    'scaleSid':1
                }]
            },
            'HR':{
                'indicatorData':[{
                    'startYear':2019,
                    'indicatorSid':3504,
                    'timeSerie':[
                        7.418266283524905,
                        7.538793893129769,
                        7.528822222222222,
                        7.552098038461558,
                        7.554730000000019
                    ],
                    'scaleSid':1
                }]
            },
        }

        // stubs
        let getCountryStatusIdStub
        let getCountryGroupCountriesStub
        let archiveCountryMeasuresStub

        beforeEach(function() {
            getCountryStatusIdStub = sinon.stub(CountryStatusApi, 'getCountryStatusId')
            getCountryGroupCountriesStub = sinon.stub(DashboardApi, 'getCountryGroupCountries')
            archiveCountryMeasuresStub = sinon.stub(DfmApi, 'archiveCountryMeasures')
            uploadController['_countriesToArchive'] = null
        })

        afterEach(function() {
            getCountryStatusIdStub.restore()
            getCountryGroupCountriesStub.restore()
            archiveCountryMeasuresStub.restore()
            uploadServiceStub.uploadFdmsIndData.reset()
            uploadServiceStub.setIndicatorDataUpload.reset()
        })

        // skip active and rejected
        const ctyStatuses = [
            EStatusRepo.OPENED, EStatusRepo.CLOSED, EStatusRepo.SUBMITTED,
            EStatusRepo.ARCHIVED, EStatusRepo.PUBLISHED, EStatusRepo.TR_OPENED, EStatusRepo.TR_SUBMITTED,
            EStatusRepo.TR_PUBLISHED, EStatusRepo.VALIDATED, EStatusRepo.ACCEPTED,
            EStatusRepo.ST_CLOSED,
        ]

        ctyStatuses.forEach(ctyStatus => {
            it(`should return error when cty status is ${ctyStatus}`, async function() {
                // given
                const countryId = 'PL'
                getCountryStatusIdStub.resolves(ctyStatus)

                // when
                const result = await uploadController.uploadIndicatorData(
                    roundSid, storageSid, providerId, [countryId], data, user
                )

                // then
                result.should.be.eql({ 'PL': EErrors.CTY_STATUS })
                getCountryStatusIdStub.calledOnceWithExactly(
                    appId, countryId, {roundSid, storageSid}
                ).should.be.true
            })
        })

        it('should failed all uploads', async function() {
            // given
            getCountryStatusIdStub.resolves(EStatusRepo.ACTIVE)
            uploadServiceStub.uploadFdmsIndData.onCall(0).resolves(-1)
            uploadServiceStub.uploadFdmsIndData.onCall(1).resolves(-2)
            uploadServiceStub.uploadFdmsIndData.onCall(2).resolves(-3)
            uploadServiceStub.uploadFdmsIndData.onCall(3).resolves(-4)

            // when
            const result = await uploadController.uploadIndicatorData(
                roundSid, storageSid, providerId, null, data, user
            )

            // then
            result.should.be.eql({
                'BG': EErrors.IDR_SCALE_INVALID,
                'CZ': EErrors.IDR_SCALE_DIFFERENT,
                'DK': EErrors.ROUND_KEYS,
                'HR': EErrors.IDR_DUPLICATE
            })
        })

        // registerUploadResult < 0 => throw internal error
        it('should throw internal error', async function() {
            // given
            const provider = 'DESK'
            getCountryStatusIdStub.resolves(EStatusRepo.ACTIVE)
            uploadServiceStub.uploadFdmsIndData.resolves(1)
            uploadServiceStub.setIndicatorDataUpload.resolves(-1)

            // when
            let error
            try {
                await uploadController.uploadIndicatorData(
                    roundSid, storageSid, provider, null, data, user
                )
            } catch(err) {
                error = err
            }

            // then
            should().exist(error)
        })

        it('should fails archiving DFM', async function() {
            // given
            const provider = 'DESK'
            const country = 'CZ'
            getCountryStatusIdStub.resolves(EStatusRepo.ACTIVE)
            uploadServiceStub.uploadFdmsIndData.resolves(1)
            uploadServiceStub.setIndicatorDataUpload.resolves(0)
            getCountryGroupCountriesStub.resolves([{ COUNTRY_ID: country }])
            archiveCountryMeasuresStub.resolves({ result: -1})

            // when
            const result = await uploadController.uploadIndicatorData(
                roundSid, storageSid, provider, [country], data, user
            )

            // then
            result.should.be.eql({ 'CZ': -1})
            getCountryGroupCountriesStub.calledOnceWithExactly('EU').should.be.true
            archiveCountryMeasuresStub.calledOnceWithExactly(
                country, user, { roundSid, storageSid }
            ).should.be.true
        })

        it('should upload indicator data', async function() {
            // given
            const provider = 'DESK'
            const countries = ['BG', 'CZ', 'DK', 'HR']

            getCountryStatusIdStub.resolves(EStatusRepo.ACTIVE)
            uploadServiceStub.uploadFdmsIndData.onCall(0).resolves(1)
            uploadServiceStub.uploadFdmsIndData.onCall(1).resolves(2)
            uploadServiceStub.uploadFdmsIndData.onCall(2).resolves(3)
            uploadServiceStub.uploadFdmsIndData.onCall(3).resolves(4)
            uploadServiceStub.setIndicatorDataUpload.resolves(2)
            getCountryGroupCountriesStub.resolves(countries.map(cty => ({COUNTRY_ID: cty})))
            archiveCountryMeasuresStub.resolves({ result: 1})

            // when
            const result = await uploadController.uploadIndicatorData(
                roundSid, storageSid, provider, countries, data, user
            )

            // then
            result.should.be.eql({ 'BG': 1, 'CZ': 2, 'DK': 3, 'HR': 4})
            getCountryGroupCountriesStub.calledWithExactly('EU').should.be.true
        })
    })


    describe('uploadTceDataHandler method', function() {

        // test data
        const roundSid = 432
        const storageSid = 2
        const providerId = 'TCE_GDS'
        const user = 'sparrj'
        const data = [
            {
                expLineNr: 1,
                expCtyId: 'PL',
                partners: [
                    {
                        prtColNr: 1,
                        prtCtyId: 'CZ',
                        value: '1.00022'
                    },
                    {
                        prtColNr: 2,
                        prtCtyId: 'HR',
                        value: '-0.000234'
                    }
                ]
            },
            {
                expLineNr: 2,
                expCtyId: 'BE',
                partners: [
                    {
                        prtColNr: 1,
                        prtCtyId: 'CZ',
                        value: '12.232'
                    },
                    {
                        prtColNr: 2,
                        prtCtyId: 'HR',
                        value: '10.100234'
                    }
                ]
            }
        ]

        after(function() {
            uploadServiceStub.setTceMatrix.reset()
        })

        it('should throw error', async function() {
            // given
            uploadServiceStub.setTceMatrix.resolves(0)

            // when
            let error
            try {
                await uploadController.uploadTceDataHandler(
                    roundSid, storageSid, providerId, data, user
                )
            } catch(err) {
                error = err
            }

            // then
            should().exist(error)
        })

        it('should upload tce data', async function() {
            // given
            uploadServiceStub.setTceMatrix.resolves(2)
            uploadServiceStub.uploadTceMatrixData.resolves({ 'PL': 2, 'BE': 2 })

            // when
            const result = await uploadController.uploadTceDataHandler(
                roundSid, storageSid, providerId, data, user
            )

            // then
            result.should.be.eql({ 'PL': 2, 'BE': 2 })
            uploadServiceStub.uploadTceMatrixData.firstCall.calledWithExactly(
                {
                    matrixSid: 2,
                    expCtyId: 'PL',
                    expLineNr: 1,
                    prntCtyIds: ['CZ','HR'],
                    prntColNrs: [1,2],
                    values: ['1.00022','-0.000234']
                }
            ).should.be.true

            uploadServiceStub.uploadTceMatrixData.secondCall.calledWithExactly(
                {
                    matrixSid: 2,
                    expCtyId: 'BE',
                    expLineNr: 2,
                    prntCtyIds: ['CZ','HR'],
                    prntColNrs: [1,2],
                    values: ['12.232','10.100234']
                }
            ).should.be.true
        })
    })

    describe('getCtyIndicatorScales method', function() {

        after(function() {
            uploadServiceStub.getCtyIndicatorScales.reset()
        })

        it('should return indicators scales', async function() {
            // given
            const providerId = 'ESTAT_Q'
            uploadServiceStub.getCtyIndicatorScales.resolves([
                { CTY_IND: 'PL', SCALE_SID: 2 },
                { CTY_IND: 'BE', SCALE_SID: 3 },
                { CTY_IND: 'FR', SCALE_SID: 2 },
            ])

            // when
            const result = await uploadController.getCtyIndicatorScales(providerId)

            // then
            result.should.be.eql({ 'PL': 2, 'BE': 3, 'FR': 2 })
            uploadServiceStub.getCtyIndicatorScales.calledOnceWithExactly(providerId).should.be.true
        })
    })
})
