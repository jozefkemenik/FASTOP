import 'chai/register-should.js'
import * as sinon from 'sinon'

import { EOutputFormat, EProvider, IFpapiParams } from '../../../src/shared/shared-interfaces'
import { FpapiDataService } from '../../../src/shared/providers/fpapi.data.service'
import { LoggingService } from '../../../../lib/dist'
import { SdmxApi } from '../../../../lib/dist/api'


describe('FpapiDataService test suite', function() {

    const loggingServiceStub = sinon.createStubInstance(LoggingService)
    let getFpapiDataStub

    const fpapiDataService = new FpapiDataService(loggingServiceStub)


    describe('getData', function() {

        beforeEach(function() {
            getFpapiDataStub = sinon.stub(SdmxApi, 'getFpapiData')
        })

        afterEach(function() {
            getFpapiDataStub.restore()
        })

        describe('format date period', function() {

            const provider = EProvider.EUROSTAT
            const params: IFpapiParams = {
                dataset: 'namq_10_gdp',
                query: 'A.XYZ.PL',
                format: EOutputFormat.JSON,
                obsFlags: false,
            }

            describe('format annual period', function(){
                it('should format annual period', function() {
                    // given
                    params.startPeriod = { raw: '1999', freq: 'A', date: new Date(1999, 0, 1) }
                    getFpapiDataStub.resolves(undefined)

                    // when
                    fpapiDataService.getData(provider, params)

                    // then
                    getFpapiDataStub.calledWithExactly(
                        provider, params.dataset, params.query,
                        '1999', undefined, false
                    ).should.be.true
                })

            })

            describe('format semester period', function() {
                const tests = [
                    { arg: { raw: '2019-S1', freq: 'S', date: new Date(2019, 0, 1) }, expected: '2019-S1' },
                    { arg: { raw: '2019-S2', freq: 'S', date: new Date(2019, 6, 1) }, expected: '2019-S2' },
                ]

                tests.forEach(function(test) {
                    it(`should format ${test.arg.raw} semester`, function() {
                        // given
                        params.startPeriod = test.arg
                        getFpapiDataStub.resolves(undefined)

                        // when
                        fpapiDataService.getData(provider, params)

                        // then
                        getFpapiDataStub.calledWithExactly(
                            provider, params.dataset, params.query,
                            test.expected, undefined, false
                        ).should.be.true
                    })
                })
            })

            describe('format quarterly period', function() {
                const tests = [
                    { arg: { raw: '2018-Q1', freq: 'Q', date: new Date(2018, 0, 1) }, expected: '2018-Q1' },
                    { arg: { raw: '2018-Q2', freq: 'Q', date: new Date(2018, 3, 1) }, expected: '2018-Q2' },
                    { arg: { raw: '2018-Q3', freq: 'Q', date: new Date(2018, 6, 1) }, expected: '2018-Q3' },
                    { arg: { raw: '2018-Q4', freq: 'Q', date: new Date(2018, 9, 1) }, expected: '2018-Q4' },
                ]

                tests.forEach(function(test) {
                    it(`should format ${test.arg.raw} quarter`, function() {
                        // given
                        params.startPeriod = test.arg
                        getFpapiDataStub.resolves(undefined)

                        // when
                        fpapiDataService.getData(provider, params)

                        // then
                        getFpapiDataStub.calledWithExactly(
                            provider, params.dataset, params.query,
                            test.expected, undefined, false
                        ).should.be.true
                    })
                })
            })

            describe('format monthly period', function() {
                const tests = [
                    { arg: { raw: '2018-01', freq: 'M', date: new Date(2018, 0, 1) } , expected: '2018-01'},
                    { arg: { raw: '2018-02', freq: 'M', date: new Date(2018, 1, 1) } , expected: '2018-02'},
                    { arg: { raw: '2018-03', freq: 'M', date: new Date(2018, 2, 1) } , expected: '2018-03'},
                    { arg: { raw: '2018-04', freq: 'M', date: new Date(2018, 3, 1) } , expected: '2018-04'},
                    { arg: { raw: '2018-05', freq: 'M', date: new Date(2018, 4, 1) } , expected: '2018-05'},
                    { arg: { raw: '2018-06', freq: 'M', date: new Date(2018, 5, 1) } , expected: '2018-06'},
                    { arg: { raw: '2018-07', freq: 'M', date: new Date(2018, 6, 1) } , expected: '2018-07'},
                    { arg: { raw: '2018-08', freq: 'M', date: new Date(2018, 7, 1) } , expected: '2018-08'},
                    { arg: { raw: '2018-09', freq: 'M', date: new Date(2018, 8, 1) } , expected: '2018-09'},
                    { arg: { raw: '2018-10', freq: 'M', date: new Date(2018, 9, 1) } , expected: '2018-10'},
                    { arg: { raw: '2018-11', freq: 'M', date: new Date(2018, 10, 1) }, expected: '2018-11' },
                    { arg: { raw: '2018-12', freq: 'M', date: new Date(2018, 11, 1) }, expected: '2018-12' },
                ]

                tests.forEach(function(test) {
                    it(`should format ${test.arg.raw} month`, function() {
                        // given
                        params.startPeriod = test.arg
                        getFpapiDataStub.resolves(undefined)

                        // when
                        fpapiDataService.getData(provider, params)

                        // then
                        getFpapiDataStub.calledWithExactly(
                            provider, params.dataset, params.query,
                            test.expected, undefined, false
                        ).should.be.true
                    })
                })
            })

            describe('format daily period', function() {

                const tests = [
                    { arg: { raw: '2018-1-1', freq: 'D', date: new Date(2018, 0, 1) }, expected: '2018-001' },
                    { arg: { raw: '2019-2-15', freq: 'D', date: new Date(2019, 1, 15) }, expected: '2019-046' },
                    { arg: { raw: '2020-10-11', freq: 'D', date: new Date(2020, 9, 11) }, expected: '2020-285' },
                    { arg: { raw: '2023-12-31', freq: 'D', date: new Date(2023, 11, 31) }, expected: '2023-365' },
                    { arg: { raw: '2024-12-31', freq: 'D', date: new Date(2024, 11, 31) }, expected: '2024-366' },
                ]

                tests.forEach(function(test) {
                    it(`should format ${test.arg.raw} day`, function() {
                        // given
                        params.startPeriod = test.arg
                        getFpapiDataStub.resolves(undefined)

                        // when
                        fpapiDataService.getData(provider, params)

                        // then
                        getFpapiDataStub.calledWithExactly(
                            provider, params.dataset, params.query,
                            test.expected, undefined, false
                        ).should.be.true
                    })
                })
            })
        })
    })

})
