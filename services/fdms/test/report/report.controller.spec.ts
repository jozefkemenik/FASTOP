import 'chai/register-should.js'
import * as sinon from 'sinon'
import { should } from 'chai'

import { EApps } from 'config'
import { ETasks } from 'task'
import { IIndicatorData } from '../../src/report/shared-interfaces'
import { LoggingService } from '../../../lib/dist'
import { ProviderDataLocation } from '../../src/report'
import { ReportController } from '../../src/report/report.controller'
import { ReportService } from '../../src/report/report.service'
import { RequestService } from '../../../lib/dist/request.service'
import { SharedService } from '../../src/shared/shared.service'
import { TaskApi } from '../../../lib/dist/api/task.api'
import { TceService } from '../../src/report/tce/tce.service'

describe('ReportController test suite', function() {

    const appId = EApps.FDMS
    const reportServiceStub = sinon.createStubInstance(ReportService)
    const tceServiceStub = sinon.createStubInstance(TceService)
    const sharedServiceStub = sinon.createStubInstance(SharedService)
    const loggingServiceStub = sinon.createStubInstance(LoggingService)

    const reportController = new ReportController(
        appId, reportServiceStub, tceServiceStub, loggingServiceStub, sharedServiceStub
    )

    describe('getCountryTable method', function() {

        // test data
        const roundSid = 322
        const storageSid = 4
        const countryId = 'PL'

        // stubs
        let requestStub

        beforeEach(function() {
            requestStub = sinon.stub(RequestService, 'request')
        })

        afterEach(function() {
            requestStub.restore()
        })

        it('should call fdms', async function() {
            // given
            const tableData = {
                header: [
                    [{ header: 'ABC', colSpan: 1 }, { header: 'XXX' }],
                    [{ header: 'UUU', rowSpan: 3}, { header: 'PPP', rowSpan: 3 }],
                ],
                data: [[
                    { values: ['Ala', 'Ola', 'Jola'], colSpans: 2, rowType: 'TEXT', styles: 'italic', indicators: ['ILN.1.1.0.0']}
                ],],
                dataColumnOffset: 2,
                tableNumber: 'T12.3',
                title: 'Summary data',
                footer: 'Detailed info'
            }
            requestStub.resolves(tableData)
            sharedServiceStub.isOgFull.resolves(true)

            // when
            const result = await reportController.getCountryTable(ETasks.VALIDATION, roundSid, storageSid, countryId)

            // then
            result.should.be.eql(Object.assign({}, tableData, { ogFull: true }))
            requestStub.calledOnceWithExactly(
                EApps.FDMSSTAR, `/reports/countryTable/${countryId}/${roundSid}/${storageSid}`
            ).should.be.true
            sharedServiceStub.isOgFull.calledOnceWithExactly(countryId, roundSid, storageSid).should.be.true

            sharedServiceStub.isOgFull.reset()
        })

        it('should call fdmsie', async function() {
            // given
            const tableData = {
                header: [
                    [{ header: 'ABC', colSpan: 1 }, { header: 'XXX' }],
                    [{ header: 'UUU', rowSpan: 3}, { header: 'PPP', rowSpan: 3 }],
                ],
                data: [[
                    { values: ['Ala', 'Ola', 'Jola'], colSpans: 2, rowType: 'TEXT', styles: 'italic', indicators: ['ILN.1.1.0.0']}
                ],],
                dataColumnOffset: 2,
                tableNumber: 'T12.3',
                title: 'Summary data',
                footer: 'Detailed info'
            }
            requestStub.resolves(tableData)
            sharedServiceStub.isOgFull.resolves(false)
            const fdmsieReportController = new ReportController(
                EApps.FDMSIE, reportServiceStub, tceServiceStub, loggingServiceStub, sharedServiceStub
            )

            // when
            const result = await fdmsieReportController.getCountryTable(ETasks.VALIDATION, roundSid, storageSid, countryId)

            // then
            result.should.be.eql(Object.assign({}, tableData, { ogFull: false }))
            requestStub.calledOnceWithExactly(
                EApps.FDMSSTAR, `/reports/countryTable/${countryId}/${roundSid}/${storageSid}?ie=true`
            ).should.be.true
            sharedServiceStub.isOgFull.calledOnceWithExactly(countryId, roundSid, storageSid).should.be.true

            sharedServiceStub.isOgFull.reset()
        })
    })

    describe('getCountryTableData method', function() {

        afterEach(function() {
            reportServiceStub.getCountryTableData.reset()
        })

        it('should return country table data', async function() {
            // given
            const countryId = 'CZ'
            const roundSid = 234
            const storageSid = 4
            const custTextSid = 3

            reportServiceStub.getCountryTableData.resolves([
                {
                    COUNTRY_ID: 'CZ',
                    INDICATOR_ID: 'PLCD.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1996,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Czech republic',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS+',
                    UPDATE_DATE: new Date('2022-04-18'),
                    TIMESERIE_DATA: '-0.2,0.3,0.5,,1.002',
                }
            ])

            // when
            const result = await reportController.getCountryTableData(countryId, roundSid, storageSid, custTextSid)

            // then
            result.should.be.eql([{
                TIMESERIE_DATA: [-0.2,0.3,0.5,NaN,1.002],
                COUNTRY_ID: 'CZ',
                INDICATOR_ID: 'PLCD.6.1.0.0',
                SCALE_ID: 'UNIT',
                START_YEAR: 1996,
                PERIODICITY_ID: 'A',
                COUNTRY_DESCR: 'Czech republic',
                SCALE_DESCR: 'Units',
                DATA_SOURCE: 'FDMS+',
                UPDATE_DATE: new Date('2022-04-18')
            }])
            reportServiceStub.getCountryTableData.calledOnceWithExactly(
                [countryId], null, roundSid, storageSid, custTextSid
            ).should.be.true
        })
    })

    describe('getDetailedTable method', function() {

        afterEach(function() {
            reportServiceStub.getCtyScale.reset()
            reportServiceStub.getBaseYear.reset()
            reportServiceStub.getTableCols.reset()
            reportServiceStub.getTableLines.reset()
            reportServiceStub.getTableFooter.reset()
            reportServiceStub.getTableIndicators.reset()
            sharedServiceStub.getProvidersIndicatorData.reset()
            sharedServiceStub.isOgFull.reset()
        })

        it('should return detailed table', async function() {
            // given
            const tableSid = 24
            const countryId = 'PL'
            const roundSid = 53
            const storageSid = 4
            reportServiceStub.getCtyScale.resolves({ id: 'MILLION', name: 'Millions', exponent: 9 })
            reportServiceStub.getBaseYear.resolves(2020)
            reportServiceStub.getTableCols.resolves([
                { COL_TYPE_ID: 'CODE', DESCR: 'ESA 2010 code', YEAR_VALUE: null, QUARTER: null, USE_CTY_SCALE: null },
                { COL_TYPE_ID: 'ALT_DATA', DESCR: 'Alt data', YEAR_VALUE: -2, QUARTER: null, USE_CTY_SCALE: 1 },
                { COL_TYPE_ID: 'ALT_DATA2', DESCR: 'Alt data2', YEAR_VALUE: -1, QUARTER: null, USE_CTY_SCALE: 0 },
                { COL_TYPE_ID: 'DATA', DESCR: 'Primary data', YEAR_VALUE: -1, QUARTER: null, USE_CTY_SCALE: null },
                { COL_TYPE_ID: 'DATA', DESCR: 'I', YEAR_VALUE: 0, QUARTER: 1, USE_CTY_SCALE: null },
                { COL_TYPE_ID: 'DATA', DESCR: 'I', YEAR_VALUE: 1, QUARTER: 1, USE_CTY_SCALE: null },
            ])
            reportServiceStub.getTableLines.resolves([
                {
                    LINE_TYPE_ID: 'YEAR',
                    LINE_ID: null,
                    DESCR: null,
                    ESA_CODE: null,
                    LINE_SPAN: 2,
                    COL_TYPE_SPAN: null,
                    SPAN_YEARS_OFFSET: null,
                    DATA: null,
                    ALT_DATA: null,
                    ALT2_DATA: null,
                    USE_CTY_SCALE: null,
                    STYLES: null,
                },
                {
                    LINE_TYPE_ID: 'HEADER',
                    LINE_ID: null,
                    DESCR: null,
                    ESA_CODE: null,
                    LINE_SPAN: 1,
                    COL_TYPE_SPAN: null,
                    SPAN_YEARS_OFFSET: null,
                    DATA: '% change',
                    ALT_DATA: 'Level',
                    ALT2_DATA: '% trade',
                    USE_CTY_SCALE: null,
                    STYLES: null,
                },
                {
                    LINE_TYPE_ID: 'DATA',
                    LINE_ID: '1',
                    DESCR: 'Private consumption expenditure',
                    ESA_CODE: 'P3',
                    LINE_SPAN: 1,
                    COL_TYPE_SPAN: null,
                    SPAN_YEARS_OFFSET: null,
                    DATA: 'AVGDGP.1.0.0.0',
                    ALT_DATA: 'AVGDGP.1.0.0.0',
                    ALT2_DATA: 'AVGDGP.1.0.0.0',
                    USE_CTY_SCALE: 1,
                    STYLES: null,
                },
                {
                    LINE_TYPE_ID: 'DATA',
                    LINE_ID: '2',
                    DESCR: 'Government consumption expenditure',
                    ESA_CODE: 'P3',
                    LINE_SPAN: 1,
                    COL_TYPE_SPAN: null,
                    SPAN_YEARS_OFFSET: null,
                    DATA: 'OCTG.6.1.0.0',
                    ALT_DATA: 'OCTG.1.1.0.0',
                    ALT2_DATA: 'OCTG.1.1.0.0',
                    USE_CTY_SCALE: 1,
                    STYLES: null,
                },
                {
                    LINE_TYPE_ID: 'HEADER',
                    LINE_ID: null,
                    DESCR: null,
                    ESA_CODE: null,
                    LINE_SPAN: 1,
                    COL_TYPE_SPAN: null,
                    SPAN_YEARS_OFFSET: null,
                    DATA: null,
                    ALT_DATA: null,
                    ALT2_DATA: null,
                    USE_CTY_SCALE: null,
                    STYLES: null,
                },
                {
                    LINE_TYPE_ID: 'DATA',
                    LINE_ID: '5',
                    DESCR: 'Change in inventories + net acquisition of valuable as % of GDP',
                    ESA_CODE: 'P52+P53',
                    LINE_SPAN: 1,
                    COL_TYPE_SPAN: null,
                    SPAN_YEARS_OFFSET: null,
                    DATA: 'HWCDW.6.1.0.0',
                    ALT_DATA: 'HWCDW.6.1.0.0',
                    ALT2_DATA: null,
                    USE_CTY_SCALE: 1,
                    STYLES: null,
                },
            ])
            reportServiceStub.getTableFooter.resolves('End of data')
            const indicators = ['AVGDGP.1.0.0.0', 'HWCDW.6.1.0.0', 'OCTG.1.1.0.0']
            reportServiceStub.getTableIndicators.resolves([ ['A', indicators] ])
            sharedServiceStub.getProvidersIndicatorData.resolves([
                {
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'AVGDGP.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23'),
                    // eslint-disable-next-line max-len
                    TIMESERIE_DATA: '-1.149242957,0.816327897,2.370429442,1.568514632,1.632238388,1.46699523',
                },
                {
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'HWCDW.6.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23'),
                    // eslint-disable-next-line max-len
                    TIMESERIE_DATA: '56.77088731416029,31.461901726716015,41.30896773074277,34.07715717122106,27.250909223613107,20.53306704318889',
                },
                {
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'OCTG.1.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23'),
                    // eslint-disable-next-line max-len
                    TIMESERIE_DATA: '141165826500.0,154678050000.0,163745487200.0,167656832300.0,169656325500.0,177791000000.0',
                },
            ])
            sharedServiceStub.isOgFull.resolves(true)

            // when
            const result = await reportController.getDetailedTable(
                tableSid, countryId, roundSid, storageSid
            )

            // then
            result.should.be.eql({
                header: [
                    [
                        { header: 'index', colSpan: 2, rowSpan: 2 },
                        { header: 'ESA 2010 code', colSpan: 1, rowSpan: 2 },
                        { header: '2018', colSpan: 1 },
                        { header: '2019', colSpan: 2 },
                        { header: '2020', colSpan: 1 },
                        { header: '2021', colSpan: 1 }
                    ],
                    [
                        { header: '', colSpan: 0 },
                        { header: '', colSpan: 1 },
                        { header: '', colSpan: 1 },
                        { header: '', colSpan: 1 },
                        { header: '', colSpan: 1 },
                        { header: '', colSpan: 1 },
                    ],
                ],
                data: [
                    {
                        // eslint-disable-next-line max-len
                        values: ['1','Private consumption expenditure','P3',8.163278969999999e-10,2.370429442,1.568514632,1.632238388],
                        colSpans: [1,1,1,1],
                        rowType: 'DATA',
                        styles: null,
                        indicators: [' AVGDGP.1.0.0.0']
                    },
                    {
                        values: ['2','Government consumption expenditure','P3',154.67805,'','',''],
                        colSpans: [1,1,1,1],
                        rowType: 'DATA',
                        styles: null,
                        indicators: [' OCTG.1.1.0.0',' OCTG.6.1.0.0']
                    },

                    {
                        values: [null,undefined,null,null],
                        colSpans: [4],
                        rowType: 'HEADER',
                        styles: null,
                        indicators: undefined
                    },
                    {
                        // eslint-disable-next-line max-len
                        values: ['5','Change in inventories + net acquisition of valuable as % of GDP','P52+P53',3.146190172671601e-8,41.30896773074277,34.07715717122106,27.250909223613107],
                        colSpans: [1,1,1,1],
                        rowType: 'DATA',
                        styles: null,
                        indicators: [' HWCDW.6.1.0.0']
                    },
                ],
                dataColumnOffset: 3,
                footer: 'End of data',
                ogFull: true
            })

            reportServiceStub.getCtyScale.calledOnceWithExactly(countryId).should.be.true
            reportServiceStub.getBaseYear.calledOnceWithExactly(roundSid).should.be.true
            reportServiceStub.getTableCols.calledOnceWithExactly(tableSid).should.be.true
            reportServiceStub.getTableLines.calledWithExactly(tableSid).should.be.true
            reportServiceStub.getTableFooter.calledWithExactly(tableSid).should.be.true
            reportServiceStub.getTableIndicators.calledOnceWithExactly(tableSid).should.be.true
            sharedServiceStub.getProvidersIndicatorData.calledWithExactly(
                ['PRE_PROD'], [countryId], indicators, 'A', null, roundSid, storageSid
            ).should.be.true
            sharedServiceStub.isOgFull.calledOnceWithExactly(countryId, roundSid, storageSid).should.be.true
        })
    })

    describe('getDetailedTablesData method', function() {

        afterEach(function() {
            reportServiceStub.getDetailedTablesData.reset()
        })

        it('should return detailed tables data', async function() {
            // given
            const countryId = 'IT'
            const periodicity = 'M'
            const roundSid = 34
            const storageSid = 1
            const custTextSid = 2
            reportServiceStub.getDetailedTablesData.resolves([{
                COUNTRY_ID: 'IT',
                INDICATOR_ID: 'PLCD.6.1.0.0',
                SCALE_ID: 'UNIT',
                START_YEAR: 2022,
                PERIODICITY_ID: 'M',
                COUNTRY_DESCR: 'Italy',
                SCALE_DESCR: 'Units',
                DATA_SOURCE: 'FDMS+',
                UPDATE_DATE: new Date('2022-05-11'),
                TIMESERIE_DATA: '-0.2,0.3,0.5,NaN,1.002',
            }])

            // when
            const result = await reportController.getDetailedTablesData(
                countryId, periodicity, roundSid, storageSid, custTextSid
            )

            // then
            result.should.be.eql([{
                TIMESERIE_DATA: [-0.2,0.3,0.5,NaN,1.002],
                COUNTRY_ID: 'IT',
                INDICATOR_ID: 'PLCD.6.1.0.0',
                SCALE_ID: 'UNIT',
                START_YEAR: 2022,
                PERIODICITY_ID: 'M',
                COUNTRY_DESCR: 'Italy',
                SCALE_DESCR: 'Units',
                DATA_SOURCE: 'FDMS+',
                UPDATE_DATE: new Date('2022-05-11')
            }])
            reportServiceStub.getDetailedTablesData.calledOnceWithExactly(
                [countryId], periodicity, null, roundSid, storageSid, custTextSid
            ).should.be.true
        })

    })

    describe('getProviderData method', function() {

        // test data
        const providerId = 'PRE_PROD'
        const periodicity = 'A'
        const roundSid = 34
        const storageSid = 3
        const custTextSid = 2
        const countryIds = ['PL', 'BE']
        const indicatorIds = ['CIST.1.0.0.0', 'OIGT.1.1.0.0']

        afterEach(function() {
            sharedServiceStub.getProvidersIndicatorData.reset()
        })

        it('should return indicator data', async function() {
            // given
            reportServiceStub.getProviderData.resolves([
                {
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'CIST.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23'),
                    // eslint-disable-next-line max-len
                    TIMESERIE_DATA: [-1.149242957,0.816327897,2.370429442,1.568514632,1.632238388,1.46699523],
                },
                {
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'OIGT.1.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23'),
                    // eslint-disable-next-line max-len
                    TIMESERIE_DATA: [56.77088731416029,31.461901726716015,41.30896773074277,34.07715717122106,27.250909223613107,20.53306704318889],
                },
                {
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'CIST.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23'),
                    // eslint-disable-next-line max-len
                    TIMESERIE_DATA: [141165826500.0,154678050000.0,163745487200.0,167656832300.0,169656325500.0,177791000000.0],
                },
                {
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'OIGT.1.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23'),
                    // eslint-disable-next-line max-len
                    TIMESERIE_DATA: [22354996710.0,25118770990.0,26595713670.0,26635113500.0,30541207410.0,31800624440.0],
                },
            ])
            reportServiceStub.getProviderDataLocation.resolves(ProviderDataLocation.INDICATOR_DATA)

            // when
            const result = await reportController.getProviderData(
                providerId, periodicity, roundSid, storageSid, custTextSid, countryIds, indicatorIds, false
            )

            // then
            result.should.be.eql([
                {
                    TIMESERIE_DATA: [-1.149242957,0.816327897,2.370429442,1.568514632,1.632238388,1.46699523],
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'CIST.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23')
                },
                {
                    // eslint-disable-next-line max-len
                    TIMESERIE_DATA: [56.77088731416029,31.461901726716015,41.30896773074277,34.07715717122106,27.250909223613107,20.53306704318889],
                    COUNTRY_ID: 'PL',
                    INDICATOR_ID: 'OIGT.1.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Poland',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23')
                },
                {
                    TIMESERIE_DATA: [141165826500,154678050000,163745487200,167656832300,169656325500,177791000000],
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'CIST.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23')
                },
                {
                    TIMESERIE_DATA: [22354996710,25118770990,26595713670,26635113500,30541207410,31800624440],
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'OIGT.1.1.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2017,
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Units',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-05-23')
                }]
            )
            reportServiceStub.getProviderData.calledOnceWithExactly(
                providerId, countryIds, indicatorIds, periodicity, roundSid, storageSid, custTextSid,  false,
            ).should.be.true
        })

        it('should throw error for unknown data location', async function() {
            // given
            const provider = 'AAAX'
            reportServiceStub.getProviderDataLocation.resolves('XXX')

            // when
            let error
            try {
                await reportController.getProviderData(
                    provider, periodicity, roundSid, storageSid, custTextSid, countryIds, indicatorIds,
                )
            } catch(err) {
                error = err
            }

            // then
            should().exist(error)
            reportServiceStub.getProviderDataLocation.calledWithExactly(provider).should.be.true
        })

        it('should return tce data', async function() {
            // given
            const provider = 'TCE_RSLTS'
            reportServiceStub.getProviderDataLocation.resolves(ProviderDataLocation.TCE_RESULTS_DATA)
            const dbData: IIndicatorData[] = [
                {
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'OXGN.6.0.30.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 2019,
                    TIMESERIE_DATA: [12.570123050037836,1.7740586503079463,0.6998746878309313,4.306924692364062],
                    PERIODICITY_ID: 'A',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Units',
                    UPDATE_DATE: new Date('2022-02-03'),
                    DATA_SOURCE: 'TCE Calculation',
                    DATA_TYPE: 'EU',
                },
            ]
            tceServiceStub.getTceResultsData.resolves(dbData)

            // when
            const result = await reportController.getProviderData(
                provider, periodicity, roundSid, storageSid, custTextSid, countryIds, indicatorIds,
            )

            // then
            result.should.be.eql(dbData)
            reportServiceStub.getProviderDataLocation.calledWithExactly(provider).should.be.true
            tceServiceStub.getTceResultsData.calledOnceWithExactly(
                countryIds, indicatorIds, undefined, periodicity, roundSid, storageSid, undefined
            ).should.be.true
            tceServiceStub.getTceResultsData.reset()

        })
    })

    describe('getValidationStepDetails method', function() {

        // stubs
        let getValidationStepStub

        beforeEach(function() {
            getValidationStepStub = sinon.stub(TaskApi, 'getValidationStep')
        })

        afterEach(function() {
            getValidationStepStub.restore()
            reportServiceStub.getIndicatorNames.reset()
        })

        it('should return validation step details', async function() {
            // given
            const countryId = 'PL'
            const step = 2
            const roundSid = 34
            const storageSid = 6

            const stepDetails = [
                {
                    INDICATOR_ID: 'OXGN.6.0.30.0',
                    DESCR: 'Step 1',
                    LABELS: 'ABC',
                    ACTUAL: '0.002',
                    VALIDATION1: '0.0001',
                    VALIDATION2: '-0.0001',
                    FAILED: 'true',
                },
                {
                    INDICATOR_ID: 'OXGN.6.0.30.998',
                    DESCR: 'Step 1.1',
                    LABELS: 'My label',
                    ACTUAL: '1.002',
                    VALIDATION1: '-0.01',
                    VALIDATION2: '0.01',
                    FAILED: 'false',
                },
            ]
            getValidationStepStub.resolves(stepDetails)
            reportServiceStub.getIndicatorNames.resolves({
                'OXGN.6.0.30.0': 'Tce indicator 1',
                'OXGN.6.0.30.998': 'Tce indicator 2'
            })

            // when
            const result = await reportController.getValidationStepDetails(countryId, step, roundSid, storageSid)

            // then
            result.should.be.eql([
                {
                    indicatorId: 'OXGN.6.0.30.0',
                    indicatorName: 'Tce indicator 1',
                    labels: ['ABC'],
                    actual: [0.002],
                    validation1: [0.0001],
                    validation2: [ -0.0001],
                    failed: [false]
                },
                {
                    indicatorId: 'OXGN.6.0.30.998',
                    indicatorName: 'Tce indicator 2',
                    labels: ['My label'],
                    actual: [1.002],
                    validation1: [-0.01],
                    validation2: [0.01],
                    failed: [false]
                }
            ])
            getValidationStepStub.calledOnceWithExactly(
                appId, step, countryId, {roundSid, storageSid}
            ).should.be.true
            reportServiceStub.getIndicatorNames.calledWithExactly(
                stepDetails.map(sd => sd.INDICATOR_ID)
            ).should.be.true
        })

    })

    describe('getValidationTable method', function() {

        let requestStub
        let getCtyTaskExceptionsStub

        beforeEach(function() {
            requestStub = sinon.stub(RequestService, 'request')
            getCtyTaskExceptionsStub = sinon.stub(TaskApi, 'getCtyTaskExceptions')
        })

        afterEach(function() {
            requestStub.restore()
            getCtyTaskExceptionsStub.restore()
        })

        it('should return validation table', async function() {
            // given
            const countryId = 'PL'
            const roundSid = 32
            const storageSid = 1
            requestStub.resolves({
                // eslint-disable-next-line max-len
                header: ['Type', 'Identifier', 'No.', 'Validation rule', 'Description', 'Number of Exceptions', 'Severity', 'Formula', 'Target data', 'Frequency'],
                data: [
                    ['', 0, 'I.', 'Check for changes in Notified GDP', '', '', '', '', '', ''],
                    ['', 1, '1.', 'Check if Notified GDP <> UVGDH.1.0.0.0 in AMECO_H database',
                    // eslint-disable-next-line max-len
                     'Validation checks for the difference between Notified GDP from Country desk and the one from AMECO_H',
                     '', 'High', 'abs(UVGDH[t] / AMECO Historical!UVGDH.1.0.0.0[t] - 1) * 100 > 2',
                     'UVGDH', 'Annual']
                ]
            })
            getCtyTaskExceptionsStub.resolves([
                { STEP_NUMBER: 0, STEP_EXCEPTIONS: 4, TASK_STEP_TYPE_ID: 'Unknown error' },
                { STEP_NUMBER: 1, STEP_EXCEPTIONS: 1, TASK_STEP_TYPE_ID: 'Validation error' },
            ])

            // when
            const result = await reportController.getValidationTable(
                countryId, roundSid, storageSid
            )

            // then
            result.should.be.eql({
                // eslint-disable-next-line max-len
                header: ['Type','Identifier','No.','Validation rule','Description','Number of Exceptions','Severity','Formula','Target data','Frequency'],
                data: [
                    ['Unknown error',0,'I.','Check for changes in Notified GDP','',4,'','','',''],
                    // eslint-disable-next-line max-len
                    ['Validation error',1,'1.','Check if Notified GDP <> UVGDH.1.0.0.0 in AMECO_H database','Validation checks for the difference between Notified GDP from Country desk and the one from AMECO_H',1,'High','abs(UVGDH[t] / AMECO Historical!UVGDH.1.0.0.0[t] - 1) * 100 > 2','UVGDH','Annual']
                ]}
            )
            requestStub.calledOnceWithExactly(EApps.FDMSSTAR, '/reports/validationTable').should.be.true
            getCtyTaskExceptionsStub.calledOnceWithExactly(
                appId, ETasks.VALIDATION, countryId, {roundSid, storageSid}
            ).should.be.true
        })
    })

    describe('getReportIndicators method', function() {

        it('should return indicators for reportId', async function() {

            // given
            const reportId = 'GDP_XYZ'
            reportServiceStub.getReportIndicators.resolves([
                { INDICATOR_ID: 'OVGD.1.0.0.0', INDICATOR_DESCR: 'Test indicator 1', ORDER_BY: 3 },
                { INDICATOR_ID: 'OVGD.1.30.0.0', INDICATOR_DESCR: 'Test indicator 2', ORDER_BY: 5 },
            ])

            // when
            const result = await reportController.getReportIndicators(reportId)

            // then
            result.should.be.eql([
                { INDICATOR_ID: 'OVGD.1.0.0.0', INDICATOR_DESCR: 'Test indicator 1', ORDER_BY: 3 },
                { INDICATOR_ID: 'OVGD.1.30.0.0', INDICATOR_DESCR: 'Test indicator 2', ORDER_BY: 5 },
            ])
            reportServiceStub.getReportIndicators.calledOnceWithExactly(reportId).should.be.true
        })
    })

    describe('getBaseYear method', function() {

        it('should return base year', async function() {
            // given
            const roundSid = 346
            reportServiceStub.getBaseYear.resolves(2020)

            // when
            const result = await reportController.getBaseYear(roundSid)

            // then
            result.should.be.eql(2020)
            reportServiceStub.getBaseYear.calledOnceWithExactly(roundSid).should.be.true
        })
    })

    describe('getIndicatorScales method', function() {

        it('should return indicators scales', async function() {

            // given
            const provider = 'PRE_PROD'
            const periodicity = 'M'
            const countries = ['PL', 'BE']
            const indicators = ['OBGE.1.0.1.0', 'OVGDE.1.2.30.0']
            reportServiceStub.getIndicatorsScales.resolves([
                {  INDICATOR_ID: 'OBGE.1.0.1.0',
                    COUNTRY_ID: 'PL',
                    SCALE_ID: 'BILLIONS',
                    DESCR: 'Billions PLN',
                    EXPONENT: 1000
                }
            ])

            // when
            const result = await reportController.getIndicatorScales(
                provider, periodicity, countries, indicators
            )

            // then
            result.should.be.eql([
                {  INDICATOR_ID: 'OBGE.1.0.1.0',
                    COUNTRY_ID: 'PL',
                    SCALE_ID: 'BILLIONS',
                    DESCR: 'Billions PLN',
                    EXPONENT: 1000
                }
            ])
            reportServiceStub.getIndicatorsScales.calledOnceWithExactly(
                provider, periodicity, countries, indicators
            ).should.be.true
        })
    })

    describe('getIndicatorCountries method', function() {

        it('should return indicator countries', async function() {

            // given
            reportServiceStub.getIndicatorCountries.resolves([
                {
                    CODEISO3: 'PLN',
                    CODE_FGD: 123,
                    COUNTRY_ID: 'PL',
                    DESCR: 'Poland'
                }
            ])

            // when
            const result = await reportController.getIndicatorCountries()

            // then
            result.should.be.eql([{
                CODEISO3: 'PLN',
                CODE_FGD: 123,
                COUNTRY_ID: 'PL',
                DESCR: 'Poland'
            }])
            reportServiceStub.getIndicatorCountries.calledOnceWithExactly().should.be.true
        })
    })

    describe('getIndicatorsTree method', function() {

        it('should return indicators tree', async function() {

            // given
            reportServiceStub.getIndicatorsTree.resolves([
                {
                    CODE: 'IO',
                    DESCR: 'Parent node',
                    ORDER_BY: 2,
                    LEVEL: 1,
                },
                {
                    CODE: 'IT',
                    DESCR: 'Indicator one',
                    ORDER_BY: 4,
                    LEVEL: 2,
                    PARENT_CODE: 'IO2',
                    INDICATOR_ID: 'OBGDE.1.0.0.0'
                }
            ])

            // when
            const result = await reportServiceStub.getIndicatorsTree()

            // then
            result.should.be.eql([
                {
                    CODE: 'IO',
                    DESCR: 'Parent node',
                    ORDER_BY: 2,
                    LEVEL: 1,
                },
                {
                    CODE: 'IT',
                    DESCR: 'Indicator one',
                    ORDER_BY: 4,
                    LEVEL: 2,
                    PARENT_CODE: 'IO2',
                    INDICATOR_ID: 'OBGDE.1.0.0.0'
                }
            ])
            reportServiceStub.getIndicatorsTree.calledOnceWithExactly().should.be.true
        })
    })
})
