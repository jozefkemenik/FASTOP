import {} from 'mocha'
import * as sinon from 'sinon'
import { Request, Response } from 'express'
import { should as chaiShould } from 'chai'

import { AuthzLibService } from '../src/authzLib.service'
import { config } from '../../config/config'

/* eslint-disable @typescript-eslint/no-unused-vars, @typescript-eslint/no-explicit-any */
const should = chaiShould()

describe('AuthzLibService test suite', function() {
    function getReq(authzs: {userGroup: string, countries?: string[]}[]): Request {
        return {
            get: (header: string) => header === 'authzs'
                ? authzs.map(authz => `${authz.userGroup},${authz.countries ?? ''}`).join('|')
                : 'ABC'
        } as Request
    }

    afterEach(function() {
        sinon.restore()
    })

    describe('checkApiKey', function() {
        function getReq(apiKey: string): Request {
            return {get: (header: string) => header === 'apiKey' ? apiKey : 'ABC'} as Request
        }
        let next: sinon.SinonSpy
        const res: Response = {} as any

        beforeEach(function() {
            next = sinon.spy()
        })

        it('should call next with no arguments if apiKey is correct', function() {
            const req = getReq(config.apiKey)
            AuthzLibService.checkApiKey()(req, res, next)
            next.calledOnceWithExactly().should.be.true
        })
        it('should call next with Error if apiKey is empty', function() {
            const req = getReq('')
            AuthzLibService.checkApiKey()(req, res, next)
            next.calledOnce.should.be.true
            next.firstCall.args.should.not.be.empty
        })
        it('should call next with Error if apiKey is incorrect', function() {
            const req = getReq('wrongApiKey')
            AuthzLibService.checkApiKey()(req, res, next)
            next.calledOnce.should.be.true
            next.firstCall.args.should.not.be.empty
        })
        it('should call next with Error if apiKey is not found in the header', function() {
            const req = {get: (header: string) => header === 'apiKey' ? undefined : 'ABC'} as Request
            AuthzLibService.checkApiKey()(req, res, next)
            next.calledOnce.should.be.true
            next.firstCall.args.should.not.be.empty
        })
    })

    describe('checkAuthorisation', function() {
        let next: sinon.SinonSpy
        const res: Response = {} as any

        beforeEach(function() {
            next = sinon.spy()
        })

        it('should call next with no arguments if internal call', function() {
            const req = {get: (header: string) => header === 'internal' ? 'true' : 'ABC'} as Request
            AuthzLibService.checkAuthorisation('blabla')(req, res, next)
            next.calledOnceWithExactly().should.be.true
        })
        it('should call next with no arguments if user is SU', function() {
            const req = getReq([{userGroup: 'SU'}])
            AuthzLibService.checkAuthorisation('blabla')(req, res, next)
            next.calledOnceWithExactly().should.be.true
        })
        it('should call next with no arguments if user is SU and other', function() {
            const req = getReq([{userGroup: 'AAA'}, {userGroup: 'SU'}, {userGroup: 'OTHER'}])
            AuthzLibService.checkAuthorisation('blabla')(req, res, next)
            next.calledOnceWithExactly().should.be.true
        })
        it('should call next with no arguments if user is authorised (single group)', function() {
            const req = getReq([{userGroup: 'GROUP1'}])
            AuthzLibService.checkAuthorisation('blabla', 'GROUP1', '')(req, res, next)
            next.calledOnceWithExactly().should.be.true
        })
        it('should call next with no arguments if user is authorised (multiple groups)', function() {
            const req = getReq([{userGroup: 'XYZ'}, {userGroup: 'GROUP1'}, {userGroup: 'GROUP2'}])
            AuthzLibService.checkAuthorisation('blabla', 'GROUP1', '')(req, res, next)
            next.calledOnceWithExactly().should.be.true
        })
        it('should call next with AuthzError if user is not authorised', function() {
            const req = getReq([{userGroup: 'GROUP1'}, {userGroup: 'GROUP3'}])
            AuthzLibService.checkAuthorisation('blabla', 'GROUP2')(req, res, next)
            next.calledOnce.should.be.true
            next.firstCall.args.should.not.be.empty
        })
    })

    describe('checkCountryAuthorisation',
        function () {
            function countryGetter(req: Request): string {
                return 'AT'
            }

            function countriesGetter(req: Request): string {
                return 'AT,BE'
            }

            function countriesGetterArray(req: Request): string[] {
                return ['AT', 'BE']
            }

            let next: sinon.SinonSpy
            const res: Response = {} as any

            beforeEach(function () {
                next = sinon.spy()
            })

            it('should call next with no arguments if internal call', function () {
                const req = { get: (header: string) => header === 'internal' ? 'true' : 'ABC' } as Request
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with no arguments if user is SU (no countries)', function () {
                const req = getReq([{ userGroup: 'SU' }])
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with no arguments if user is SU (with countries)', function () {
                const req = getReq([{ userGroup: 'SU', countries: ['AT', 'BE'] }])
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with no arguments if user is SU with other groups', function () {
                const req = getReq([{
                    userGroup: 'ABC',
                    countries: ['AT', 'BE']
                }, { userGroup: 'SU' }, { userGroup: 'GROUP1' }])
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with no arguments if user is ADMIN (no countries)', function () {
                const req = getReq([{ userGroup: 'ADMIN' }])
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with no arguments if user is ADMIN (with countries)', function () {
                const req = getReq([{ userGroup: 'ADMIN', countries: ['AT', 'BE'] }])
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with no arguments if user is ADMIN with other groups', function () {
                const req = getReq([{ userGroup: 'ADMIN' }, {
                    userGroup: 'ABC',
                    countries: ['AT', 'BE']
                }, { userGroup: 'GROUP1' }])
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with no arguments if user has access to the country', function () {
                const req = getReq([{ userGroup: 'GROUP1', countries: ['BE', 'AT'] }])
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with no arguments if user has access to the country in the specified group', function () {
                const req = getReq([{ userGroup: 'AB', countries: ['CY', 'DK'] }, {
                    userGroup: 'GROUP1',
                    countries: ['BE', 'AT']
                }])
                AuthzLibService.checkCountryAuthorisation(countryGetter, ['GROUP1'])(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with AuthzError if user has no access to the country in the specified group', function () {
                const req = getReq([{ userGroup: 'GROUP1', countries: ['CY', 'DK'] }, {
                    userGroup: 'GROUP2',
                    countries: ['BE', 'AT']
                }])
                AuthzLibService.checkCountryAuthorisation(countryGetter, ['GROUP1'])(req, res, next)
                next.calledOnce.should.be.true
                next.firstCall.args.should.not.be.empty
            })
            it('should call next with AuthzError if user has no access to the country', function () {
                const req = getReq([{ userGroup: 'CTY_DESK', countries: ['CY', 'DK'] }])
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
                next.calledOnce.should.be.true
                next.firstCall.args.should.not.be.empty
            })
            it('should call next with no arguments if user has access to all countries in the request', function () {
                const req = getReq([{ userGroup: 'GROUP1', countries: ['BE', 'AT'] }])
                AuthzLibService.checkCountryAuthorisation(countriesGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            /* eslint-disable-next-line max-len */
            it('should call next with no arguments if user has access to all countries in the request (array getter)', function () {
                const req = getReq([{ userGroup: 'GROUP1', countries: ['BE', 'AT'] }])
                AuthzLibService.checkCountryAuthorisation(countriesGetterArray)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            /* eslint-disable-next-line max-len */
            it('should call next with no arguments if user has access to all countries in the request in different groups', function () {
                const req = getReq([{ userGroup: 'GROUP1', countries: ['BE', 'DK'] }, {
                    userGroup: 'GROUP2',
                    countries: ['CY', 'AT']
                }])
                AuthzLibService.checkCountryAuthorisation(countriesGetter)(req, res, next)
                next.calledOnceWithExactly().should.be.true
            })
            it('should call next with AuthzError if countryGetter returns undefined', function () {
                const req = getReq([{ userGroup: 'CTY_DESK', countries: ['BE', 'AT', 'DK'] }])
                AuthzLibService.checkCountryAuthorisation(() => undefined)(req, res, next)
                next.calledOnce.should.be.true
                next.firstCall.args.should.not.be.empty
            })
            it('should call next with AuthzError if countryGetter returns empty string', function () {
                const req = getReq([{ userGroup: 'CTY_DESK', countries: ['BE', 'AT', 'DK'] }])
                AuthzLibService.checkCountryAuthorisation(() => '')(req, res, next)
                next.calledOnce.should.be.true
                next.firstCall.args.should.not.be.empty
            })
            it('should call next with AuthzError if countryGetter returns empty array', function () {
                const req = getReq([{ userGroup: 'CTY_DESK', countries: ['BE', 'AT', 'DK'] }])
                AuthzLibService.checkCountryAuthorisation(() => [])(req, res, next)
                next.calledOnce.should.be.true
                next.firstCall.args.should.not.be.empty
            })
        })

    describe('getUserCountries', function() {
        it('should return an empty array if user has no access to any country', function() {
            const req = getReq([{userGroup: 'G1'}, {userGroup: 'G2', countries: []}])
            const result = AuthzLibService.getUserCountries(req)
            result.should.be.empty
        })
        it('should return user countries with no duplicates', function() {
            const req = getReq([{userGroup: 'G1', countries: ['AT', 'PL']}, {userGroup: 'G2', countries: ['AT', 'BE']}])
            const result = AuthzLibService.getUserCountries(req)
            result.should.have.lengthOf(3)
            for (const cty of ['AT', 'BE', 'PL']) result.should.contain(cty)
        })
    })

    describe('getUserGroups', function() {
        it('should return user groups', function() {
            const req = getReq([{userGroup: 'G1', countries: ['AT', 'PL']}, {userGroup: 'G2', countries: ['AT', 'BE']}])
            const result = AuthzLibService.getUserGroups(req)
            result.should.have.lengthOf(2)
            for (const group of ['G1', 'G2']) result.should.contain(group)
        })
    })

    describe('isCtyDesk', function() {
        it('should return true if user has CTY_DESK role', function() {
            const req = getReq([{userGroup: 'G1', countries: ['AT', 'PL']}, {userGroup: 'CTY_DESK', countries: ['AT', 'BE']}])
            AuthzLibService.isCtyDesk(req).should.be.true
        })
        it('should return true if user has ADMIN role', function() {
            const req = getReq([{userGroup: 'ADMIN', countries: ['AT', 'PL']}, {userGroup: 'G2', countries: ['AT', 'BE']}])
            AuthzLibService.isCtyDesk(req).should.be.true
        })
        it('should return true if user has SU role', function() {
            const req = getReq([{userGroup: 'SU'}, {userGroup: 'G2', countries: ['AT', 'BE']}])
            AuthzLibService.isCtyDesk(req).should.be.true
        })
        it('should return false if user has no CTY_DESK role', function() {
            const req = getReq([{userGroup: 'G1', countries: ['AT', 'PL']}, {userGroup: 'G2', countries: ['AT', 'BE']}])
            AuthzLibService.isCtyDesk(req).should.be.false
        })
    })

    describe('isAdmin', function() {
        it('should return true if user has ADMIN role', function() {
            const req = getReq([{userGroup: 'ADMIN'}, {userGroup: 'G2', countries: ['AT', 'BE']}])
            AuthzLibService.isAdmin(req).should.be.true
        })
        it('should return true if user has SU role', function() {
            const req = getReq([{userGroup: 'G2', countries: ['AT', 'BE']}, {userGroup: 'SU'}])
            AuthzLibService.isAdmin(req).should.be.true
        })
        it('should return false if user has no ADMIN role', function() {
            const req = getReq([{userGroup: 'G1', countries: ['AT', 'PL']}, {userGroup: 'G2'}])
            AuthzLibService.isAdmin(req).should.be.false
        })
    })

    describe('isReadOnly', function() {
        it('should return true if user has READ_ONLY role', function() {
            const req = getReq([{userGroup: 'G1'}, {userGroup: 'READ_ONLY', countries: ['AT', 'BE']}])
            AuthzLibService.isReadOnly(req).should.be.true
        })
        it('should return false if user has no READ_ONLY role', function() {
            const req = getReq([{userGroup: 'G1', countries: ['AT', 'PL']}, {userGroup: 'ADMIN'}])
            AuthzLibService.isReadOnly(req).should.be.false
        })
    })

    describe('isInternalCall', function() {
        it('should return true for internal calls', function() {
            const req = {get: (header: string) => header === 'internal' ? 'true' : 'ABC'} as Request
            AuthzLibService.isInternalCall(req).should.be.true
        })
        it('should return false for not internal calls', function() {
            const req = {get: (header: string) => 'ABC'} as Request
            AuthzLibService.isInternalCall(req).should.be.false
        })
    })

})
/* eslint-enable @typescript-eslint/no-unused-vars, @typescript-eslint/no-explicit-any */
