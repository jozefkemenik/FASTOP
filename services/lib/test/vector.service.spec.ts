import {} from 'mocha'
import { expect } from 'chai'

import { VectorService } from '../src/vector.service'


describe('VectorService test suite', function() {

    describe('normaliseVectorStart', function() {

        it('should normalize annual data', function() {
            // given
            const freq = 'A'

            // when
            const result = VectorService.normaliseVectorStart(freq, 1989, 1992, [1,2,3,4,5])

            // then
            expect(result).deep.equal([NaN,NaN,NaN,1,2,3,4,5])
        })

        it('should normalize semi-annual data', function() {
            // given
            const freq = 'S'

            // when
            const result = VectorService.normaliseVectorStart(freq, 1989, 1992, [1,2,3,4,5])

            // then
            expect(result).deep.equal([NaN,NaN,NaN,NaN,NaN,NaN,1,2,3,4,5])
        })

        it('should normalize quarterly data', function() {
            // given
            const freq = 'Q'

            // when
            const result = VectorService.normaliseVectorStart(freq, 1989, 1992, [1,2,3,4,5])

            // then
            expect(result).deep.equal([NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,3,4,5])
        })

        it('should normalize monthly data', function() {
            // given
            const freq = 'M'

            // when
            const result = VectorService.normaliseVectorStart(freq, 1991, 1992, [1,2,3,4,5])

            // then
            expect(result).deep.equal([NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,3,4,5])
        })

        it('should failed for weekly data', function() {
            // given
            const freq = 'W'

            // when
            expect(function() {
                VectorService.normaliseVectorStart(freq, 1991, 1992, [1,2,3,4,5])
            }).to.throw(`Not supported periodicity: ${freq}!`)
        })

        it('should failed for daily data', function() {
            // given
            const freq = 'D'

            // when
            expect(function() {
                VectorService.normaliseVectorStart(freq, 1991, 1992, [1,2,3,4,5])
            }).to.throw(`Not supported periodicity: ${freq}!`)
        })
    })
})
