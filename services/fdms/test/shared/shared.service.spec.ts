import 'chai/register-should.js'
import * as sinon from 'sinon'

import { BIND_OUT, CURSOR, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { LoggingService } from '../../../lib/dist'
import { SharedService } from '../../src/shared/shared.service'

describe('SharedService test suite', function() {

    let execSPStub
    const loggingServiceStub = sinon.createStubInstance(LoggingService)
    const sharedService = new SharedService(loggingServiceStub)

    // test data
    const providerIds = ['PRE_PROD', 'ESTAT_M']
    const countryIds = ['BE', 'IT']
    const indicatorIds = ['UBLG.1.1.0.309', 'OMDG.3.4.2.1']
    const partnerIds = ['T', 'W']
    const periodicityId = 'Q'
    const roundSid = 32
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

    beforeEach(function() {
        execSPStub = sinon.stub(DataAccessApi, 'execSP')
    })

    afterEach(function() {
        execSPStub.restore()
    })

    describe('getProvidersIndicatorData method', function() {

        it('should return indicator data as db objects', async function() {
            // given
            execSPStub.resolves({ o_cur: dbData })

            // when
            const results = await sharedService.getProvidersIndicatorData(
                providerIds, countryIds, indicatorIds, periodicityId, true, roundSid, storageSid, undefined
            )

            // then
            results.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_indicator.getProvidersIndicatorData', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_provider_ids', type: STRING, value: providerIds },
                    { name: 'p_country_ids', type: STRING, value: countryIds },
                    { name: 'p_indicator_ids', type: STRING, value: indicatorIds },
                    { name: 'p_og_full', type: NUMBER, value: 1 },
                    { name: 'p_periodicity_id', type: STRING, value: periodicityId },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'p_cust_text_sid', type: NUMBER, value: null },
                    { name: 'p_codes', type: STRING, value: [] },
                    { name: 'p_trns', type: STRING, value: [] },
                    { name: 'p_aggs', type: STRING, value: [] },
                    { name: 'p_units', type: STRING, value: [] },
                    { name: 'p_refs', type: STRING, value: [] },
                ],
                arrayFormat: undefined
            }).should.be.true
        })
    })

    describe('getProvidersIndicatorDataArray method', function() {

        it('should return indicator data as array data', async function() {
            // given
            execSPStub.resolves({ o_cur: dbData })

            // when
            const results = await sharedService.getProvidersIndicatorDataArray(
                providerIds, countryIds, indicatorIds, periodicityId, true, roundSid, storageSid, undefined
            )

            // then
            results.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_indicator.getProvidersIndicatorData', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_provider_ids', type: STRING, value: providerIds },
                    { name: 'p_country_ids', type: STRING, value: countryIds },
                    { name: 'p_indicator_ids', type: STRING, value: indicatorIds },
                    { name: 'p_og_full', type: NUMBER, value: 1 },
                    { name: 'p_periodicity_id', type: STRING, value: periodicityId },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'p_cust_text_sid', type: NUMBER, value: null },
                    { name: 'p_codes', type: STRING, value: [] },
                    { name: 'p_trns', type: STRING, value: [] },
                    { name: 'p_aggs', type: STRING, value: [] },
                    { name: 'p_units', type: STRING, value: [] },
                    { name: 'p_refs', type: STRING, value: [] },
                ],
                arrayFormat: true
            }).should.be.true
        })
    })

    describe('indicatorsDataVectorToArray method', function() {

        it('should convert string vector to array of numbers', function() {
            // given
            const data = [
                {
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
                },
                {
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'UPSA.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1960,
                    PERIODICITY_ID: 'Q',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-02-02'),
                    TIMESERIE_DATA: 'n/a,2.0003,32232,0,,76.897897',
                }
            ]

            // when
            const results = SharedService.indicatorsDataVectorToArray(data)

            // then
            results.should.be.eql([
                {
                    TIMESERIE_DATA: [1, 2.3, 2.45, 2.443],
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'UBLG.1.1.0.309',
                    SCALE_ID: 'UNIT',
                    START_YEAR:1969,
                    PERIODICITY_ID: 'Q',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-06-07')
                },
                {
                    TIMESERIE_DATA: [NaN, 2.0003, 32232, 0, NaN, 76.897897],
                    COUNTRY_ID: 'BE',
                    INDICATOR_ID: 'UPSA.1.0.0.0',
                    SCALE_ID: 'UNIT',
                    START_YEAR: 1960,
                    PERIODICITY_ID: 'Q',
                    COUNTRY_DESCR: 'Belgium',
                    SCALE_DESCR: 'Unit',
                    DATA_SOURCE: 'FDMS*',
                    UPDATE_DATE: new Date('2022-02-02')
                }]
            )
        })
    })

    describe('isOgFull method', function() {

        it('should be successful', async function() {
            // given
            const countryId = 'MT'
            execSPStub.resolves({ o_res: 1 })

            // when
            const result = await sharedService.isOgFull(countryId, roundSid, storageSid)

            // then
            result.should.be.eql(true)
            execSPStub.calledWithExactly('fdms_indicator.isOgFull', {
                params: [
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                    { name: 'p_country_id', type: STRING, value: countryId },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                ],
            }).should.be.true
        })
    })

    describe('getTceData method', function() {

        it('should return tce data as db objects', async function() {
            // given
            execSPStub.resolves({ o_cur: dbData })

            // when
            const results = await sharedService.getTceData(
                countryIds, indicatorIds, partnerIds, periodicityId, roundSid, storageSid
            )

            // then
            results.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_tce.getTCEIndicatorData', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_country_ids', type: STRING, value: countryIds },
                    { name: 'p_indicator_ids', type: STRING, value: indicatorIds },
                    { name: 'p_partner_ids', type: STRING, value: partnerIds },
                    { name: 'p_periodicity_id', type: STRING, value: periodicityId },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                ],
                arrayFormat: undefined,
            }).should.be.true
        })
    })

    describe('getTceDataArray method', function() {

        it('should return tce data as array data', async function() {
            // given
            execSPStub.resolves({ o_cur: dbData })

            // when
            const results = await sharedService.getTceDataArray(
                countryIds, indicatorIds, partnerIds, periodicityId, roundSid, storageSid
            )

            // then
            results.should.be.eql(dbData)
            execSPStub.calledWithExactly('fdms_tce.getTCEIndicatorData', {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_country_ids', type: STRING, value: countryIds },
                    { name: 'p_indicator_ids', type: STRING, value: indicatorIds },
                    { name: 'p_partner_ids', type: STRING, value: partnerIds },
                    { name: 'p_periodicity_id', type: STRING, value: periodicityId },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                ],
                arrayFormat: true,
            }).should.be.true
        })
    })
})
