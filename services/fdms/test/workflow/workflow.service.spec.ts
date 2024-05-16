import 'chai/register-should.js'
import * as sinon from 'sinon'

import { BIND_IN, BIND_OUT, NUMBER } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { WorkflowService } from '../../src/workflow/workflow.service'

describe('WorkflowService test suite', function() {

    let execSPStub
    const appId = EApps.FDMS
    const workflowService = new WorkflowService(appId)

    beforeEach(function() {
        execSPStub = sinon.stub(DataAccessApi, 'execSP')
    })

    afterEach(function() {
        execSPStub.restore()
    })

    describe('closeApplication method', function() {

        it('should be successful', async function() {
            // given
            execSPStub.resolves({ o_res: 1 })

            // when
            const result = await workflowService.closeApplication()

            // then
            result.should.be.eql(1)
            execSPStub.calledWithExactly('fdms_app_status.setApplicationClosed', {
                params: [
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('advanceStorage method', function() {

        it('should be successful', async function() {
            // given
            const roundSid = 657
            const storageSid = 2
            execSPStub.resolves({ o_res: 10 })

            // when
            const result = await workflowService.advanceStorage(roundSid, storageSid)

            // then
            result.should.be.eql(10)
            execSPStub.calledWithExactly('fdms_round.moveToNextStorage', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                    { name: 'p_storage_sid', type: NUMBER, dir: BIND_IN, value: storageSid },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })
})
