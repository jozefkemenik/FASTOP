import 'chai/register-should.js'
import * as sinon from 'sinon'

import { DashboardApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { SharedService } from '../../src/shared/shared.service'
import { WebQueryController } from '../../src/web-query/web-query.controller'

describe('WebQueryController test suite', function() {

    const appId = EApps.FDMS
    const sharedServiceStub = sinon.createStubInstance(SharedService)
    const webQueryController = new WebQueryController(appId, sharedServiceStub)

    describe('getProviderIndicators method', function() {

        // test data
        const roundInfo = {
            roundSid: 321,
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
            version: 3,
        }

        // stubs
        let getCountryGroupCountriesStub
        let getCurrentRoundInfoStub

        beforeEach(function() {
            getCountryGroupCountriesStub = sinon.stub(DashboardApi, 'getCountryGroupCountries')
            getCurrentRoundInfoStub = sinon.stub(DashboardApi, 'getCurrentRoundInfo').resolves(roundInfo)
        })

        afterEach(function() {
            getCountryGroupCountriesStub.restore()
            getCurrentRoundInfoStub.restore()
            sharedServiceStub.getTceData.reset()
            sharedServiceStub.getProvidersIndicatorData.reset()
        })

        it('should return empty result when no countries provided', async function() {
            // given
            const params = {
                countryIds: [],
                ctyGroup: null,
                yearsRange: [],
                periodicity: 'A'
            }

            // when
            const result = await webQueryController.getProviderIndicators(params)

            // then
            result.should.be.eql({startYear: 0, vectorLength: -1, indicators: []})
            getCountryGroupCountriesStub.called.should.be.false
        })

        it('should return empty result when no countries for given country group', async function() {
            // given
            const params = {
                countryIds: undefined,
                ctyGroup: 'ABC',
                yearsRange: [],
                periodicity: 'A'
            }
            getCountryGroupCountriesStub.resolves([])

            // when
            const result = await webQueryController.getProviderIndicators(params)

            // then
            result.should.be.eql({startYear: 0, vectorLength: -1, indicators: []})
            getCountryGroupCountriesStub.calledOnceWithExactly('ABC').should.be.true
        })

        it('should return TCE data', async function() {
            // given
            const params = {
                countryIds: ['PL', 'BE'],
                ctyGroup: null,
                yearsRange: [-1,4],
                periodicity: 'A',
                providerId: 'TCE_RSLTS',
                indicatorIds: ['FETD9.6.0.0.0', 'HWCDW.6.1.0.0'],
                roundSid: 320,
                storageSid: 3,
            }
            sharedServiceStub.getTceData.resolves([
                {
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'HWCDW.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2020,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS+',
                    DATA_TYPE: 'WE',
                    UPDATE_DATE: new Date('2022-06-02'),
                    TIMESERIE_DATA: '0.1,0.2,0.3,0.4,0.5,,0.61234',
                },
                {
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'HWCDW.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2020,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS+',
                    DATA_TYPE: 'EU',
                    UPDATE_DATE: new Date('2022-06-01'),
                    TIMESERIE_DATA: '1.1,1.2,1.3,1.4,1.5,,1.61234',
                },
                {
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'FETD9.6.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2019,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS+',
                    DATA_TYPE: 'W',
                    UPDATE_DATE: new Date('2022-05-22'),
                    TIMESERIE_DATA: '-0.01,-0.02,-0.03,-0.04,-0.05,n/a,-0.061234',
                },
                {
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'FETD9.6.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2019,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS+',
                    DATA_TYPE: 'T',
                    UPDATE_DATE: new Date('2022-05-24'),
                    TIMESERIE_DATA: '10.1,10.2,10.3,10.4,10.5,#N/A,10.61234',
                },
            ])

            // when
            const result = await webQueryController.getProviderIndicators(params)

            // then
            result.should.be.eql({
                startYear: 2021,
                vectorLength: 6,
                indicators: [
                    {
                        indicatorId: 'HWCDW.6.1.0.0',
                        scale: 'UNIT',
                        countryId: 'PL',
                        dataType: 'EU',
                        vector: [1.2,1.3,1.4,1.5,NaN,1.61234],
                        updateDate: new Date('2022-06-01')
                    },
                    {
                        indicatorId: 'FETD9.6.0.0.0',
                        scale: 'UNIT',
                        countryId: 'PL',
                        dataType: 'T',
                        vector: [10.3,10.4,10.5,NaN,10.61234,NaN],
                        updateDate: new Date('2022-05-24')
                    },
                    {
                        indicatorId: 'HWCDW.6.1.0.0',
                        scale: 'UNIT',
                        countryId: 'BE',
                        dataType: 'WE',
                        vector: [0.2,0.3,0.4,0.5,NaN,0.61234],
                        updateDate: new Date('2022-06-02')
                    },
                    {
                        indicatorId: 'FETD9.6.0.0.0',
                        scale: 'UNIT',
                        countryId: 'BE',
                        dataType: 'W',
                        vector: [-0.03,-0.04,-0.05,NaN,-0.061234,NaN],
                        updateDate: new Date('2022-05-22')
                    }
                ]}
            )
            sharedServiceStub.getTceData.calledOnceWithExactly(
                params.countryIds, params.indicatorIds, undefined, params.periodicity, params.roundSid, params.storageSid
            ).should.be.true
            sharedServiceStub.getProvidersIndicatorData.called.should.be.false
        })

        it('should return fdms indicator data', async function() {
            // given
            const params = {
                countryIds: ['FR', 'BE'],
                ctyGroup: null,
                yearsRange: [-1,1],
                periodicity: 'Q',
                providerId: 'PRE_PROD',
                indicatorIds: ['FETD9.6.0.0.0', 'HWCDW.6.1.0.0'],
            }
            sharedServiceStub.getProvidersIndicatorData.resolves([
                {
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'HWCDW.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2022,
                    PERIODICITY_ID: 'Q',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS+',
                    UPDATE_DATE: new Date('2022-06-02'),
                    TIMESERIE_DATA: '0.1,0.2,0.3,0.4,0.5,,0.61234,0.76',
                },
                {
                    COUNTRY_ID: 'FR',
                    INDICATOR_ID: 'HWCDW.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2022,
                    PERIODICITY_ID: 'Q',
                    COUNTRY_DESCR: 'France',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS+',
                    UPDATE_DATE: new Date('2022-06-01'),
                    TIMESERIE_DATA: '1.1,1.2,1.3,1.4,1.5,,1.61234,1.7788',
                },
                {
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'FETD9.6.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2022,
                    PERIODICITY_ID: 'Q',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS+',
                    UPDATE_DATE: new Date('2022-05-22'),
                    TIMESERIE_DATA: '-0.01,-0.02,-0.03,-0.04,-0.05,n/a,-0.061234,-0.7863',
                },
                {
                    COUNTRY_ID: 'FR',
                    INDICATOR_ID: 'FETD9.6.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2022,
                    PERIODICITY_ID: 'Q',
                    COUNTRY_DESCR: 'France',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS+',
                    UPDATE_DATE: new Date('2022-05-24'),
                    TIMESERIE_DATA: '10.1,10.2,10.3,10.4,10.5,#N/A,10.61234,11.333',
                },
            ])

            // when
            const result = await webQueryController.getProviderIndicators(params)

            // then
            result.should.be.eql({
                startYear: 2021,
                vectorLength: 12,
                indicators: [
                    {
                        indicatorId: 'HWCDW.6.1.0.0',
                        scale: 'UNIT',
                        countryId: 'FR',
                        dataType: undefined,
                        vector: [NaN,NaN,NaN,NaN,1.1,1.2,1.3,1.4,1.5,NaN,1.61234,1.7788],
                        updateDate: new Date('2022-06-01')
                    },
                    {
                        indicatorId: 'FETD9.6.0.0.0',
                        scale: 'UNIT',
                        countryId: 'FR',
                        dataType: undefined,
                        vector: [NaN,NaN,NaN,NaN,10.1,10.2,10.3,10.4,10.5,NaN,10.61234,11.333],
                        updateDate: new Date('2022-05-24')
                    },
                    {
                        indicatorId: 'HWCDW.6.1.0.0',
                        scale: 'UNIT',
                        countryId: 'BE',
                        dataType: undefined,
                        vector: [NaN,NaN,NaN,NaN,0.1,0.2,0.3,0.4,0.5,NaN,0.61234,0.76],
                        updateDate: new Date('2022-06-02')
                    },
                    {
                        indicatorId: 'FETD9.6.0.0.0',
                        scale: 'UNIT',
                        countryId: 'BE',
                        dataType: undefined,
                        vector: [NaN,NaN,NaN,NaN,-0.01,-0.02,-0.03,-0.04,-0.05,NaN,-0.061234,-0.7863],
                        updateDate: new Date('2022-05-22')
                    }
                ]}
            )
            sharedServiceStub.getProvidersIndicatorData.calledOnceWithExactly(
                [params.providerId], params.countryIds, params.indicatorIds, params.periodicity, null,
                roundInfo.roundSid, roundInfo.storageSid
            ).should.be.true
            sharedServiceStub.getTceData.called.should.be.false
        })
    })
})
