import 'chai/register-should.js'
import * as sinon from 'sinon'

import { BIND_OUT, CURSOR, NUMBER } from '../../../../lib/dist/db'
import { DataAccessApi } from '../../../../lib/dist/api'
import { EApps } from 'config'
import { ICountry } from '../../../../lib/dist/menu'
import { SharedService } from '../../../src/shared/shared.service'
import { TceService } from '../../../src/report/tce/tce.service'


describe('TceService test suite', function() {

    let execSPStub
    let tceService
    const appId = EApps.FDMS
    const sharedServiceStub = sinon.createStubInstance(SharedService)

    beforeEach(function() {
        execSPStub = sinon.stub(DataAccessApi, 'execSP')
        // create each time to clear the cache
        tceService = new TceService(appId, sharedServiceStub)
    })

    afterEach(function() {
        execSPStub.restore()
        tceService = undefined
    })

    describe('getTceResultsCountries method', function() {

        it('should return tce result countries', async function() {
            // given
            const roundSid = 33
            const storageSid = 2
            const dbCountries: ICountry[] = [
                {
                    CODEISO3: 'BEL',
                    CODE_FGD: 123,
                    COUNTRY_ID: 'BE',
                    DESCR: 'Belgium'
                }
            ]
            execSPStub.resolves({ o_cur: dbCountries })

            // when
            const result = await tceService.getTceResultsCountries(roundSid, storageSid)


            // then
            result.should.be.eql(dbCountries)
            execSPStub.calledWithExactly('fdms_tce.getTceResultsCountries', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ]
            }).should.be.true
        })
    })
})

