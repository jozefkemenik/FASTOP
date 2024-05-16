import 'chai/register-should.js'
import * as sinon from 'sinon'

import { ICountry } from '../../../../lib/dist/menu'
import { TceController } from '../../../src/report/tce/tce.controller'
import { TceService } from '../../../src/report/tce/tce.service'


describe('TceController test suite', function() {

    const tceServiceStub = sinon.createStubInstance(TceService)

    const tceController = new TceController(tceServiceStub)

    describe('getTceCountries method', function() {

        it('should return tce countries', async function() {
            // given
            const roundSid = 123
            const storageSid = 4
            const dbCountries: ICountry[] = [
                { CODEISO3: 'BEL', CODE_FGD: 17, COUNTRY_ID: 'BE', DESCR: 'Belgium' },
                { CODEISO3: 'POL', CODE_FGD: 44, COUNTRY_ID: 'PL', DESCR: 'Poland' },
            ]
            tceServiceStub.getTceResultsCountries.resolves(dbCountries)

            // when
            const result = await tceController.getCountries(roundSid, storageSid)

            // then
            result.should.be.eql(dbCountries)
            tceServiceStub.getTceResultsCountries.calledOnceWithExactly(roundSid, storageSid).should.be.true
        })
    })

    describe('getTceMatrixData method', function() {

        it('should return tce matrix data', async function() {
            // given
            const roundSid = 123
            const storageSid = 4
            const provider = 'TCE_XX'
            tceServiceStub.getMatrixData.resolves([
                { EXPORTER_CTY_ID: 'BE', PARTNER_CTY_ID: 'BG', VALUE: '929.822929' },
                { EXPORTER_CTY_ID: 'CZ', PARTNER_CTY_ID: 'BE', VALUE: '4329.636056' },
                { EXPORTER_CTY_ID: 'BE', PARTNER_CTY_ID: 'DE', VALUE: '82807.441601' },
                { EXPORTER_CTY_ID: 'CZ', PARTNER_CTY_ID: 'KR', VALUE: '483.50021' },
                { EXPORTER_CTY_ID: 'BE', PARTNER_CTY_ID: 'RU', VALUE: '4345.317701' },
            ])

            // when
            const result = await tceController.getMatrixData(provider, roundSid, storageSid)

            // then
            result.should.be.eql([
                {
                    expCtyId: 'BE',
                    partners: [
                        { ctyId:'BG', value:929.822929 },
                        { ctyId:'DE', value:82807.441601 },
                        { ctyId:'RU', value:4345.317701 }
                    ]
                },
                {
                    expCtyId: 'CZ',
                    partners: [
                        { ctyId:'BE', value:4329.636056 },
                        { ctyId:'KR', value:483.50021 }
                    ]
                }
            ])
            tceServiceStub.getMatrixData.calledOnceWithExactly(provider, roundSid, storageSid).should.be.true
        })

    })
})
