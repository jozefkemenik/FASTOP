import {} from 'mocha'
import { should as chaiShould } from 'chai'

import { EOutputFormat, EProvider } from '../../src/shared/shared-interfaces'
import { HttpError } from '../../src/shared/errors'
import { ParamsService } from '../../src/shared/params.service'


describe('ParamsService test suite', function() {

    const should = chaiShould()

    describe('parseFormat', function() {

        it('should parse format', function() {
            // when
            const result = ParamsService.parseFormat('sdmx-csv')

            // then
            should.equal(result, EOutputFormat.SDMX_CSV)
        })

        it('should return default json format', function() {
            // when
            const result = ParamsService.parseFormat('xyz')

            // then
            should.equal(result, EOutputFormat.JSON)
        })

    })

    describe('parseProvider', function() {

        it('should parse provider', function() {
            // when
            const result = ParamsService.parseProvider('estat')

            // then
            should.equal(result, EProvider.EUROSTAT)
        })

        it('should not parse provider', function() {
            // when
            const result = ParamsService.parseProvider('xyz')

            // then
            should.not.exist(result)
        })
    })

    describe('parseBoolean', function() {

        it('should parse 1 as true', function() {

            // when
            const result = ParamsService.parseBoolean(1)

            // then
            should.equal(result, true)
        })

        it('should parse "true" as true', function() {

            // when
            const result = ParamsService.parseBoolean("true")

            // then
            should.equal(result, true)
        })

        it('should parse 0 as false', function() {

            // when
            const result = ParamsService.parseBoolean(0)

            // then
            should.equal(result, false)
        })

        it('should parse "false" as false', function() {

            // when
            const result = ParamsService.parseBoolean("false")

            // then
            should.equal(result, false)
        })


        it('should parse null to default value', function() {

            // when
            const result = ParamsService.parseBoolean(undefined, false)

            // then
            should.equal(result, false)
        })

    })

    describe('parseDate', function() {

        it('should parse undefined period', function() {
            // when
            const result = ParamsService.parseDate(undefined)

            // then
            should.not.exist(result)
        })

        describe('parse annual', function() {

            it('should parse annual period', function() {
                // when
                const result = ParamsService.parseDate('2019')

                // then
                should.equal(result.raw, '2019')
                should.equal(result.freq, 'A')
                should.equal(result.date.getTime(), new Date(2019, 0, 1).getTime())
            })

            it('should throw exception when invalid annual period', function() {
                // when
                let error: HttpError
                try {
                    ParamsService.parseDate('201901')
                } catch(err) {
                    error = err
                }

                // then
                should.exist(error)
                should.equal(error.httpStatus, 400)
            })
        })

        describe('parse semester', function() {

            const tests = [
                { arg: '2019-S1', expected: { raw: '2019-S1', freq: 'S', date: new Date(2019, 0, 1) } },
                { arg: '2019-S2', expected: { raw: '2019-S2', freq: 'S', date: new Date(2019, 6, 1) } },
            ]

            tests.forEach(function(test) {
                it(`should parse ${test.arg} semester`, function() {
                    // when
                    const result = ParamsService.parseDate(test.arg)

                    // then
                    should.equal(result.raw, test.expected.raw)
                    should.equal(result.freq, test.expected.freq)
                    should.equal(result.date.getTime(), test.expected.date.getTime())
                })
            })

            it('should throw exception when invalid semester period', function() {
                // when
                let error: HttpError
                try {
                    ParamsService.parseDate('2019-S01')
                } catch(err) {
                    error = err
                }

                // then
                should.exist(error)
                should.equal(error.httpStatus, 400)
            })
        })

        describe('parse quarter', function() {

            const tests = [
                { arg: '2018-Q1', expected: { raw: '2018-Q1', freq: 'Q', date: new Date(2018, 0, 1) } },
                { arg: '2018-Q2', expected: { raw: '2018-Q2', freq: 'Q', date: new Date(2018, 3, 1) } },
                { arg: '2018-Q3', expected: { raw: '2018-Q3', freq: 'Q', date: new Date(2018, 6, 1) } },
                { arg: '2018-Q4', expected: { raw: '2018-Q4', freq: 'Q', date: new Date(2018, 9, 1) } },
            ]

            tests.forEach(function(test) {
                it(`should parse ${test.arg} quarter`, function() {
                    // when
                    const result = ParamsService.parseDate(test.arg)

                    // then
                    should.equal(result.raw, test.expected.raw)
                    should.equal(result.freq, test.expected.freq)
                    should.equal(result.date.getTime(), test.expected.date.getTime())
                })
            })

            it('should throw exception when invalid quarter period', function() {
                // when
                let error: HttpError
                try {
                    ParamsService.parseDate('2019-Q05')
                } catch(err) {
                    error = err
                }

                // then
                should.exist(error)
                should.equal(error.httpStatus, 400)
            })

        })

        describe('parse monthly', function() {

            const tests = [
                { arg: '2018-01', expected: { raw: '2018-01', freq: 'M', date: new Date(2018, 0, 1) } },
                { arg: '2018-02', expected: { raw: '2018-02', freq: 'M', date: new Date(2018, 1, 1) } },
                { arg: '2018-03', expected: { raw: '2018-03', freq: 'M', date: new Date(2018, 2, 1) } },
                { arg: '2018-04', expected: { raw: '2018-04', freq: 'M', date: new Date(2018, 3, 1) } },
                { arg: '2018-05', expected: { raw: '2018-05', freq: 'M', date: new Date(2018, 4, 1) } },
                { arg: '2018-06', expected: { raw: '2018-06', freq: 'M', date: new Date(2018, 5, 1) } },
                { arg: '2018-07', expected: { raw: '2018-07', freq: 'M', date: new Date(2018, 6, 1) } },
                { arg: '2018-08', expected: { raw: '2018-08', freq: 'M', date: new Date(2018, 7, 1) } },
                { arg: '2018-09', expected: { raw: '2018-09', freq: 'M', date: new Date(2018, 8, 1) } },
                { arg: '2018-10', expected: { raw: '2018-10', freq: 'M', date: new Date(2018, 9, 1) } },
                { arg: '2018-11', expected: { raw: '2018-11', freq: 'M', date: new Date(2018, 10, 1) } },
                { arg: '2018-12', expected: { raw: '2018-12', freq: 'M', date: new Date(2018, 11, 1) } },
                { arg: '2018-M01', expected: { raw: '2018-M01', freq: 'M', date: new Date(2018, 0, 1) } },
                { arg: '2018-M02', expected: { raw: '2018-M02', freq: 'M', date: new Date(2018, 1, 1) } },
                { arg: '2018-M03', expected: { raw: '2018-M03', freq: 'M', date: new Date(2018, 2, 1) } },
                { arg: '2018-M04', expected: { raw: '2018-M04', freq: 'M', date: new Date(2018, 3, 1) } },
                { arg: '2018-M05', expected: { raw: '2018-M05', freq: 'M', date: new Date(2018, 4, 1) } },
                { arg: '2018-M06', expected: { raw: '2018-M06', freq: 'M', date: new Date(2018, 5, 1) } },
                { arg: '2018-M07', expected: { raw: '2018-M07', freq: 'M', date: new Date(2018, 6, 1) } },
                { arg: '2018-M08', expected: { raw: '2018-M08', freq: 'M', date: new Date(2018, 7, 1) } },
                { arg: '2018-M09', expected: { raw: '2018-M09', freq: 'M', date: new Date(2018, 8, 1) } },
                { arg: '2018-M10', expected: { raw: '2018-M10', freq: 'M', date: new Date(2018, 9, 1) } },
                { arg: '2018-M11', expected: { raw: '2018-M11', freq: 'M', date: new Date(2018, 10, 1) } },
                { arg: '2018-M12', expected: { raw: '2018-M12', freq: 'M', date: new Date(2018, 11, 1) } },
                { arg: '2018-6', expected: { raw: '2018-6', freq: 'M', date: new Date(2018, 5, 1) } },
                { arg: '2018-M6', expected: { raw: '2018-M6', freq: 'M', date: new Date(2018, 5, 1) } },
            ]

            tests.forEach(function(test) {
                it(`should parse ${test.arg} month`, function() {
                    // when
                    const result = ParamsService.parseDate(test.arg)

                    // then
                    should.equal(result.raw, test.expected.raw)
                    should.equal(result.freq, test.expected.freq)
                    should.equal(result.date.getTime(), test.expected.date.getTime())
                })
            })

            it('should throw exception when invalid monthly period with M prefix', function() {
                // when
                let error: HttpError
                try {
                    ParamsService.parseDate('2019-M13')
                } catch(err) {
                    error = err
                }

                // then
                should.exist(error)
                should.equal(error.httpStatus, 400)
            })

            it('should throw exception when invalid monthly period', function() {
                // when
                let error: HttpError
                try {
                    ParamsService.parseDate('2019-13')
                } catch(err) {
                    error = err
                }

                // then
                should.exist(error)
                should.equal(error.httpStatus, 400)
            })

        })

        describe('parse daily', function() {

            const tests = [
                { arg: '2018-01-21', expected: { raw: '2018-01-21', freq: 'D', date: new Date(2018, 0, 21) } },
                { arg: '2015-12-31', expected: { raw: '2015-12-31', freq: 'D', date: new Date(2015, 11, 31) } },
            ]

            tests.forEach(function(test) {
                it(`should parse ${test.arg} day`, function() {
                    // when
                    const result = ParamsService.parseDate(test.arg)

                    // then
                    should.equal(result.raw, test.expected.raw)
                    should.equal(result.freq, test.expected.freq)
                    should.equal(result.date.getTime(), test.expected.date.getTime())
                })
            })

            it('should throw exception when invalid month in daily period', function() {
                // when
                let error: HttpError
                try {
                    ParamsService.parseDate('2019-13-01')
                } catch(err) {
                    error = err
                }

                // then
                should.exist(error)
                should.equal(error.httpStatus, 400)
            })

            it('should throw exception when invalid day in daily period', function() {
                // when
                let error: HttpError
                try {
                    ParamsService.parseDate('2019-12-32')
                } catch(err) {
                    error = err
                }

                // then
                should.exist(error)
                should.equal(error.httpStatus, 400)
            })

        })

    })
})
