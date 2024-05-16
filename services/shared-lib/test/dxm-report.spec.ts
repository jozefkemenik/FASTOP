import { should as chaiShould } from 'chai'

import { IMeasureDetails } from '../../dfm/src/measure'
import { calculateTotalResidual } from '../src/dxm-report'
import { config } from '../../lib/dist/measure/shared'

/* eslint-disable-next-line @typescript-eslint/no-unused-vars */
const should = chaiShould()

describe('dxm-report test suite', function() {

    describe('calculateTotalResidual', function() {

        it('should calculate correct residual values', function() {
            const measures = [
                {MEASURE_SID: 1, START_YEAR: config.startYear, IS_PUBLIC: 0, dataWithoutGDP: [0, 11.1, 22.2]},
                {MEASURE_SID: 1, START_YEAR: config.startYear, IS_PUBLIC: 1, dataWithoutGDP: [51, -51, 0]},
                {MEASURE_SID: 1, START_YEAR: config.startYear, IS_PUBLIC: 0, dataWithoutGDP: [51, -51, 0]},
                {MEASURE_SID: 1, START_YEAR: config.startYear, IS_PUBLIC: 0, dataWithoutGDP: [1.01, 0.99, 2.22222]},
                {MEASURE_SID: 1, START_YEAR: config.startYear, IS_PUBLIC: 1, dataWithoutGDP: [10, 11, 12]},
            ] as IMeasureDetails[]
            const gdp = [123.1122, 58.0001, 222.222]
            const expected = {
                raw: [ 52.01, -38.91, 24.42222 ],
                gdp: [ 0.04224601623559647, -0.06708609123087718, 0.01099000999000999]
            }

            const result = calculateTotalResidual<IMeasureDetails>(
                measures, gdp, 1000, (m: IMeasureDetails) => m.IS_PUBLIC < 1
            )
            result.should.eql(expected)
        })
    })
})
