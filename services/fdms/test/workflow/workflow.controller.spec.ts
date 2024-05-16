import 'chai/register-should.js'
import * as sinon from 'sinon'

import { DashboardApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { ICurrentRoundInfo } from '../../../dashboard/src/config/shared-interfaces'
import { WorkflowController } from '../../src/workflow/workflow.controller'
import { WorkflowService } from '../../src/workflow/workflow.service'

describe('WorkflowController test suite', function() {

    const appId = EApps.FDMS
    const workflowServiceStub = sinon.createStubInstance(WorkflowService)
    const workflowController = new WorkflowController(appId, workflowServiceStub)

    describe('advanceStorage method', function() {

        // test data
        const currentRoundInfo: ICurrentRoundInfo = {
            roundSid: 56,
            year: 2021,
            roundDescr: 'Spring 2021',
            periodDescr: 'Spring',
            periodId: 'SPR',
            storageSid: 5,
            storageDescr: 'TCE three',
            storageId: 'TCE3',
            textSid: null,
            textTitle: null,
            textDescr: null,
            version: 1,
        }

        // stubs
        let getCurrentRoundInfoStub

        beforeEach(function() {
            getCurrentRoundInfoStub = sinon.stub(DashboardApi, 'getCurrentRoundInfo').resolves(currentRoundInfo)
        })

        afterEach(function() {
            getCurrentRoundInfoStub.restore()
            workflowServiceStub.advanceStorage.reset()
        })

        it('should return ROUND_KEYS error when different roundSid', async function() {
            // given
            const roundInfo = Object.assign({}, currentRoundInfo, { roundSid: 100 })

            // when
            const result = await workflowController.advanceStorage(roundInfo)

            // then
            result.should.be.eql(EErrors.ROUND_KEYS)
            workflowServiceStub.advanceStorage.called.should.be.false
        })

        it('should return ROUND_KEYS error when different storageSid', async function() {
            // given
            const roundInfo = Object.assign({}, currentRoundInfo, { storageSid: 1 })

            // when
            const result = await workflowController.advanceStorage(roundInfo)

            // then
            result.should.be.eql(EErrors.ROUND_KEYS)
            workflowServiceStub.advanceStorage.called.should.be.false
        })

        it('should advance to the next storage', async function() {
            // given
            const roundInfo = Object.assign({}, currentRoundInfo)
            workflowServiceStub.advanceStorage.resolves(1)

            // when
            const result = await workflowController.advanceStorage(roundInfo)

            // then
            result.should.be.eql(1)
            workflowServiceStub.advanceStorage.calledWithExactly(roundInfo.roundSid, roundInfo.storageSid).should.be.true
        })
    })
})
