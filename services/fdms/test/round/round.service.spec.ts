import 'chai/register-should.js'
import * as sinon from 'sinon'
import { should } from 'chai'

import { BIND_IN, BIND_OUT, CURSOR, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { RoundService } from '../../src/round/round.service'

describe('RoundService test suite', function() {

    const roundService = new RoundService()
    let execSPStub

    beforeEach(function() {
        execSPStub = sinon.stub(DataAccessApi, 'execSP')
    })

    afterEach(function() {
        execSPStub.restore()
    })

    describe('getNextRoundInfo method', function() {

        it('should return next round info', async function() {
            // given
            const roundInfo = { year: 2022, periodDesc: 'Summer', title: 'SUM 2022', periodSid: 2 }
            execSPStub.resolves({ o_cur: [roundInfo] })

            // when
            const result = await roundService.getNextRoundInfo()

            // then
            result.should.be.eql(roundInfo)
            execSPStub.calledWithExactly('fdms_round.getNextRoundInfo',
                { params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }] }
            ).should.be.true
        })

        it('should not return next round info', async function() {
            // given
            execSPStub.resolves({})

            // when
            const result = await roundService.getNextRoundInfo()

            // then
            should().not.exist(result)
            execSPStub.calledWithExactly('fdms_round.getNextRoundInfo',
                { params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }] }
            ).should.be.true
        })
    })

    describe('getRounds method', function() {

        it('should return rounds', async function() {
            // given
            const roundInfos = [
                { year: 2021, periodDesc: 'Winter', title: 'WIN 2021' },
                { year: 2022, periodDesc: 'Summer', title: 'SUM 2022' },
            ]
            execSPStub.resolves({ o_cur: roundInfos })

            // when
            const result = await roundService.getRounds()

            // then
            result.should.be.eql(roundInfos)
            execSPStub.calledWithExactly('fdms_round.getRounds',
                { params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }] }
            ).should.be.true
        })
    })

    describe('checkNewRound method', function() {

        it('should return new round validation info', async function() {
            // given
            const year = 2020
            const periodSid = 3
            execSPStub.resolves({ o_input_year_ok: 1, o_input_period_sid_ok: 1, o_storage_ok: 0 })

            // when
            const result = await roundService.checkNewRound(year, periodSid)

            // then
            result.should.be.eql({ inputYearOk: true, inputPeriodSidOk: true, storageOk: false })
            execSPStub.calledWithExactly('fdms_round.checkNewRoundPreconditions', {
                params: [
                    { name: 'p_year', type: NUMBER, dir: BIND_IN, value: year },
                    { name: 'p_period_sid', type: NUMBER, dir: BIND_IN, value: periodSid },
                    { name: 'o_input_year_ok', type: NUMBER, dir: BIND_OUT },
                    { name: 'o_input_period_sid_ok', type: NUMBER, dir: BIND_OUT },
                    { name: 'o_storage_ok', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('createNewRound method', function() {

        it('should create a new round', async function() {
            // given
            const year = 2020
            const periodSid = 3
            const roundDesc = 'My test round'
            execSPStub.resolves({ o_input_year_ok: 1, o_input_period_sid_ok: 1, o_grid_round_app_id: 4, o_grids_ok: 1 })

            // when
            const result = await roundService.createNewRound(year, periodSid, roundDesc)

            // then
            result.should.be.eql({ inputYearOk: true, inputPeriodSidOk: true, gridRoundAppId: 4, gridsOk: true })
            execSPStub.calledWithExactly('fdms_round.createNewRound', {
                params: [
                    { name: 'p_year', type: NUMBER, dir: BIND_IN, value: year },
                    { name: 'p_period_sid', type: NUMBER, dir: BIND_IN, value: periodSid },
                    { name: 'p_desc', type: STRING, dir: BIND_IN, value: roundDesc },
                    { name: 'o_input_year_ok', type: NUMBER, dir: BIND_OUT },
                    { name: 'o_input_period_sid_ok', type: NUMBER, dir: BIND_OUT },
                    { name: 'o_grid_round_app_id', type: STRING, dir: BIND_OUT },
                    { name: 'o_grids_ok', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('checkRoundActivation', function() {

        it('should check round activation preconditions', async function() {
            // given
            const roundSid = 686
            execSPStub.resolves({ o_round_ok: 1, o_storage_ok: -1, o_app_status_cur: 'OPEN' })

            // when
            const result = await roundService.checkRoundActivation(roundSid)

            // then
            result.should.be.eql({ roundOk: true, storageOk: false, appStatus: 'OPEN' })
            execSPStub.calledWithExactly('fdms_round.checkActivateRound', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                    { name: 'o_round_ok', type: NUMBER, dir: BIND_OUT },
                    { name: 'o_storage_ok', type: NUMBER, dir: BIND_OUT },
                    { name: 'o_app_status_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })

    describe('activateRound method', function() {

        const roundSid = 1655
        const user = 'wickj'

        it('should activate round', async function() {
            // given
            execSPStub.resolves({ o_res: 2 })

            // when
            const result = await roundService.activateRound(roundSid, user)

            // then
            result.should.be.true
            execSPStub.calledWithExactly('fdms_round.activateRound', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                    { name: 'p_user', type: STRING, dir: BIND_IN, value: user },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true
        })

        it('should not activate round', async function() {
            // given
            execSPStub.resolves({ o_res: 0 })

            // when
            const result = await roundService.activateRound(roundSid, user)

            // then
            result.should.be.false
            execSPStub.calledWithExactly('fdms_round.activateRound', {
                params: [
                    { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                    { name: 'p_user', type: STRING, dir: BIND_IN, value: user },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }).should.be.true
        })
    })
})
