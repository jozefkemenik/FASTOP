import {} from 'mocha'
import { should as chaiShould } from 'chai'

import { EOutputFormat, IFpapiParams } from '../../../src/shared/shared-interfaces'
import { ISdmxData } from '../../../../lib/src/sdmx/shared-interfaces'
import { SdmxCsvFormatter } from '../../../src/shared/formatters/sdmx-csv.formatter'


describe('SdmxCsvFormatter test suite', function() {

    const should = chaiShould()

    const formatter = new SdmxCsvFormatter()

    const params: IFpapiParams = {
        dataset: 'namq_10_gdp',
        query: 'A.XYZ.PL',
        format: EOutputFormat.JSON,
    }

    const sdmxData: ISdmxData = {
        names: ['FREQ', 'INDIC_EM', 'SEX', 'AGE', 'UNIT', 'GEO'],
        freq: 'A',
        data: [
            {
                index: ['A', 'EMP_LFS', 'T', 'Y20-64', 'PC_POP', 'BE'],
                item: { '1230768000000.0': 67.1, '1262304000000.0': 67.6, '1483228800000.0': 68.5 },
                flags: { '1483228800000.0': 'b' }
            }
        ]
    }

    describe('format', function() {

        it('format to csv without observation flags', function() {
            // given
            params.obsFlags = false

            // when
            const result = formatter.format(sdmxData, params)

            // then
            should.equal(result,
                'FREQ,INDIC_EM,SEX,AGE,UNIT,GEO,TIME_PERIOD,OBS_VALUE\n' +
                'A,EMP_LFS,T,Y20-64,PC_POP,BE,2009,67.1\n' +
                'A,EMP_LFS,T,Y20-64,PC_POP,BE,2010,67.6\n' +
                'A,EMP_LFS,T,Y20-64,PC_POP,BE,2017,68.5'
            )

        })


        it('format to csv with observation flags', function() {
            // given
            params.obsFlags = true

            // when
            const result = formatter.format(sdmxData, params)

            // then
            should.equal(result,
                'FREQ,INDIC_EM,SEX,AGE,UNIT,GEO,TIME_PERIOD,OBS_VALUE,OBS_FLAG\n' +
                'A,EMP_LFS,T,Y20-64,PC_POP,BE,2009,67.1,\n' +
                'A,EMP_LFS,T,Y20-64,PC_POP,BE,2010,67.6,\n' +
                'A,EMP_LFS,T,Y20-64,PC_POP,BE,2017,68.5,b'
            )
        })

    })
})
