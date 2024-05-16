import 'chai/register-should.js'
import * as sinon from 'sinon'

import { BIND_OUT, CURSOR, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { ReportService } from '../../src/report/report.service'
import { SharedService } from '../../src/shared/shared.service'

describe('ReportService test suite', function() {

    let execSPStub
    const appId = EApps.FDMS
    let reportService
    const sharedServiceStub = sinon.createStubInstance(SharedService)

    beforeEach(function() {
        execSPStub = sinon.stub(DataAccessApi, 'execSP')
        // create each time to clear the cache
        reportService = new ReportService(appId, sharedServiceStub)
    })

    afterEach(function() {
        execSPStub.restore()
        reportService = undefined
    })

    describe('getIndicatorsScales method', function() {

        it('should return indicator scales', async function() {
            // given
            const provider = 'PRE_PROD'
            const periodicity = 'M'
            const countries = ['PL', 'CZ']
            const indicators = ['UBLG.1.0.0.0', 'AMDG.1.319.2.0']
            const dbScales = [
                {   INDICATOR_ID: 'UBLG.1.0.0.0',
                    COUNTRY_ID: 'PL',
                    SCALE_ID: 'MILLION',
                    DESCR: 'Millions of national currency',
                    EXPONENT: '9'
                }
            ]
            execSPStub.resolves({ o_cur: dbScales })

            // when
            const results = await reportService.getIndicatorsScales(
                provider, periodicity, countries, indicators
            )

            // then
            results.should.be.eql(dbScales)
            execSPStub.calledWithExactly('fdms_indicator.getIndicatorScales', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_provider_id', type: STRING, value: provider },
                    { name: 'p_periodicity_id', type: STRING, value: periodicity },
                    { name: 'p_indicator_ids', type: STRING, value: indicators },
                    { name: 'p_country_ids', type: STRING, value: countries },
                ],
            }).should.be.true
        })
    })

    describe('getBaseYear method', function() {

        const roundSid = 24

        it('should return base year for specific round', async function() {
            // given
            execSPStub.resolves({ o_year: 2022 })

            // when
            const result = await reportService.getBaseYear(roundSid)

            // then
            result.should.be.eql(2022)
            execSPStub.calledWithExactly('fdms_detailed_table.getBaseYear', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'o_year', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true

            // get cached data
            const cachedResult = await reportService.getBaseYear(roundSid)
            cachedResult.should.be.eql(2022)
            execSPStub.calledOnce.should.be.true
        })

        it('should return base year when round not specified', async function() {
            // given
            execSPStub.resolves({ o_year: 2020 })

            // when
            const result = await reportService.getBaseYear()

            // then
            result.should.be.eql(2020)
            execSPStub.calledWithExactly('fdms_detailed_table.getBaseYear', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: null },
                    { name: 'o_year', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true

            // should not be cached
            const result2 = await reportService.getBaseYear()
            result2.should.be.eql(2020)
            execSPStub.calledTwice.should.be.true
        })
    })

    describe('getCountryTableData method', function() {

        it('should return data successfully', async function() {
            // given
            const countryIds = ['PL', 'BE']
            const roundSid = 28
            const storageSid = 5
            const dbData = [{
                COUNTRY_ID: 'BE',
                INDICATOR_ID: 'UBLG.1.1.0.309',
                SCALE_ID: 'UNIT',
                START_YEAR: 1969,
                PERIODICITY_ID: 'Q',
                COUNTRY_DESCR: 'Belgium',
                SCALE_DESCR: 'Unit',
                DATA_SOURCE: 'FDMS*',
                UPDATE_DATE: new Date('2022-06-07'),
                TIMESERIE_DATA: '1,2.3,2.45,2.443',
            }]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const results = await reportService.getCountryTableData(countryIds, true, roundSid, storageSid, null)

            // then
            results.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_indicator.getCountryTableData', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_country_ids', type: STRING, value: countryIds },
                    { name: 'p_og_full', type: NUMBER, value: 1 },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'p_cust_text_sid', type: NUMBER, value: null },
                ],
            }).should.be.true
        })
    })

    describe('getCtyScale method', function() {

        it('should return country scale', async function () {
            // given
            const countryId = 'PL'
            execSPStub.resolves({ o_scale_id: 'MILLION', o_descr: 'Millions of national currency', o_exponent: 9 })

            // when
            const result = await reportService.getCtyScale(countryId)

            // then
            result.should.be.eql({
                id: 'MILLION',
                name: 'Millions of national currency',
                exponent: 9
            })
            execSPStub.calledWithExactly('fdms_getters.getCtyScale', {
                params: [
                    { name: 'p_country_id', type: STRING, value: countryId },
                    { name: 'o_scale_id', type: STRING, dir: BIND_OUT },
                    { name: 'o_descr', type: STRING, dir: BIND_OUT },
                    { name: 'o_exponent', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true

            // get cached data
            const cached = await reportService.getCtyScale(countryId)
            cached.should.be.eql({
                id: 'MILLION',
                name: 'Millions of national currency',
                exponent: 9
            })
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getDetailedTables method', function() {

        it('should return detailed tables', async function() {
            // given
            const dbData = [{
                TABLE_SID: 13,
                TABLE_ID: 'Table thirteen',
                DESCR: 'Eurostat GDP data',
                FOOTER: 'Eurostat 2022'
            }]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await reportService.getDetailedTables()

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_detailed_table.getTables', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }).should.be.true

            // get cached data
            const cached = await reportService.getDetailedTables()
            cached.should.be.eql(dbData)
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getDetailedTablesData method', function() {

        it('should return data successfully', async function() {
            // given
            const countryIds = ['PT', 'RO']
            const periodicity = 'Q'
            const roundSid = 34
            const storageSid = 2
            const custTextSid = 23
            const dbData = [ {
                COUNTRY_ID: 'PT',
                INDICATOR_ID: 'UBLG.1.0.2.0',
                SCALE_ID: 'UNIT',
                START_YEAR: 1971,
                PERIODICITY_ID: 'Q',
                COUNTRY_DESCR: 'Portugal',
                SCALE_DESCR: 'Unit',
                DATA_SOURCE: 'FDMS*',
                UPDATE_DATE: new Date('2022-05-08'),
                TIMESERIE_DATA: 'N/A,1.23,0.00003,1.0002,n/a,-0.2',
            }]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const results = await reportService.getDetailedTablesData(
                countryIds, periodicity, false, roundSid,  storageSid, custTextSid
            )

            // then
            results.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_indicator.getDetailedTablesData', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_country_ids', type: STRING, value: countryIds },
                    { name: 'p_og_full', type: NUMBER, value: null },
                    { name: 'p_periodicity_id', type: STRING, value: periodicity },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'p_cust_text_sid', type: NUMBER, value: custTextSid },
                ],
            }).should.be.true
        })
    })

    describe('getIndicatorNames method', function() {

        it('should return indicator names', async function() {
            // given
            const indicatorIds = ['UBLE.1.0.3.3', 'JUIS.19.3.3.3']
            const dbData = [
                [ 'UBLE.1.0.3.3', 'Ublge fake indicator' ],
                ['JUIS.19.3.3.3', 'Juis fake indicator' ]
            ]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const results = await reportService.getIndicatorNames(indicatorIds)

            // then
            results.should.be.eql({ 'UBLE.1.0.3.3': 'Ublge fake indicator', 'JUIS.19.3.3.3': 'Juis fake indicator'})
            execSPStub.calledWithExactly('fdms_indicator.getIndicatorNames', {
                params: [
                    { name: 'p_indicator_ids', type: STRING, value: indicatorIds },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
                arrayFormat: true,
            }).should.be.true

            // get cached data
            execSPStub.restore()
            execSPStub = sinon.stub(DataAccessApi, 'execSP')
            // given
            const newIndicatorId = 'YYUQ.1.0.0.319'
            const dbData2 = [
                [ newIndicatorId, 'YYUQ fake indicator - not cached' ],
            ]
            execSPStub.resolves({ o_cur: dbData2 })

            // when
            const results2 = await reportService.getIndicatorNames(indicatorIds.concat(newIndicatorId))

            // then
            results2.should.be.eql({
                'UBLE.1.0.3.3': 'Ublge fake indicator',
                'JUIS.19.3.3.3': 'Juis fake indicator',
                'YYUQ.1.0.0.319': 'YYUQ fake indicator - not cached'
            })
            execSPStub.calledWithExactly('fdms_indicator.getIndicatorNames', {
                params: [
                    { name: 'p_indicator_ids', type: STRING, value: [newIndicatorId] },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
                arrayFormat: true,
            }).should.be.true
        })
    })

    describe('getReportIndicators method', function() {

        it('should return report indicators', async function() {
            // given
            const reportId = 'GDP_DATA'
            const dbData = [ { INDICATOR_ID: 'UBLG.1.0.0.0', INDICATOR_DESCR: 'Gdp data', ORDER_BY: 2 } ]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await reportService.getReportIndicators(reportId)

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_indicator.getReportIndicators', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_report_id', type: STRING, value: reportId },
                ],
            }).should.be.true

            // get cached data
            const cached = await reportService.getReportIndicators(reportId)
            cached.should.be.eql(dbData)
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getProviders method', function() {

        it('should return providers', async function() {
            // given
            const dbData = [
                { PROVIDER_ID: 'ESTAT_M', DESCR: 'Monthly eurostat' },
                { PROVIDER_ID: 'ESTAT_A', DESCR: 'Annual eurostat' },
            ]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result  = await reportService.getProviders()

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_getters.getProviders', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_app_id', type: STRING, value: appId },
                ],
            }).should.be.true

            // get cached data
            const cached  = await reportService.getProviders()
            cached.should.be.eql(dbData)
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getProviderDataLocation method', function() {

        it('should return provider data location', async function() {
            // given
            const providerId = 'PRE_PROD'
            const dbData = 'FDMS_INDICATORS'
            execSPStub.resolves({ o_res: dbData })

            // when
            const result = await reportService.getProviderDataLocation(providerId)

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_getters.getProviderDataLocation', {
                params: [
                    { name: 'p_provider_id', type: STRING, value: providerId },
                    { name: 'o_res', type: STRING, dir: BIND_OUT },
                ],
            }).should.be.true

            // get cached data
            const cached = await reportService.getProviderDataLocation(providerId)
            cached.should.be.eql(dbData)
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getTableCols method', function() {

        it('should return table columns', async function() {
            // given
            const tableSid = 424
            const dbData = [{
                COL_TYPE_ID: 'TEXT',
                DESCR: 'Description',
                YEAR_VALUE: 2019,
                QUARTER: 2,
                USE_CTY_SCALE: 1,
            }]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await reportService.getTableCols(tableSid)

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_detailed_table.getTableCols', {
                params: [
                    { name: 'p_table_sid', type: NUMBER, value: tableSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }).should.be.true

            // get cached data
            const cached = await reportService.getTableCols(tableSid)
            cached.should.be.eql(dbData)
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getTableFooter method', function() {

        it('should return table footer', async function() {
            // given
            const tableSid = 13
            const dbData = [
                {
                    TABLE_SID: 13,
                    TABLE_ID: 'Table thirteen',
                    DESCR: 'Eurostat GDP data',
                    FOOTER: 'Eurostat GDP 2022'
                },
                {
                    TABLE_SID: 14,
                    TABLE_ID: 'Table forteen',
                    DESCR: 'Eurostat HICP data',
                    FOOTER: 'Eurostat Hicp 2022'
                },

            ]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await reportService.getTableFooter(tableSid)

            // then
            result.should.be.eql(dbData[0].FOOTER)
            execSPStub.calledWithExactly('fdms_detailed_table.getTables', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }).should.be.true

            // get cached data
            const cached = await reportService.getTableFooter(tableSid)
            cached.should.be.eql(dbData[0].FOOTER)
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getTableIndicators method', function() {

        it('should return table indicators', async function() {
            // given
            const tableSid = 78
            const dbData = [
                ['A', 'AVGDGP.1.0.0.0'],
                ['A', 'HWCDW.6.1.0.0'],
            ]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await reportService.getTableIndicators(tableSid)

            // then
            result.should.be.eql([ ['A', ['AVGDGP.1.0.0.0', 'HWCDW.6.1.0.0']] ])
            execSPStub.calledWithExactly('fdms_detailed_table.getTableIndicators', {
                params: [
                    { name: 'p_table_sid', type: NUMBER, value: tableSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
                arrayFormat: true,
            }).should.be.true

            // get cached data
            const cached = await reportService.getTableIndicators(tableSid)
            cached.should.be.eql([ ['A', ['AVGDGP.1.0.0.0', 'HWCDW.6.1.0.0']] ])
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getTableLines', function() {

        it('should return table lines', async function() {
            // given
            const tableSid = 79
            const dbData = [{
                LINE_TYPE_ID: 'DATA',
                LINE_ID: '1',
                DESCR: 'Effective (% change)',
                ESA_CODE: 'XXX',
                LINE_SPAN: 1,
                COL_TYPE_SPAN: 'PPP',
                SPAN_YEARS_OFFSET: 2,
                DATA: 'XUNNQ.6.0.30.437',
                ALT_DATA: 'ALT data',
                ALT2_DATA: 'alt line 2',
                USE_CTY_SCALE: 1,
                STYLES: 'italic'
            }]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await reportService.getTableLines(tableSid)

            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_detailed_table.getTableLines', {
                params: [
                    { name: 'p_table_sid', type: NUMBER, value: tableSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }).should.be.true

            // get cached data
            const cached = await reportService.getTableLines(tableSid)
            cached.should.be.eql(dbData)
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getIndicatorCountries', function() {

        it('should return indicator countries', async function() {
            // given
            const dbData = [
                {
                    CODEISO3: 'EU13',
                    CODE_FGD: null,
                    COUNTRY_ID: 'EU13',
                    DESCR: 'EU13 countries'
                },
                {
                    CODEISO3: 'BFA',
                    CODE_FGD: 2,
                    COUNTRY_ID: 'BF',
                    DESCR: 'Burkina Faso'
                },
            ]
            execSPStub.resolves({ o_cur: dbData })

            // when
            const result = await reportService.getIndicatorCountries()

            // then
            result.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_getters.getIndicatorGeoAreas', {
                params: [
                    { name: 'p_app_id', type: STRING, value: appId },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }).should.be.true

            // get cached data
            const cached = await reportService.getIndicatorCountries()
            cached.should.be.eql(dbData)
            execSPStub.calledOnce.should.be.true
        })
    })

    describe('getProviderData method', function() {

        it('should return indicator data', async function() {
            // given
            const providerId = 'PRE_PROD'
            const periodicity = 'A'
            const roundSid = 34
            const storageSid = 3
            const custTextSid = 2
            const countryIds = ['PL', 'BE']
            const indicatorIds = ['CIST.1.0.0.0', 'OIGT.1.1.0.0']

            const dbData = [
                {
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'CIST.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1996,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS_INDICATOR_DATA',
                    UPDATE_DATE: new Date('2023-09-11'),
                    TIMESERIE_DATA: [1.12, 1.13, 1.14]
                }
            ]

            sharedServiceStub.getCompressedIndicatorsData.resolves(dbData)

            // when
            const result = await reportService.getProviderData(
                providerId, countryIds, indicatorIds, periodicity, roundSid, storageSid, custTextSid
            )

            // then
            result.should.be.eql(dbData)
            sharedServiceStub.getCompressedIndicatorsData.calledOnceWithExactly(
                [providerId], countryIds, indicatorIds, periodicity, roundSid, storageSid, custTextSid, undefined
            )
            sharedServiceStub.getCompressedIndicatorsData.reset()
        })
    })

})
