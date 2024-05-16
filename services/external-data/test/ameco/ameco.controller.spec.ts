import 'chai/register-should.js'
import * as sinon from 'sinon'
import { should } from 'chai'

import { AmecoController } from '../../src/ameco/ameco.controller'
import { AmecoInternalService } from '../../src/ameco/ameco-internal.service'
import { AmecoOnlineService } from '../../src/ameco/ameco-online.service'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'


describe('AmecoController test suite', function() {

    const amecoInternalServiceStub = sinon.createStubInstance(AmecoInternalService)
    const amecoOnlineServiceStub = sinon.createStubInstance(AmecoOnlineService)

    const amecoController = new AmecoController(amecoInternalServiceStub, amecoOnlineServiceStub)

    describe('getAmecoData method', function() {

        const countries = ['PL', 'FR']
        const indicators = ['AMGN.1.0.30.52', 'OIGOT']
        const amecoDbData = [
            {
                indicator_id: 'AMGN.1.0.30.52',
                descr: 'Test indicator 1',
                unit: 'MRD',
                start_year: 1992,
                vector: '1,2.3,4.2, n/a',
                country_id_iso2: 'PL',
                country_id_iso3: 'POL',
                country_descr: 'Poland',
            },
            {
                indicator_id: 'OIGOT',
                descr: 'Test indicator 12',
                unit: 'UNIT',
                start_year: 2013,
                vector: '10,12.3,14.2',
                country_id_iso2: 'FR',
                country_id_iso3: 'FRA',
                country_descr: 'France',
            }
        ]
        const amecoData = [
            {
                indicatorId: 'AMGN.1.0.30.52',
                countryIdIso3: 'POL',
                countryIdIso2: 'PL',
                countryDesc: 'Poland',
                name: 'Test indicator 1',
                scale: 'MRD',
                startYear: 1992,
                vector: [
                    1,
                    2.3,
                    4.2,
                    NaN
                ]
            },
            {
                indicatorId: 'OIGOT',
                countryIdIso2: 'FR',
                countryIdIso3: 'FRA',
                countryDesc: 'France',
                name: 'Test indicator 12',
                scale: 'UNIT',
                startYear: 2013,
                vector: [
                    10,
                    12.3,
                    14.2
                ]
            }
        ]

        beforeEach(function() {
            amecoOnlineServiceStub.getAmecoFullData.resolves(amecoDbData)
            amecoInternalServiceStub.getAmecoFullData.resolves(amecoDbData)
        })

        afterEach(function() {
            amecoOnlineServiceStub.getAmecoFullData.reset()
            amecoInternalServiceStub.getAmecoFullData.reset()
        })

        it('should return ameco online data', async function() {
            // when
            const result = await amecoController.getAmecoData(AmecoType.ONLINE, indicators, countries, true)

            // then
            result.should.be.eql(amecoData)
            amecoOnlineServiceStub.getAmecoFullData.calledOnceWithExactly(indicators, countries, true)
            amecoInternalServiceStub.getAmecoFullData.called.should.be.false
        })

        it('should return ameco current data', async function() {
            // when
            const result = await amecoController.getAmecoData(AmecoType.CURRENT, indicators, countries)

            // then
            result.should.be.eql(amecoData)
            amecoInternalServiceStub.getAmecoFullData.calledOnceWithExactly('getAmecoCurrent', indicators, countries)
            amecoOnlineServiceStub.getAmecoFullData.called.should.be.false
        })

        it('should return ameco public data', async function() {
            // when
            const result = await amecoController.getAmecoData(AmecoType.PUBLIC, indicators, countries)

            // then
            result.should.be.eql(amecoData)
            amecoInternalServiceStub.getAmecoFullData.calledOnceWithExactly('getAmecoPublic', indicators, countries)
            amecoOnlineServiceStub.getAmecoFullData.called.should.be.false
        })

        it('should return ameco restricted data', async function() {
            // when
            const result = await amecoController.getAmecoData(AmecoType.RESTRICTED, indicators, countries)

            // then
            result.should.be.eql(amecoData)
            amecoInternalServiceStub.getAmecoFullData.calledOnceWithExactly('getAmecoRestricted', indicators, countries)
            amecoOnlineServiceStub.getAmecoFullData.called.should.be.false
        })

        it('should throw exception when unknown ameco type', async function() {
            // when
            let error
            try {
                await amecoController.getAmecoData('XXX' as AmecoType, indicators, countries)
            } catch(err) {
                error = err
            }

            // then
            should().exist(error)
        })
    })

    describe('getCountries', function() {

        const countriesDB = [
            {
                COUNTRY_ID: 'BE',
                NAME: 'Belgium'
            },
            {
                COUNTRY_ID: 'EA',
                NAME: 'Euro Area',
                IS_COMPOSITE: 1
            }
        ]

        beforeEach(function() {
            amecoOnlineServiceStub.getCountries.resolves(countriesDB)
            amecoInternalServiceStub.getCountries.resolves(countriesDB)
        })

        afterEach(function() {
            amecoOnlineServiceStub.getCountries.reset()
            amecoInternalServiceStub.getCountries.reset()
        })

        it('should return ameco online countries', async function() {
            // when
            const result = await amecoController.getCountries(AmecoType.ONLINE)

            // then
            result.should.be.eql(countriesDB)
            amecoOnlineServiceStub.getCountries.calledOnce.should.be.true
            amecoInternalServiceStub.getCountries.called.should.be.false
        })

        it('should return ameco internal countries', async function() {
            // when
            const result = await amecoController.getCountries(AmecoType.PUBLIC)

            // then
            result.should.be.eql(countriesDB)
            amecoInternalServiceStub.getCountries.calledOnce.should.be.true
            amecoOnlineServiceStub.getCountries.called.should.be.false
        })
    })

    describe('getSeries', function() {

        const seriesDB = [
            {
                SERIE_SID: 2,
                SERIE_ID: 'KJUE',
                DESCR: 'Test ABC'
            },
            {
                SERIE_SID: 25,
                SERIE_ID: 'XYZT.1.0.2.3',
                DESCR: 'Test XYZ'
            }
        ]

        beforeEach(function() {
            amecoOnlineServiceStub.getNomSeries.resolves(seriesDB)
            amecoInternalServiceStub.getNomSeries.resolves(seriesDB)
        })

        afterEach(function() {
            amecoOnlineServiceStub.getNomSeries.reset()
            amecoInternalServiceStub.getNomSeries.reset()
        })

        it('should return ameco online series', async function() {
            // when
            const result = await amecoController.getSeries(AmecoType.ONLINE)

            // then
            result.should.be.eql(seriesDB)
            amecoOnlineServiceStub.getNomSeries.calledOnce.should.be.true
            amecoInternalServiceStub.getNomSeries.called.should.be.false
        })

        it('should return ameco internal series', async function() {
            // when
            const result = await amecoController.getSeries(AmecoType.PUBLIC)

            // then
            result.should.be.eql(seriesDB)
            amecoInternalServiceStub.getNomSeries.calledOnce.should.be.true
            amecoOnlineServiceStub.getNomSeries.called.should.be.false
        })
    })

    describe('getChapters', function() {

        const chaptersDB = [
            {
                SID: 10,
                CODE: 'D10',
                DESCR: 'Population',
                LEVEL: 2,
                NODE_TYPE: 'E',
                ORDER_BY: 1002,
                PARENT_CODE: 'U01'
            },
            {
                SID: 102,
                CODE: 'U01',
                DESCR: 'Global indicators',
                LEVEL: 1,
                NODE_TYPE: 'N',
                ORDER_BY: 101,
                PARENT_CODE: ''
            }
        ]

        beforeEach(function() {
            amecoOnlineServiceStub.getChapters.resolves(chaptersDB)
            amecoInternalServiceStub.getChapters.resolves(chaptersDB)
        })

        afterEach(function() {
            amecoOnlineServiceStub.getChapters.reset()
            amecoInternalServiceStub.getChapters.reset()
        })

        it('should return ameco online chapters', async function() {
            // when
            const result = await amecoController.getChapters(AmecoType.ONLINE)

            // then
            result.should.be.eql(chaptersDB)
            amecoOnlineServiceStub.getChapters.calledOnce.should.be.true
            amecoInternalServiceStub.getChapters.called.should.be.false
        })

        it('should return ameco internal chapters', async function() {
            // when
            const result = await amecoController.getChapters(AmecoType.PUBLIC)

            // then
            result.should.be.eql(chaptersDB)
            amecoInternalServiceStub.getChapters.calledOnce.should.be.true
            amecoOnlineServiceStub.getChapters.called.should.be.false
        })
    })

    describe('getSeriesData method', function() {

        const countries = 'PL,FR'
        const series = 'AMGN.1.0.30.52,OIGOT'
        const seriesDB = [
            {
                COUNTRY_ID: 'PL',
                SERIE_SID: 34,
                UNIT: 'Currency',
                TIME_SERIE: '12.0,n/a,10.001,12.02',
                START_YEAR: 2015
            },
            {
                COUNTRY_ID: 'BE',
                SERIE_SID: 22,
                UNIT: 'Currency',
                TIME_SERIE: '121.0,n/a,101.001,121.02',
                START_YEAR: 2013
            }
        ]

        beforeEach(function() {
            amecoOnlineServiceStub.getSeriesData.resolves(seriesDB)
            amecoInternalServiceStub.getCurrentSeriesData.resolves(seriesDB)
            amecoInternalServiceStub.getPublicSeriesData.resolves(seriesDB)
            amecoInternalServiceStub.getRestrictedSeriesData.resolves(seriesDB)
        })

        afterEach(function() {
            amecoOnlineServiceStub.getSeriesData.reset()
            amecoInternalServiceStub.getCurrentSeriesData.reset()
            amecoInternalServiceStub.getPublicSeriesData.reset()
            amecoInternalServiceStub.getRestrictedSeriesData.reset()
        })

        it('should return ameco online series data', async function() {
            // when
            const result = await amecoController.getSeriesData(AmecoType.ONLINE, countries, series)

            // then
            result.should.be.eql(seriesDB)
            amecoOnlineServiceStub.getSeriesData.calledOnceWithExactly(countries, series).should.be.true
        })

        it('should return ameco current series data', async function() {
            // when
            const result = await amecoController.getSeriesData(AmecoType.CURRENT, countries, series)

            // then
            result.should.be.eql(seriesDB)
            amecoInternalServiceStub.getCurrentSeriesData.calledOnceWithExactly(countries, series).should.be.true
        })

        it('should return ameco public series data', async function() {
            // when
            const result = await amecoController.getSeriesData(AmecoType.PUBLIC, countries, series)

            // then
            result.should.be.eql(seriesDB)
            amecoInternalServiceStub.getPublicSeriesData.calledOnceWithExactly(countries, series).should.be.true
        })

        it('should return ameco restricted series data', async function() {
            // when
            const result = await amecoController.getSeriesData(AmecoType.RESTRICTED, countries, series)

            // then
            result.should.be.eql(seriesDB)
            amecoInternalServiceStub.getRestrictedSeriesData.calledOnceWithExactly(countries, series).should.be.true
        })

        it('should throw exception when invalid ameco type', async function() {
            // when
            let error
            try {
                await amecoController.getSeriesData('XX' as AmecoType, countries, series)
            } catch(err) {
                error = err
            }

            // then
            should().exist(error)
        })
    })

    describe('logStats method', function() {

        beforeEach(function() {
            amecoInternalServiceStub.logStats.resolves(2)
            amecoOnlineServiceStub.logStats.resolves(1)
        })

        afterEach(function() {
            amecoInternalServiceStub.logStats.reset()
            amecoOnlineServiceStub.logStats.reset()
        })

        it('should log ameco internal restricted statistics', async function() {
            // given
            const stats = {
                userId: 'wreq',
                source: 'WWW',
                addr: '192.43.23.43',
                amecoType: AmecoType.RESTRICTED,
                agent: 'Mozilla Firefox',
                uri: '/ameco/wq/data?start=1998'
            }

            // when
            const result = await amecoController.logStats(stats)

            // then
            result.should.be.eql(2)
            amecoInternalServiceStub.logStats.calledOnceWithExactly(
                stats.userId, stats.source, stats.addr, 'R', stats.uri
            ).should.be.true
        })

        it('should log ameco internal current statistics', async function() {
            // given
            const stats = {
                userId: 'wreq',
                source: 'WWW',
                addr: '192.43.23.43',
                amecoType: AmecoType.CURRENT,
                agent: 'Chrome',
                uri: '/ameco/wq/data?start=1998'
            }

            // when
            const result = await amecoController.logStats(stats)

            // then
            result.should.be.eql(2)
            amecoInternalServiceStub.logStats.calledOnceWithExactly(
                stats.userId, stats.source, stats.addr, 'C', stats.uri
            ).should.be.true
        })

        it('should log ameco internal public statistics', async function() {
            // given
            const stats = {
                userId: 'wreq',
                source: 'WWW',
                addr: '192.43.23.43',
                amecoType: AmecoType.PUBLIC,
                agent: 'Edge',
                uri: '/ameco/wq/data?start=1998'
            }

            // when
            const result = await amecoController.logStats(stats)

            // then
            result.should.be.eql(2)
            amecoInternalServiceStub.logStats.calledOnceWithExactly(
                stats.userId, stats.source, stats.addr, 'A', stats.uri
            ).should.be.true
        })

        it('should log ameco online statistics', async function() {
            // given
            const stats = {
                userId: 'wreq',
                source: 'WWW',
                addr: '192.43.23.43',
                amecoType: AmecoType.ONLINE,
                agent: 'Safari',
                uri: '/ameco/wq/data?start=1998'
            }

            // when
            const result = await amecoController.logStats(stats)

            // then
            result.should.be.eql(1)
            amecoOnlineServiceStub.logStats.calledOnceWithExactly(
                stats.userId, stats.agent, stats.addr, stats.uri, stats.source
            ).should.be.true
        })
    })

})
