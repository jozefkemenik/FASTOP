import {} from 'mocha'
import * as sinon from 'sinon'
import { should as chaiShould } from 'chai'

import { Level, LoggingService } from '../../lib/dist'
import { CountryStatusApi } from '../../lib/dist/api/country-status.api'
import { DashboardApi } from '../../lib/dist/api/dashboard.api'
import { DashboardController } from '../src/dashboard/dashboard.controller'
import { EApps } from 'config'
import { EDashboardActions } from '../../shared-lib/dist/prelib/dashboard'
import { EErrors } from '../../shared-lib/dist/prelib/error'
import { EStatusRepo } from 'country-status'

/* eslint-disable-next-line @typescript-eslint/no-unused-vars */
const should = chaiShould()

/* eslint-disable-next-line @typescript-eslint/no-unused-vars */
const statuses = [
    EStatusRepo.ACCEPTED, EStatusRepo.ACTIVE, EStatusRepo.ARCHIVED,
    EStatusRepo.REJECTED, EStatusRepo.SUBMITTED, EStatusRepo.VALIDATED,
]

describe('DashboardController test suite', function() {
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    const dashboardService: any = {
        archiveCountry: sinon.fake(() => Promise.resolve(5)),
    }
    const dashboardController = new DashboardController(EApps.DFM, new LoggingService(EApps.DFM, Level.NONE), dashboardService)
    const finalStorage = { storageSid: 3, storageId: 'FINAL', descr: 'Final', altDescr: 'Final', orderBy: 3, isCustom: false }
    const roundKeys = {roundSid: 23, storageSid: finalStorage.storageSid, storageId: finalStorage.storageId}
    const tce1Storage = { storageSid: 1, storageId: 'TCE1', descr: 'TCE1', altDescr: 'TCE1', orderBy: 1, isCustom: false }
    const roundKeysNotFinalStorage = {roundSid: 23, storageSid: 2, storageId: 'SECOND'}
    let getApplicationStatusStub
    let getCurrentRoundInfoStub
    let setCountryStatusStub
    let getStoragesStub

    beforeEach(() => {
        getApplicationStatusStub = sinon.stub(DashboardApi, 'getApplicationStatus')
        getCurrentRoundInfoStub = sinon.stub(DashboardApi, 'getCurrentRoundInfo')
        getStoragesStub = sinon.stub(DashboardApi, 'getStorages')

        setCountryStatusStub = sinon.stub(CountryStatusApi, 'setCountryStatus')
        setCountryStatusStub.resolves({result: 1, countryStatus: {
            lastChangeDate: '2020-04-01',
            lastChangeUser: 'changeUser',
            statusDescr: 'new status',
            statusId: 'statusId',
        }})
    });
    afterEach(()=>{
        getApplicationStatusStub.restore()
        getCurrentRoundInfoStub.restore()
        setCountryStatusStub.restore()
        getStoragesStub.restore()
    })

    describe('performAction', function() {

        describe('Transparency report dashboard actions', function() {

            it('should reject (ROUND_KEYS) if storage is not FINAL for TR_SUBMIT', async function() {
                getApplicationStatusStub.resolves(EStatusRepo.TR_OPENED)
                getCurrentRoundInfoStub.resolves(roundKeysNotFinalStorage)

                const result = await dashboardController.performAction(
                    EDashboardActions.TR_SUBMIT, 'ab', EStatusRepo.TR_OPENED, roundKeysNotFinalStorage, undefined, 'user'
                )
                setCountryStatusStub.notCalled.should.be.true
                result.result.should.equal(EErrors.ROUND_KEYS)
            })

            it('should reject (ROUND_KEYS) if storage is not FINAL for TR_UNSUBMIT', async function() {
                getApplicationStatusStub.resolves(EStatusRepo.TR_OPENED)
                getCurrentRoundInfoStub.resolves(roundKeysNotFinalStorage)

                const result = await dashboardController.performAction(
                    EDashboardActions.TR_UNSUBMIT, 'ab', EStatusRepo.TR_SUBMITTED, roundKeysNotFinalStorage, 'comment', 'user'
                )
                setCountryStatusStub.notCalled.should.be.true
                result.result.should.equal(EErrors.ROUND_KEYS)
            })

            it('should return ICtyActionResult if TR_SUBMIT succeeded', async function() {
                getApplicationStatusStub.resolves(EStatusRepo.TR_OPENED)
                getCurrentRoundInfoStub.resolves(roundKeys)

                const result = await dashboardController.performAction(
                    EDashboardActions.TR_SUBMIT, 'ab', EStatusRepo.TR_OPENED, roundKeys, undefined, 'user'
                )
                result.updatedRow.lastChangeDate.should.equal('2020-04-01')
                result.updatedRow.lastChangeUser.should.equal('changeUser')
                result.updatedRow.data.DFM.should.eql(
                    {statusDescr: 'new status', statusId: 'statusId'}
                )
            })

            it('should return ICtyActionResult if TR_UNSUBMIT succeeded', async function() {
                getApplicationStatusStub.resolves(EStatusRepo.TR_OPENED)
                getCurrentRoundInfoStub.resolves(roundKeys)

                const result = await dashboardController.performAction(
                    EDashboardActions.TR_UNSUBMIT, 'ab', EStatusRepo.TR_SUBMITTED, roundKeys, undefined, 'user'
                )
                result.updatedRow.lastChangeDate.should.equal('2020-04-01')
                result.updatedRow.lastChangeUser.should.equal('changeUser')
                result.updatedRow.data.DFM.should.eql(
                    {statusDescr: 'new status', statusId: 'statusId'}
                )
            })
        })

        describe('Archive dashboard action', function() {

            it('should return EErrors.IGNORE if ARCHIVE rejected for storage', async function() {
                getApplicationStatusStub.resolves(EStatusRepo.OPENED)
                getCurrentRoundInfoStub.resolves(roundKeys)
                getStoragesStub.resolves([tce1Storage])

                const result = await dashboardController.performAction(
                    EDashboardActions.ARCHIVE, 'ab', EStatusRepo.SUBMITTED, roundKeys, undefined, 'user'
                )
                dashboardService.archiveCountry.called.should.be.false
                result.result.should.equal(EErrors.IGNORE)
            })

            it('should return ICtyActionResult if ARCHIVE succeeded', async function() {
                getApplicationStatusStub.resolves(EStatusRepo.OPENED)
                getCurrentRoundInfoStub.resolves(roundKeys)
                getStoragesStub.resolves([finalStorage])

                const result = await dashboardController.performAction(
                    EDashboardActions.ARCHIVE, 'ab', EStatusRepo.SUBMITTED, roundKeys, undefined, 'user'
                )
                dashboardService.archiveCountry.called.should.be.true
                result.updatedRow.lastChangeDate.should.equal('2020-04-01')
                result.result.should.equal(1)
                result.updatedRow.lastChangeUser.should.equal('changeUser')
                result.updatedRow.data.DFM.should.eql(
                    {statusDescr: 'new status', statusId: 'statusId'}
                )
            })
        })
    })
})
