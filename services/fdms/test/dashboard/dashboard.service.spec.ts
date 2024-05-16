import 'chai/register-should.js'
import * as sinon from 'sinon'

import { BIND_OUT, CURSOR, NUMBER, STRING } from '../../../lib/dist/db'
import { DashboardService } from '../../src/dashboard/dashboard.service'
import { DataAccessApi } from '../../../lib/dist/api'

describe('DashboardService test suite', function() {

    const dashboardService = new DashboardService()

    let execSPStub

    beforeEach(function() {
        execSPStub = sinon.stub(DataAccessApi, 'execSP')
    })

    afterEach(function() {
        execSPStub.restore()
    })

    describe('getCountryUploads method', function() {

        it('should return country uploads information', async function() {
            // given
            const appId = 'FDMS'
            const countries = ['BE', 'PL', 'IT']
            const roundSid = 672
            const storageSid = 3

            const uploadDates = [
                { COUNTRY_ID: 'BE', UPDATE_DATE: new Date('2022-01-02') },
                { COUNTRY_ID: 'PL', UPDATE_DATE: new Date('2022-02-04') },
                { COUNTRY_ID: 'IT', UPDATE_DATE: new Date('2022-03-05') },
            ]
            execSPStub.resolves({ o_cur: uploadDates })

            // when
            const result = await dashboardService.getCountryUploads(appId, countries, roundSid, storageSid)

            // then
            result.should.be.eql(uploadDates)
            execSPStub.calledWithExactly('fdms_upload.getCountryUploadsInfo',
                {
                    params: [
                        { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                        { name: 'p_app_id', type: STRING, value: appId },
                        { name: 'p_country_ids', type: STRING, value: countries },
                        { name: 'p_round_sid', type: NUMBER, value: roundSid },
                        { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    ],
                }
            ).should.be.true
        })

        it('should return country uploads information for empty params', async function() {
            // given
            const appId = 'FDMS'
            const uploadDates = [
                { COUNTRY_ID: 'BE', UPDATE_DATE: new Date('2022-01-02') },
            ]
            execSPStub.resolves({ o_cur: uploadDates })

            // when
            const result = await dashboardService.getCountryUploads(appId, undefined)

            // then
            result.should.be.eql(uploadDates)
            execSPStub.calledWithExactly('fdms_upload.getCountryUploadsInfo',
                {
                    params: [
                        { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                        { name: 'p_app_id', type: STRING, value: appId },
                        { name: 'p_country_ids', type: STRING, value: [] },
                        { name: 'p_round_sid', type: NUMBER, value: null },
                        { name: 'p_storage_sid', type: NUMBER, value: null },
                    ],
                }
            ).should.be.true
        })
    })

    describe('transferAmecoIndicatorsToScopax method', function() {

        it('should transfer ameco indicators to scopax', async function() {
            // given
            const roundSid = 873
            const storageSid = 6
            execSPStub.resolves({ o_res: 256 })

            // when
            const result = await dashboardService.transferAmecoIndicatorsToScopax(roundSid, storageSid)

            // then
            result.should.be.eql(256)
            execSPStub.calledWithExactly('fdms_indicator.transferAmecoToScopax',
                {
                    params: [
                        { name: 'p_round_sid', type: NUMBER, value: roundSid},
                        { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                        { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                    ],
                }
            ).should.be.true
        })
    })
})
