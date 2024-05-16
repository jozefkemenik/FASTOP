import 'chai/register-should.js'
import * as sinon from 'sinon'
import { should } from 'chai'

import { CountryStatusApi, DashboardApi, EucamLightApi, NotificationApi } from '../../../lib/dist/api'
import { DashboardController } from '../../src/dashboard/dashboard.controller'
import { DashboardService } from '../../src/dashboard/dashboard.service'
import { EApps } from 'config'
import { EDashboardActions } from '../../../shared-lib/dist/prelib/dashboard'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { ENotificationTemplate } from 'notification'
import { EStatusRepo } from 'country-status'
import { ForecastType } from '../../src/forecast/shared-interfaces'
import { LoggingService } from '../../../lib/dist'
import { SharedService } from '../../src/shared/shared.service'

const allStatuses = [
    EStatusRepo.ACTIVE, EStatusRepo.OPENED, EStatusRepo.CLOSED, EStatusRepo.SUBMITTED, EStatusRepo.ARCHIVED,
    EStatusRepo.PUBLISHED, EStatusRepo.TR_OPENED, EStatusRepo.TR_SUBMITTED, EStatusRepo.TR_PUBLISHED,
    EStatusRepo.VALIDATED, EStatusRepo.ACCEPTED, EStatusRepo.REJECTED, EStatusRepo.ST_CLOSED
]

const invalidFdmsActions = [
    EDashboardActions.TR_SUBMIT, EDashboardActions.TR_UNSUBMIT, EDashboardActions.VALIDATE,
    EDashboardActions.UNVALIDATE, EDashboardActions.ARCHIVE
]

function getActionStatuses(
    action: EDashboardActions, statuses: EStatusRepo[], exclude: boolean, newStatusId: EStatusRepo = undefined
) {
    const filteredStatuses = exclude ? allStatuses.filter(s => !statuses.includes(s)) : statuses
    return filteredStatuses.map(status => ({ action, status, newStatusId }))
}

