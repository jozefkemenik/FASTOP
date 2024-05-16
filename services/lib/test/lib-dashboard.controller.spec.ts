import {} from 'mocha'
import * as sinon from 'sinon'
import { should as chaiShould } from 'chai'

import { EApps } from 'config'
import { EDashboardActions } from '../../shared-lib/dist/prelib/dashboard'
import { EErrors } from '../../shared-lib/dist/prelib/error'
import { EStatusRepo } from 'country-status'
import { IRoundKeys } from '../../dashboard/src/config/shared-interfaces'

import { CountryStatusApi } from '../src/api/country-status.api'
import { DashboardApi } from '../src/api/dashboard.api'
import { IDashboard } from '../src/dashboard'
import { LibDashboardController } from '../src/dashboard/lib-dashboard.controller'
import { LoggingService } from '../src/logging.service'

/* eslint-disable @typescript-eslint/no-unused-vars */
const should = chaiShould()

class DashboardController extends LibDashboardController {
    constructor() {super(EApps.DFM, new LoggingService(EApps.DFM))}
    protected get currentRoundKeys$(): Promise<IRoundKeys> {
        return Promise.resolve({roundSid: 23, storageSid: null, custTextSid: null})
    }
    public async getDashboard(isAdmin: boolean, userCountries: string[]): Promise<IDashboard> {
        return {} as IDashboard
    }
    public async presubmitCheck(countryId: string, roundSid: number) {
        return 0
    }
}
const statuses = [
    EStatusRepo.ACCEPTED, EStatusRepo.ACTIVE, EStatusRepo.ARCHIVED,
    EStatusRepo.REJECTED, EStatusRepo.SUBMITTED, EStatusRepo.VALIDATED,
]

describe('LibDashboardController test suite', function() {
    const dashboardController = new DashboardController()
    const roundKeys = {roundSid: 23}
    let getApplicationStatusStub
    let setCountryStatusStub

    beforeEach(() => {
        getApplicationStatusStub = sinon.stub(DashboardApi, 'getApplicationStatus')
        getApplicationStatusStub.resolves(EStatusRepo.OPENED)

        setCountryStatusStub = sinon.stub(CountryStatusApi, 'setCountryStatus')
        setCountryStatusStub.resolves({result: 1, countryStatus: {
            lastChangeDate: '2020-04-01',
            lastChangeUser: 'changeUser',
            statusDescr: 'Submitted',
            statusId: EStatusRepo.SUBMITTED,
        }})
    });
    afterEach(()=>{
        getApplicationStatusStub.restore()
        setCountryStatusStub.restore()
    })

    describe('performAction', function() {
        it('should reject (CTY_STATUS) if action is not allowed in country status', async function() {
            for (const status of statuses.filter(s => ![EStatusRepo.ACTIVE, EStatusRepo.REJECTED].includes(s))) {
                const result = await dashboardController.performAction(
                    EDashboardActions.SUBMIT, 'ab', status, roundKeys, 'comment', 'user'
                )
                setCountryStatusStub.notCalled.should.be.true
                result.result.should.equal(EErrors.CTY_STATUS)
            }
        })
        it('should reject (APP_STATUS) if application status is not OPENED', async function() {
            getApplicationStatusStub.returns(Promise.resolve(EStatusRepo.CLOSED));
            const result = await dashboardController.performAction(
                EDashboardActions.UNSUBMIT, 'ab', EStatusRepo.SUBMITTED, roundKeys, undefined, 'user'
            )
            setCountryStatusStub.notCalled.should.be.true
            result.result.should.equal(EErrors.APP_STATUS)
        })
        it('should reject (ROUND_KEYS) if round is not current', async function() {
            const result = await dashboardController.performAction(
                EDashboardActions.SUBMIT, 'ab', EStatusRepo.ACTIVE, {roundSid: 11}, undefined, 'user'
            )
            setCountryStatusStub.notCalled.should.be.true
            result.result.should.equal(EErrors.ROUND_KEYS)
        })
        it('should reject (CTY_ACTION) if action is not allowed', async function() {
            const result = await dashboardController.performAction(
                EDashboardActions.VALIDATE, 'ab', EStatusRepo.SUBMITTED, {roundSid: 11}, undefined, 'user'
            )
            setCountryStatusStub.notCalled.should.be.true
            result.result.should.equal(EErrors.CTY_ACTION)
        })
        it ('should call setCountryStatus if all parameters ok', async function() {
            const result = await dashboardController.performAction(
                EDashboardActions.UNSUBMIT, 'ab', EStatusRepo.SUBMITTED, roundKeys, 'comment', 'user'
            )
            setCountryStatusStub.calledOnce.should.be.true
            result.result.should.be.gt(0)
        })
        it ('should return ICtyActionResult if succeeded', async function() {
            const result = await dashboardController.performAction(
                EDashboardActions.SUBMIT, 'ab', EStatusRepo.ACTIVE, roundKeys, undefined, 'user'
            )
            result.updatedRow.lastChangeDate.should.equal('2020-04-01')
            result.updatedRow.lastChangeUser.should.equal('changeUser')
            result.updatedRow.data.currentStatus.should.eql({statusDescr: 'Submitted', statusId: EStatusRepo.SUBMITTED})
        })
    })
})

/* eslint-enable @typescript-eslint/no-unused-vars */
