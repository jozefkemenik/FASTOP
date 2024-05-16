import 'chai/register-should.js'
import * as sinon from 'sinon'
import { should } from 'chai'

import { IUserAuthzs } from '../src/user'
import { LoggingService } from '../../lib/dist'
import { UserController } from '../src/user/user.controller'
import { UserService } from '../src/user/user.service'
import { config } from '../../config/config'


describe('UserController test suite', function() {

    let userServiceStub
    let userController: UserController

    beforeEach(function() {
        userServiceStub = sinon.createStubInstance(UserService)
        userController = new UserController(userServiceStub, sinon.createStubInstance(LoggingService))
    })

    describe('getUserAuthzs', function() {

        const userId = 'xyz'
        const unit = 'ECFIN.D.3'

        after(function() {
            config.secunda.useUM = false
        })

        it('should get user authorizations from user management', async function() {
            // given
            config.secunda.useUM = true
            const dbAuthz = [
                { APP_ID: 'DFM', ROLE_ID: 'CTY_DESK', LDAP_LOGIN: userId, COUNTRIES: 'PL,BE,FR'},
                { APP_ID: 'DFM', ROLE_ID: 'B1', LDAP_LOGIN: userId, COUNTRIES: 'MT'},
                { APP_ID: 'FDMS', ROLE_ID: 'SU', LDAP_LOGIN: userId, COUNTRIES: ''},
            ]
            userServiceStub.getUserAuthzsUM.resolves(dbAuthz)

            // when
            const result = await userController.getUserAuthzs(userId, unit)

            // then
            result.should.be.eql({
                DFM: [{ groupId: 'CTY_DESK', countries: ['PL','BE','FR'] }, { groupId: 'B1', countries: ['MT'] }],
                FDMS: [{ groupId: 'SU', countries: [''] }]
            })
            userServiceStub.getUserAuthzsUM.calledOnceWithExactly(userId, unit).should.be.true
        })

        it('should get empty authorization from secunda when no token', async function() {
            // given
            config.secunda.useUM = false
            userServiceStub.getToken.resolves(undefined)

            // when
            const result = await userController.getUserAuthzs(userId, unit)

            // then
            should().not.exist(result)
            userServiceStub.getUserAuthzsUM.called.should.be.false
            userServiceStub.getToken.calledOnce.should.be.true
        })

        it('should get authorization from secunda', async function() {
            // given
            config.secunda.useUM = false
            const token = {
                access_token: 'dsjfhajsh233',
                scope: 'default',
                token_type: 'Bearer',
                expires_is: 9
            }
            userServiceStub.getToken.resolves(token)
            userServiceStub.getSecundaRoles.withArgs(token, userId).resolves([
                {userId, roleId: 'GBD-CTY_DESK'},
                {userId, roleId: 'AUXTOOLS-PUBLIC'},
                {userId, roleId: 'AMECO-ADMIN'},
                {userId, roleId: 'AUXTOOLS-SU'},
                {userId, roleId: 'DFM-PUBLIC'},
                {userId, roleId: 'IFI-CTY_DESK'},
            ])
            userServiceStub.getSecundaRoles.withArgs(token, userId, 'GBD-CTY_DESK', 'GBD').resolves([
                { userId,
                  roleId: 'GBD-CTY_DESK',
                  scopes: { EU_Member_States: ['COUNTRY/FR','COUNTRY/HU','COUNTRY/DK'], EU_Candidate_Countries: [] }
                }
            ])
            userServiceStub.getSecundaRoles.withArgs(token, userId, 'AUXTOOLS-PUBLIC', 'AUXTOOLS').resolves([
                { userId,
                    roleId: 'AUXTOOLS-PUBLIC',
                    scopes: { EU_Member_States: ['COUNTRY/PL'], EU_Candidate_Countries: ['COUNTRY/UA'] }
                }
            ])
            userServiceStub.getSecundaRoles.withArgs(token, userId, 'AMECO-ADMIN', 'AMECO').resolves([
                { userId,
                    roleId: 'AMECO-ADMIN',
                    scopes: { EU_Member_States: ['COUNTRY/BE','COUNTRY/DE'], EU_Candidate_Countries: [] }
                }
            ])
            userServiceStub.getSecundaRoles.withArgs(token, userId, 'AUXTOOLS-SU', 'AUXTOOLS').resolves([
                { userId,
                    roleId: 'AUXTOOLS-SU',
                    scopes: { EU_Member_States: [], EU_Candidate_Countries: ['COUNTRY/UA/XX','COUNTRY/MD/YY'] }
                }
            ])
            userServiceStub.getSecundaRoles.withArgs(token, userId, 'DFM-PUBLIC', 'DFM').resolves([
                { userId, roleId: 'DFM-PUBLIC', }
            ])
            userServiceStub.getSecundaRoles.withArgs(token, userId, 'IFI-CTY_DESK', 'IFI').resolves([
                { userId,
                    roleId: 'IFI-CTY_DESK',
                    scopes: { EU_Member_States: ['COUNTRY/BE/10/AA','COUNTRY/PL/44/BB'], EU_Candidate_Countries: [] }
                }
            ])

            // when
            const result = await userController.getUserAuthzs(userId, unit)

            // then
            result.should.be.eql({
                GBD: [{ groupId: 'CTY_DESK', countries: ['FR','HU','DK'] }],
                AUXTOOLS: [
                    { groupId: 'PUBLIC', countries: ['PL','UA'] },
                    { groupId: 'SU', countries: ['UA','MD'] }
                ],
                AMECO: [{ groupId: 'ADMIN', countries: ['BE','DE']}],
                DFM: [{ groupId: 'PUBLIC', countries: []}],
                IFI: [{ groupId: 'CTY_DESK', countries: ['BE/10', 'PL/44']}],
            })
            userServiceStub.getUserAuthzsUM.called.should.be.false
            userServiceStub.getToken.calledOnce.should.be.true
        })
    })

    describe('getUserApps', function() {

        const allAuthz: IUserAuthzs = {
            DFM: [ { groupId: 'CTY_DESK', countries: ['PL', 'BE'] }],
            FDMS: [ { groupId: 'ADMIN', countries: ['FR'] }, { groupId: 'ADMIN-EXT', countries: ['DE'] }],
            DBP: [ { groupId: 'PUBLIC', countries: [] } ],
            SCP: [ { groupId: 'SU', countries: [] }]
        }

        it('should return all applications', async function() {
            // given
            userServiceStub.getFastopApps.resolves([
                {
                    APP_GROUP: 'Fastop',
                    SUBGROUP: 'Fiscal surveillance',
                    GROUP_ORDER: 1,
                    SUBGROUP_ORDER: 2,
                    APP_NAME: 'DFM',
                    APP_DESCR: 'DFM App',
                    APP_LINK: null,
                    ROUTE_DESCR: null,
                    ROUTE: null,
                    ROUTE_ROLES: null,
                },
            ])

            // when
            const result = await userController.getUserApps(true, allAuthz)

            // then
            result.should.be.eql([
                { name: 'Fastop',
                  subgroups: [
                      { name: 'Fiscal surveillance', order: 2,
                        apps :[{ id: 'DFM', descr: 'DFM App', link: null, routeDescr: null, route: null }]
                      }
                  ]
                }
            ])
            userServiceStub.getFastopApps.calledOnceWithExactly(true).should.be.true
        })

        it('should return route link when user has admin role', async function() {
            // given
            userServiceStub.getFastopApps.resolves([
                {
                    APP_GROUP: 'Fastop',
                    SUBGROUP: 'Fiscal surveillance',
                    GROUP_ORDER: 1,
                    SUBGROUP_ORDER: 2,
                    APP_NAME: 'DFM',
                    APP_DESCR: 'DFM App',
                    APP_LINK: null,
                    ROUTE_DESCR: null,
                    ROUTE: null,
                    ROUTE_ROLES: null,
                },
                {
                    APP_GROUP: 'Fastop',
                    SUBGROUP: 'Forecast',
                    GROUP_ORDER: 1,
                    SUBGROUP_ORDER: 3,
                    APP_NAME: 'FDMS',
                    APP_DESCR: 'FDMS App',
                    APP_LINK: null,
                    ROUTE_DESCR: 'Aggregates',
                    ROUTE: 'tools/aggregates',
                    ROUTE_ROLES: 'ADMIN,CTY_DESK',
                }
            ])

            // when
            const result = await userController.getUserApps(true, allAuthz)

            // then
            result.should.be.eql([
                { name: 'Fastop',
                  subgroups: [
                      { name: 'Fiscal surveillance', order: 2,
                        apps: [
                            { id: 'DFM', descr: 'DFM App', link: null, routeDescr: null, route: null }
                        ]
                      },
                      { name: 'Forecast', order: 3,
                        apps: [
                            { id: 'FDMS', descr: 'FDMS App', link: null, routeDescr: 'Aggregates', route: 'tools/aggregates'}
                        ]
                      }
                  ]
                }
            ])
            userServiceStub.getFastopApps.calledOnceWithExactly(true).should.be.true
        })

        it('should not return route link when user has no admin role ', async function() {
            // given
            userServiceStub.getFastopApps.resolves([
                {
                    APP_GROUP: 'Fastop',
                    SUBGROUP: 'Fiscal surveillance',
                    GROUP_ORDER: 1,
                    SUBGROUP_ORDER: 2,
                    APP_NAME: 'DFM',
                    APP_DESCR: 'DFM App',
                    APP_LINK: 'http://rp.pl',
                    ROUTE_DESCR: null,
                    ROUTE: null,
                    ROUTE_ROLES: null,
                },
                {
                    APP_GROUP: 'Fastop',
                    SUBGROUP: 'Fiscal surveillance',
                    GROUP_ORDER: 1,
                    SUBGROUP_ORDER: 2,
                    APP_NAME: 'DFM',
                    APP_DESCR: 'DFM App',
                    APP_LINK: null,
                    ROUTE_DESCR: 'Aggregates',
                    ROUTE: 'tools/aggregates',
                    ROUTE_ROLES: 'ADMIN,B1',
                },
            ])

            // when
            const result = await userController.getUserApps(false, allAuthz)

            // then
            result.should.be.eql([
                { name: 'Fastop',
                  subgroups: [
                      { name: 'Fiscal surveillance', order: 2,
                        apps: [ { id: 'DFM', descr: 'DFM App', link: 'http://rp.pl', routeDescr: null, route: null }]
                      }
                  ]
                }
            ])
            userServiceStub.getFastopApps.calledOnceWithExactly(false).should.be.true
        })

        it('should return route that requires no roles', async function() {
            // given
            userServiceStub.getFastopApps.resolves([
                {
                    APP_GROUP: 'Fastop',
                    SUBGROUP: 'Forecast',
                    GROUP_ORDER: 1,
                    SUBGROUP_ORDER: 3,
                    APP_NAME: 'FDMS',
                    APP_DESCR: 'FDMS App',
                    APP_LINK: null,
                    ROUTE_DESCR: 'Aggregates',
                    ROUTE: 'tools/aggregates',
                    ROUTE_ROLES: null,
                }
            ])

            // when
            const result = await userController.getUserApps(false, allAuthz)

            // then
            result.should.be.eql([
                { name: 'Fastop',
                    subgroups: [
                        { name: 'Forecast', order: 3,
                            apps: [
                                { id: 'FDMS', descr: 'FDMS App', link: null, routeDescr: 'Aggregates', route: 'tools/aggregates'}
                            ]
                        }
                    ]
                }
            ])
            userServiceStub.getFastopApps.calledOnceWithExactly(false).should.be.true
        })

        it('should return all routes for SU', async function() {
            // given
            userServiceStub.getFastopApps.resolves([
                {
                    APP_GROUP: 'Fastop',
                    SUBGROUP: 'Fiscal surveillance',
                    GROUP_ORDER: 1,
                    SUBGROUP_ORDER: 1,
                    APP_NAME: 'DFM',
                    APP_DESCR: 'DFM App',
                    APP_LINK: null,
                    ROUTE_DESCR: 'Transfer matrix',
                    ROUTE: 'tools/matrix',
                    ROUTE_ROLES: 'PUBLIC',
                },
                {
                    APP_GROUP: 'Fastop',
                    SUBGROUP: 'Fiscal surveillance',
                    GROUP_ORDER: 1,
                    SUBGROUP_ORDER: 2,
                    APP_NAME: 'SCP',
                    APP_DESCR: 'SCP App',
                    APP_LINK: null,
                    ROUTE_DESCR: 'Output gap',
                    ROUTE: 'tools/og',
                    ROUTE_ROLES: 'ADMIN',
                },
                {
                    APP_GROUP: 'Fastop',
                    SUBGROUP: 'Fiscal surveillance',
                    GROUP_ORDER: 1,
                    SUBGROUP_ORDER: 3,
                    APP_NAME: 'SCP',
                    APP_DESCR: 'SCP App',
                    APP_LINK: null,
                    ROUTE_DESCR: 'Measures',
                    ROUTE: 'tools/measures',
                    ROUTE_ROLES: 'CTY_DESK',
                },
            ])

            // when
            const result = await userController.getUserApps(true, allAuthz)

            // then
            result.should.be.eql([
                { name: 'Fastop',
                  subgroups: [
                      { name: 'Fiscal surveillance', order: 1,
                        apps: [
                            { id: 'SCP', descr: 'SCP App', link: null, routeDescr: 'Measures', route: 'tools/measures' },
                            { id: 'SCP', descr: 'SCP App', link: null, routeDescr: 'Output gap', route: 'tools/og' }
                        ]
                      }
                  ]
                }
            ])
            userServiceStub.getFastopApps.calledOnceWithExactly(true).should.be.true
        })
    })
})