describe('DashboardController test suite', function() {

    const appId = EApps.FDMS
    const loggingServiceStub = sinon.createStubInstance(LoggingService)
    const dashboardServiceStub = sinon.createStubInstance(DashboardService)
    const sharedServiceStub = sinon.createStubInstance(SharedService)

    const dashboardController = new DashboardController(appId, loggingServiceStub, dashboardServiceStub, sharedServiceStub)

    afterEach(function() {
        dashboardServiceStub.getCountryUploads.reset()
        dashboardServiceStub.transferAmecoIndicatorsToScopax.reset()
        sharedServiceStub.isOgFull.reset()
    })

    describe('getCountryLastAccepted method', function() {

        let getCountryLastAcceptedStub

        beforeEach(function() {
            getCountryLastAcceptedStub = sinon.stub(CountryStatusApi, 'getCountryLastAccepted')
        })

        afterEach(function() {
            getCountryLastAcceptedStub.restore()
        })

        it('should return empty map', async function() {
            // given
            const userCountries = ['BE', 'PL', 'MT']

            // when
            const lastAcceptedCountries = await dashboardController.getCountryLastAccepted(
                appId, userCountries, true, true
            )

            // then
            should().equal(lastAcceptedCountries.size, 0)
            getCountryLastAcceptedStub.called.should.be.false
        })

        it('should return last accepted countries', async function() {
            // given
            const userCountries = ['BE']
            const beLastAccepted = {
                countryId: 'BE',
                lastAcceptedDate: '2021-01-02',
                roundSid: 683,
                storageSid: 2,
            }
            getCountryLastAcceptedStub.resolves([beLastAccepted])

            // when
            const lastAcceptedCountries = await dashboardController.getCountryLastAccepted(
                EApps.FDMSIE, userCountries, true, true
            )

            // then
            should().equal(lastAcceptedCountries.size, 1)
            should().equal(lastAcceptedCountries.get('BE'), beLastAccepted)
            getCountryLastAcceptedStub.calledWithExactly(EApps.FDMS, userCountries, true, true).should.be.true
        })
    })

    describe('getDashboard method', function() {

        // test data
        const aggRoundInfo = {
            roundSid: 9876,
            year: 2022,
            roundDescr: 'SUM 2022',
            periodDescr: 'Summer',
            periodId: 'SUM',
            storageSid: 3,
            storageDescr: 'Second storage',
            storageId: 'SECOND',
            version: 2,
        }

        const beLastUpdateDate = new Date('2022-02-04')
        const frLastUpdateDate = new Date('2022-05-03')
        const lastAcceptedDateStr = new Date('2022-09-12').toLocaleString()

        // stubs
        let getCountryStatusesStub
        let getCountryLastAcceptedStub
        let getEucamLightVersionFormattedStub
        let getRoundInfoStub

        beforeEach(function() {
            getCountryStatusesStub = sinon.stub(CountryStatusApi, 'getCountryStatuses').resolves([
                {
                    countryId: 'BE',
                    countryDescr: 'Belgium',
                    lastChangeDate: '2022-02-07',
                    lastChangeUser: 'zelensky',
                    statusSid: 3,
                    statusId: EStatusRepo.OPENED,
                    statusDescr: 'Open',
                    statusTrDescr: 'TR Open',
                },
                {
                    countryId: 'FR',
                    countryDescr: 'France',
                    lastChangeDate: '2022-08-05',
                    lastChangeUser: 'drulez',
                    statusSid: 2,
                    statusId: EStatusRepo.ACCEPTED,
                    statusDescr: 'Accepted',
                    statusTrDescr: 'TR accepted',
                }
            ])
            getCountryLastAcceptedStub = sinon.stub(CountryStatusApi, 'getCountryLastAccepted').resolves([{
                countryId: 'AGG',
                lastAcceptedDate: lastAcceptedDateStr,
                roundSid: aggRoundInfo.roundSid,
                storageSid: aggRoundInfo.storageSid,
            }])

            getEucamLightVersionFormattedStub = sinon.stub(EucamLightApi, 'getEucamLightVersionFormatted').resolves(
                ['Eucam-Light', '1.0.2 Final version Spring 2022']
            )
            getRoundInfoStub = sinon.stub(DashboardApi, 'getRoundInfo').resolves(aggRoundInfo)

            dashboardServiceStub.getCountryUploads.resolves([
                { COUNTRY_ID: 'BE', UPDATE_DATE: beLastUpdateDate },
                { COUNTRY_ID: 'FR', UPDATE_DATE: frLastUpdateDate },
                { COUNTRY_ID: 'MT', UPDATE_DATE: new Date('2022-04-08') },
            ])
        })

        afterEach(function() {
            getCountryStatusesStub.restore()
            getCountryLastAcceptedStub.restore()
            getEucamLightVersionFormattedStub.restore()
            getRoundInfoStub.restore()
            dashboardServiceStub.getCountryUploads.reset()
        })

        it('should return empty list when user has no country assigned', async function() {
            // when
            const dashboard = await dashboardController.getDashboard(false, [])

            // then
            dashboard.should.be.eql({ countries: [], rows: {} })
            getCountryStatusesStub.called.should.be.false
            getCountryLastAcceptedStub.called.should.be.false
            getEucamLightVersionFormattedStub.called.should.be.false
            getRoundInfoStub.called.should.be.false
            dashboardServiceStub.getCountryUploads.called.should.be.false
        })

        it('should return all countries for admin user', async function() {
            // given
            const userCountries = ['AT', 'PL']

            // when
            const dashboard = await dashboardController.getDashboard(true, userCountries)

            // then
            dashboard.should.be.eql({
                countries: [
                    { countryId: 'BE', countryDescr: 'Belgium' },
                    { countryId: 'FR', countryDescr: 'France' }
                ],
                rows: {
                    'BE': {
                        lastChangeDate: '2022-02-07', lastChangeUser: 'zelensky',
                        data: { currentStatus: { statusDescr: 'Open', statusId: 'OPEN' } },
                        changesLog: { lastUploadDate: beLastUpdateDate, lastAcceptedDate: undefined }
                    },
                    'FR': {
                        lastChangeDate: '2022-08-05', lastChangeUser: 'drulez',
                        data: { currentStatus: { statusDescr: 'Accepted', statusId: 'ACCEPTED' } },
                        changesLog: { lastUploadDate: frLastUpdateDate, lastAcceptedDate: undefined }
                    }
                },
                globals: [
                    [ 'Last accepted forecast aggregation',
                       `SUMMER 2022 Second storage | ${new Date(lastAcceptedDateStr).toLocaleString()}`
                    ],
                    [ 'Eucam-Light', '1.0.2 Final version Spring 2022' ]
                ]
            })
            getCountryStatusesStub.calledWithExactly(appId, []).should.be.true
            getCountryLastAcceptedStub.calledOnceWithExactly(EApps.FDMS, ['AGG'], true, true).should.be.true
            getRoundInfoStub.calledWithExactly(EApps.FDMS, aggRoundInfo.roundSid, aggRoundInfo.storageSid).should.be.true
            dashboardServiceStub.getCountryUploads.calledWithExactly(appId, []).should.be.true
            getEucamLightVersionFormattedStub.calledOnce.should.be.true
        })

        it('should return user countries for non admin user', async function() {
            // given
            const userCountries = ['BE', 'FR']

            // when
            const dashboard = await dashboardController.getDashboard(false, userCountries)

            // then
            dashboard.should.be.eql({
                countries: [
                    { countryId: 'BE', countryDescr: 'Belgium' },
                    { countryId: 'FR', countryDescr: 'France' }
                ],
                rows: {
                    'BE': {
                        lastChangeDate: '2022-02-07', lastChangeUser: 'zelensky',
                        data: { currentStatus: { statusDescr: 'Open', statusId: 'OPEN' } },
                        changesLog: { lastUploadDate: beLastUpdateDate, lastAcceptedDate: undefined }
                    },
                    'FR': {
                        lastChangeDate: '2022-08-05', lastChangeUser: 'drulez',
                        data: { currentStatus: { statusDescr: 'Accepted', statusId: 'ACCEPTED' } },
                        changesLog: { lastUploadDate: frLastUpdateDate, lastAcceptedDate: undefined }
                    }
                },
                globals: [
                    [ 'Last accepted forecast aggregation',
                      `SUMMER 2022 Second storage | ${new Date(lastAcceptedDateStr).toLocaleString()}`
                    ],
                    [ 'Eucam-Light', '1.0.2 Final version Spring 2022' ]
                ]
            })
            getCountryStatusesStub.calledWithExactly(appId, userCountries).should.be.true
            getCountryLastAcceptedStub.calledOnceWithExactly(EApps.FDMS, ['AGG'], true, true).should.be.true
            getRoundInfoStub.calledWithExactly(EApps.FDMS, aggRoundInfo.roundSid, aggRoundInfo.storageSid).should.be.true
            dashboardServiceStub.getCountryUploads.calledWithExactly(appId, ['BE', 'FR']).should.be.true
            getEucamLightVersionFormattedStub.calledOnce.should.be.true
        })

        it('should not return eucam light version when exception thrown', async function() {
            // given
            const userCountries = ['BE', 'FR']
            getEucamLightVersionFormattedStub.restore()
            getEucamLightVersionFormattedStub = sinon.stub(
                EucamLightApi, 'getEucamLightVersionFormatted'
            ).rejects('Error')

            // when
            const dashboard = await dashboardController.getDashboard(false, userCountries)

            // then
            dashboard.should.be.eql({
                countries: [
                    { countryId: 'BE', countryDescr: 'Belgium' },
                    { countryId: 'FR', countryDescr: 'France' }
                ],
                rows: {
                    'BE': {
                        lastChangeDate: '2022-02-07', lastChangeUser: 'zelensky',
                        data: { currentStatus: { statusDescr: 'Open', statusId: 'OPEN' } },
                        changesLog: { lastUploadDate: beLastUpdateDate, lastAcceptedDate: undefined }
                    },
                    'FR': {
                        lastChangeDate: '2022-08-05', lastChangeUser: 'drulez',
                        data: { currentStatus: { statusDescr: 'Accepted', statusId: 'ACCEPTED' } },
                        changesLog: { lastUploadDate: frLastUpdateDate, lastAcceptedDate: undefined }
                    }
                },
                globals: [
                    [ 'Last accepted forecast aggregation',
                      `SUMMER 2022 Second storage | ${new Date(lastAcceptedDateStr).toLocaleString()}`
                    ],
                ]
            })
            getCountryStatusesStub.calledWithExactly(appId, userCountries).should.be.true
            getCountryLastAcceptedStub.calledOnceWithExactly(EApps.FDMS, ['AGG'], true, true).should.be.true
            getRoundInfoStub.calledWithExactly(EApps.FDMS, aggRoundInfo.roundSid, aggRoundInfo.storageSid).should.be.true
            dashboardServiceStub.getCountryUploads.calledWithExactly(appId, ['BE', 'FR']).should.be.true
            getEucamLightVersionFormattedStub.calledOnce.should.be.true
        })
    })

    describe('presubmitCheck method', function() {

        it('should return always zero', async function() {
            // when
            const result = await dashboardController.presubmitCheck('PL', 244)

            // then
            result.should.be.eql(0)
        })
    })

    describe('performMultiAction method', function() {

        // test data
        const countryIds = ['BE', 'PL']
        const currentRoundInfo = {
            roundSid: 753,
            year: 2022,
            roundDescr: 'SUM 2022',
            periodDescr: 'Summmer',
            periodId: 'SUM',
            storageSid: 6,
            storageDescr: 'Final storage',
            storageId: 'FINAL',
            textSid: undefined,
            textTitle: undefined,
            textDescr: undefined,
            version: 3,
        }
        const roundKeys = {
            roundSid: currentRoundInfo.roundSid,
            storageSid: currentRoundInfo.storageSid,
            storageId: currentRoundInfo.storageId,
            custTextSid: currentRoundInfo.textSid,
        }
        const comment = 'Test comment'
        const userId = 'bravoj'
        const appId = EApps.FDMS
        const countryStatutes = [
            {
                countryId: 'BE',
                countryDescr: 'Belgium',
                lastChangeDate: '2022-02-07',
                lastChangeUser: 'zelensky',
                statusSid: 3,
                statusId: EStatusRepo.OPENED,
                statusDescr: 'Open',
                statusTrDescr: 'TR Open',
            },
            {
                countryId: 'PL',
                countryDescr: 'Poland',
                lastChangeDate: '2022-08-05',
                lastChangeUser: 'drulez',
                statusSid: 2,
                statusId: EStatusRepo.ACCEPTED,
                statusDescr: 'Accepted',
                statusTrDescr: 'TR accepted',
            }
        ]

        // stubs
        let getApplicationStatusStub
        let getCurrentRoundInfoStub
        let getCountryStatusesStub
        let setManyCountriesStatus

        beforeEach(function() {
            getApplicationStatusStub = sinon.stub(DashboardApi, 'getApplicationStatus')
            getCurrentRoundInfoStub = sinon.stub(DashboardApi, 'getCurrentRoundInfo').resolves(currentRoundInfo)
            getCountryStatusesStub = sinon.stub(CountryStatusApi, 'getCountryStatuses')
            setManyCountriesStatus = sinon.stub(CountryStatusApi, 'setManyCountriesStatus')
        })

        afterEach(function() {
            getApplicationStatusStub.restore()
            getCurrentRoundInfoStub.restore()
            getCountryStatusesStub.restore()
            setManyCountriesStatus.restore()
        })

        it('should return NO_COUNTRIES error', async function() {
            // when
            const result = await dashboardController.performMultiAction(EDashboardActions.ACCEPT, [], null, null, null)

            // then
            result.should.be.eql(EErrors.NO_COUNTRIES)
        })

        invalidFdmsActions.forEach(function(action) {
            it(`should return CTY_ACTION error when action is ${action}`, async function() {
                // when
                const result = await dashboardController.performMultiAction(action, ['BE'], null, null, null)

                // then
                result.should.be.eql(EErrors.CTY_ACTION)
            })
        })

        const notOpenStatues = allStatuses.filter(s => s != EStatusRepo.OPENED)
        notOpenStatues.forEach(function(status) {
            it(`should return APP_STATUS error when application is ${status}`, async function() {
                // given
                getApplicationStatusStub.resolves(status)
                getCountryStatusesStub.resolves(countryStatutes)

                // when
                const result = await dashboardController.performMultiAction(
                    EDashboardActions.ACCEPT, countryIds, roundKeys,  comment, userId
                )

                // then
                result.should.be.eql(EErrors.APP_STATUS)
                getApplicationStatusStub.calledWithExactly(appId).should.be.true
                getCurrentRoundInfoStub.calledWithExactly(appId).should.be.true
                getCountryStatusesStub.calledWithExactly(appId, countryIds, roundKeys).should.be.true
            })
        })

        it('should return error when roundSid is different', async function() {
            // given
            const requestedRoundKeys = Object.assign({}, roundKeys, { roundSid: 123 })
            getApplicationStatusStub.resolves(EStatusRepo.OPENED)
            getCountryStatusesStub.resolves(countryStatutes)

            // when
            const result = await dashboardController.performMultiAction(
                EDashboardActions.ACCEPT, countryIds, requestedRoundKeys,  comment, userId
            )

            // then
            result.should.be.eql(EErrors.ROUND_KEYS)
            getApplicationStatusStub.calledWithExactly(appId).should.be.true
            getCurrentRoundInfoStub.calledWithExactly(appId).should.be.true
            getCountryStatusesStub.calledWithExactly(appId, countryIds, requestedRoundKeys).should.be.true
        })

        it('should return error when storageSid is different', async function() {
            // given
            const requestedRoundKeys = Object.assign({}, roundKeys, { storageSid: 1 })
            getApplicationStatusStub.resolves(EStatusRepo.OPENED)
            getCountryStatusesStub.resolves(countryStatutes)

            // when
            const result = await dashboardController.performMultiAction(
                EDashboardActions.ACCEPT, countryIds, requestedRoundKeys,  comment, userId
            )

            // then
            result.should.be.eql(EErrors.ROUND_KEYS)
            getApplicationStatusStub.calledWithExactly(appId).should.be.true
            getCurrentRoundInfoStub.calledWithExactly(appId).should.be.true
            getCountryStatusesStub.calledWithExactly(appId, countryIds, requestedRoundKeys).should.be.true
        })

        const ctyStatusErrorTest = []
            .concat(
                getActionStatuses(EDashboardActions.SUBMIT, [EStatusRepo.ACTIVE, EStatusRepo.REJECTED], true)
            ).concat(
                getActionStatuses(EDashboardActions.UNSUBMIT, [EStatusRepo.SUBMITTED], true)
            ).concat(
                getActionStatuses(EDashboardActions.ACCEPT, [EStatusRepo.SUBMITTED], true)
            ).concat(
                getActionStatuses(EDashboardActions.UNACCEPT, [EStatusRepo.ACCEPTED, EStatusRepo.SUBMITTED], true)
            ).concat(
                getActionStatuses(EDashboardActions.REJECT, [EStatusRepo.SUBMITTED], true)
            )

        ctyStatusErrorTest.forEach(function(test) {
            it(`should return CTY_STATUS error when action: ${test.action}, status: ${test.status}`, async function() {
                // given
                const testCountryIds = ['BE']
                getApplicationStatusStub.resolves(EStatusRepo.OPENED)
                getCountryStatusesStub.resolves([
                    {
                        countryId: 'BE',
                        countryDescr: 'Belgium',
                        lastChangeDate: '2022-02-07',
                        lastChangeUser: 'zelensky',
                        statusSid: 3,
                        statusId: test.status,
                        statusDescr: `Status ${test.status}`,
                        statusTrDescr: `TR status ${test.status}`,
                    },
                ])

                // when
                const result = await dashboardController.performMultiAction(
                    test.action, testCountryIds, roundKeys,  comment, userId
                )

                // then
                result.should.be.eql(EErrors.CTY_STATUS)
                getApplicationStatusStub.calledWithExactly(appId).should.be.true
                getCurrentRoundInfoStub.calledWithExactly(appId).should.be.true
                getCountryStatusesStub.calledWithExactly(appId, testCountryIds, roundKeys).should.be.true
            })
        })

        const ctyStatusSuccessTest = []
            .concat(
                getActionStatuses(
                    EDashboardActions.SUBMIT, [EStatusRepo.ACTIVE, EStatusRepo.REJECTED], false, EStatusRepo.SUBMITTED
                )
            ).concat(
                getActionStatuses(
                    EDashboardActions.UNSUBMIT, [EStatusRepo.SUBMITTED], false, EStatusRepo.ACTIVE
                )
            ).concat(
                getActionStatuses(
                    EDashboardActions.ACCEPT, [EStatusRepo.SUBMITTED], false, EStatusRepo.ACCEPTED
                )
            ).concat(
                getActionStatuses(
                    EDashboardActions.UNACCEPT, [EStatusRepo.ACCEPTED, EStatusRepo.SUBMITTED], false, EStatusRepo.ACTIVE
                )
            ).concat(
                getActionStatuses(
                    EDashboardActions.REJECT, [EStatusRepo.SUBMITTED], false, EStatusRepo.REJECTED
                )
            )
        const aggCountries = ['AGG', 'AGGIE', 'TCE', 'BE', 'PL']

        ctyStatusSuccessTest.forEach(function(test) {
            aggCountries.forEach(function(countryId) {
                it(
                    `should update country: ${countryId} status when action: ${test.action}, status: ${test.status}`,
                    async function() {
                            // given
                            const testCountryIds = [countryId]
                            getApplicationStatusStub.resolves(EStatusRepo.OPENED)
                            setManyCountriesStatus.resolves(1)
                            getCountryStatusesStub.resolves([
                                {
                                    countryId,
                                    countryDescr: `Country ${countryId}`,
                                    lastChangeDate: '2022-02-07',
                                    lastChangeUser: 'zelensky',
                                    statusSid: 3,
                                    statusId: test.status,
                                    statusDescr: `Status ${test.status}`,
                                    statusTrDescr: `TR status ${test.status}`,
                                },
                            ])

                            // when
                            const result = await dashboardController.performMultiAction(
                                test.action, testCountryIds, roundKeys,  comment, userId
                            )

                            // then
                            result.should.be.eql(1)
                            getApplicationStatusStub.calledWithExactly(appId).should.be.true
                            getCurrentRoundInfoStub.calledWithExactly(appId).should.be.true
                            getCountryStatusesStub.calledWithExactly(appId, testCountryIds, roundKeys).should.be.true
                            setManyCountriesStatus.calledWithExactly(
                                appId, testCountryIds,
                                { oldStatusId: null, newStatusId: test.newStatusId, roundKeys, userId, comment, }
                            )
                })
            })
        })
    })

    describe('performAction method', function() {

        // test data
        const countryId = 'AGG'
        const comment = 'Accepted ameco indicators'
        const userId = 'palovv'
        const currentRoundInfo = {
            roundSid: 753,
            year: 2022,
            roundDescr: 'SUM 2022',
            periodDescr: 'Summmer',
            periodId: 'SUM',
            storageSid: 6,
            storageDescr: 'Final storage',
            storageId: 'FINAL',
            textSid: undefined,
            textTitle: undefined,
            textDescr: undefined,
            version: 1,
        }
        const countryStatusResult = {
            result: 55,
            countryStatus: {
                countryId: 'AGG',
                countryDescr: 'Aggregates',
                lastChangeDate: '2022-05-31',
                lastChangeUser: 'kogutm',
                statusSid: 3,
                statusId: EStatusRepo.SUBMITTED,
                statusDescr: 'Submitted',
                statusTrDescr: 'TR submitted',
            }
        }
        const roundKeys = {
            roundSid: currentRoundInfo.roundSid,
            storageSid: currentRoundInfo.storageSid,
            storageId: currentRoundInfo.storageId,
            custTextSid: currentRoundInfo.textSid,
        }

        // stubs
        let getApplicationStatusStub
        let getCurrentRoundInfoStub
        let setCountryStatusStub
        let sendCnsNotificationStub


        beforeEach(function() {
            getApplicationStatusStub = sinon.stub(DashboardApi, 'getApplicationStatus').resolves(EStatusRepo.OPENED)
            getCurrentRoundInfoStub = sinon.stub(DashboardApi, 'getCurrentRoundInfo').resolves(currentRoundInfo)
            setCountryStatusStub = sinon.stub(CountryStatusApi, 'setCountryStatus').resolves(countryStatusResult)
            sendCnsNotificationStub = sinon.stub(NotificationApi, 'sendCnsNotificationWithTemplate').resolves()
        })

        afterEach(function() {
            getApplicationStatusStub.restore()
            getCurrentRoundInfoStub.restore()
            setCountryStatusStub.restore()
            dashboardServiceStub.transferAmecoIndicatorsToScopax.reset()
            sharedServiceStub.isOgFull.reset()
            sharedServiceStub.markForecast.reset()
            sendCnsNotificationStub.restore()
        })

        it('should transfer AGG ameco indicators when full OG results', async function() {
            // given
            sharedServiceStub.isOgFull.resolves(true)
            sharedServiceStub.markForecast.resolves()
            dashboardServiceStub.transferAmecoIndicatorsToScopax.resolves(3)

            // when
            const result = await dashboardController.performAction(
                EDashboardActions.ACCEPT, countryId, EStatusRepo.SUBMITTED, roundKeys, comment, userId, true
            )

            // then
            result.should.be.eql({
                result: 55,
                updatedRow: {
                    lastChangeDate: '2022-05-31',
                    lastChangeUser: 'kogutm',
                    canSubmit: true,
                    data: {
                        currentStatus: {
                            statusDescr: 'Submitted',
                            statusId: EStatusRepo.SUBMITTED
                        }
                    }
                }
            })
            sharedServiceStub.isOgFull.calledWithExactly('EA19', roundKeys.roundSid, roundKeys.storageSid).should.be.true
            sharedServiceStub.markForecast.calledOnceWithExactly(ForecastType.LATEST_AGGREGATES, userId).should.be.true
            dashboardServiceStub.transferAmecoIndicatorsToScopax.calledWithExactly(
                roundKeys.roundSid, roundKeys.storageSid
            ).should.be.true
            sendCnsNotificationStub.calledWithExactly(
                ENotificationTemplate.FDMS_AGGREGATES_ACCEPTATION,
                {
                    notificationGroupCode: 'FC_NEW_ROUND_STORAGE',
                    params: {
                        '{ROUND_DESC}': currentRoundInfo.roundDescr,
                        '{STORAGE_DESC}': currentRoundInfo.storageDescr,
                    }
                },
                userId, appId, true
            ).should.be.true
        })

        it('should not transfer AGG ameco indicators when approximate OG results', async function() {
            // given
            sharedServiceStub.isOgFull.resolves(false)
            sharedServiceStub.markForecast.resolves()

            // when
            const result = await dashboardController.performAction(
                EDashboardActions.ACCEPT, countryId, EStatusRepo.SUBMITTED, roundKeys, comment, userId, true
            )

            // then
            result.should.be.eql({
                result: 55,
                updatedRow: {
                    lastChangeDate: '2022-05-31',
                    lastChangeUser: 'kogutm',
                    canSubmit: true,
                    data: {
                        currentStatus: {
                            statusDescr: 'Submitted',
                            statusId: EStatusRepo.SUBMITTED
                        }
                    }
                }
            })
            sharedServiceStub.isOgFull.calledWithExactly('EA19', roundKeys.roundSid, roundKeys.storageSid).should.be.true
            sharedServiceStub.markForecast.calledOnceWithExactly(ForecastType.LATEST_AGGREGATES, userId).should.be.true
            dashboardServiceStub.transferAmecoIndicatorsToScopax.called.should.be.false
            sendCnsNotificationStub.calledWithExactly(
                ENotificationTemplate.FDMS_AGGREGATES_ACCEPTATION,
                {
                    notificationGroupCode: 'FC_NEW_ROUND_STORAGE',
                    params: {
                        '{ROUND_DESC}': currentRoundInfo.roundDescr,
                        '{STORAGE_DESC}': currentRoundInfo.storageDescr,
                    }
                },
                userId, appId, true
            ).should.be.true
        })
    })
})
