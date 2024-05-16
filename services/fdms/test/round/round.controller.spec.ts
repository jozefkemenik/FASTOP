import 'chai/register-should.js'
import * as sinon from 'sinon'

import { CountryStatusApi, DashboardApi, DrmApi, FdmsApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { EStatusRepo } from 'country-status'
import { ICurrentRoundInfo } from '../../../dashboard/src/config/shared-interfaces'
import { RoundController } from '../../src/round/round.controller'
import { RoundService } from '../../src/round/round.service'

describe('RoundController test suite', function() {

    const roundServiceStub = sinon.createStubInstance(RoundService)
    const roundController = new RoundController(roundServiceStub)

    // common test data
    const roundSid = 1410

    describe('activeRound method', function() {

        // test data
        const user = 'ramboj'
        const roundInfo: ICurrentRoundInfo = {
            roundSid: 1540,
            year: 2022,
            roundDescr: 'Spring 2022',
            periodDescr: 'Spring',
            periodId: 'SPR',
            storageSid: 6,
            storageDescr: 'Final',
            storageId: 'FINAL',
            textSid: null,
            textTitle: null,
            textDescr: null,
            version: 2,
        }

        // stubs
        let getCountryStatusStub
        let acceptForecastAggregationStub
        let getCurrentRoundInfoStub
        let newRoundStub

        beforeEach(function() {
            getCountryStatusStub = sinon.stub(CountryStatusApi, 'getCountryStatusId')
            acceptForecastAggregationStub = sinon.stub(FdmsApi, 'acceptForecastAggregation')
            getCurrentRoundInfoStub = sinon.stub(DashboardApi, 'getCurrentRoundInfo').resolves(roundInfo)
            newRoundStub = sinon.stub(DrmApi, 'newRound')
        })

        afterEach(function() {
            getCountryStatusStub.restore()
            acceptForecastAggregationStub.restore()
            getCurrentRoundInfoStub.restore()
            newRoundStub.restore()
            roundServiceStub.activateRound.reset()
        })

        it('should call Fdms to activate forecast aggregates and fail when aggregation cannot be run', async function() {
            // given
            getCountryStatusStub.resolves(EStatusRepo.ACTIVE)
            acceptForecastAggregationStub.resolves({ result: 0 })

            // when
            const result = await roundController.activateRound(roundSid, user)

            // then
            result.should.be.eq(0)
            getCountryStatusStub.calledWithExactly(EApps.FDMS, 'AGG').should.be.true
            acceptForecastAggregationStub.calledWithExactly(EStatusRepo.ACTIVE, user).should.be.true
        })

        it('should activate round when status is ACTIVE', async function() {
            // given
            getCountryStatusStub.resolves(EStatusRepo.ACTIVE)
            acceptForecastAggregationStub.resolves({ result: 1 })
            roundServiceStub.activateRound.resolves(true)

            // when
            const result = await roundController.activateRound(roundSid, user)

            // then
            result.should.be.eq(1)
            getCountryStatusStub.calledWithExactly(EApps.FDMS, 'AGG').should.be.true
            roundServiceStub.activateRound.calledWithExactly(roundSid, user).should.be.true
            acceptForecastAggregationStub.calledWithExactly(EStatusRepo.ACTIVE, user).should.be.true
            getCurrentRoundInfoStub.calledWithExactly(EApps.FDMS).should.be.true
            newRoundStub.calledOnce.should.be.true
            newRoundStub.calledWithExactly(roundInfo.roundSid, roundSid, user).should.be.true
        })

        it('should not activate round when round service fails', async function() {
            // given
            getCountryStatusStub.resolves(EStatusRepo.ACTIVE)
            acceptForecastAggregationStub.resolves({ result: 1 })
            roundServiceStub.activateRound.resolves(false)

            // when
            const result = await roundController.activateRound(roundSid, user)

            // then
            result.should.be.eq(0)
            getCountryStatusStub.calledWithExactly(EApps.FDMS, 'AGG').should.be.true
            roundServiceStub.activateRound.calledWithExactly(roundSid, user).should.be.true
            acceptForecastAggregationStub.calledWithExactly(EStatusRepo.ACTIVE, user).should.be.true
            getCurrentRoundInfoStub.calledWithExactly(EApps.FDMS).should.be.true
            newRoundStub.calledOnce.should.be.false
        })

        it('should activate round when aggregation status is different than ACTIVE', async function() {
            // given
            getCountryStatusStub.resolves(EStatusRepo.ACCEPTED)
            roundServiceStub.activateRound.resolves(true)

            // when
            const result = await roundController.activateRound(roundSid, user)

            // then
            result.should.be.eq(1)
            getCountryStatusStub.calledWithExactly(EApps.FDMS, 'AGG').should.be.true
            roundServiceStub.activateRound.calledWithExactly(roundSid, user).should.be.true
            acceptForecastAggregationStub.notCalled.should.be.true
            getCurrentRoundInfoStub.calledWithExactly(EApps.FDMS).should.be.true
            newRoundStub.calledOnce.should.be.true
            newRoundStub.calledWithExactly(roundInfo.roundSid, roundSid, user).should.be.true
        })
    })

    describe('checkRoundActivation method', function() {

        let getCountryStatusStub

        beforeEach(function() {
            getCountryStatusStub = sinon.stub(CountryStatusApi, 'getCountryStatusId')
        })

        afterEach(function() {
            getCountryStatusStub.restore()
            roundServiceStub.checkRoundActivation.reset()
        })

        it('should validate round activation', async function() {
            // given
            getCountryStatusStub.resolves(EStatusRepo.OPENED)
            const roundCheckStatus = {
                roundOk: true,
                storageOk: true,
                appStatus: [{ appId: 'FDMS', status: 'ACTIVE', statusChange: 1 }]
            }
            roundServiceStub.checkRoundActivation.resolves(roundCheckStatus)

            // when
            const result = await roundController.checkRoundActivation(roundSid)

            // then
            result.should.be.eql({
                roundOk: true,
                storageOk: true,
                appStatus: [{ appId: 'FDMS', status: 'ACTIVE', statusChange: 1 }],
                forecastAggStatusId: EStatusRepo.OPENED
            })
            roundServiceStub.checkRoundActivation.calledWithExactly(roundSid).should.be.true
            getCountryStatusStub.calledWithExactly(EApps.FDMS, 'AGG').should.be.true
        })
    })
})
