import {} from 'mocha'
import { should as chaiShould } from 'chai'

import { SharedCalcController } from '../src/fisc/shared/calc/shared-calc.controller'
import { SharedCalcService } from '../src/fisc/shared/calc/shared-calc.service'

/* eslint-disable @typescript-eslint/no-unused-vars */
const should = chaiShould()

class CalcService extends SharedCalcService {}
class CalcController extends SharedCalcController<SharedCalcService> {
    constructor() {super(new CalcService)}
    protected async getRequiredAmecoIndicators() {
        return []
    }
    public vectorHasValueTest(vector: string) {
        return this.vectorHasValue(vector)
    }
}

describe('SharedCalcController test suite', function() {
    const calcController = new CalcController()

    describe('vectorHasValue', function() {
        it('should return false if vector is null or undefined', function() {
            calcController.vectorHasValueTest(null).should.be.false
            calcController.vectorHasValueTest(undefined).should.be.false
        })
        it('should return false if vector is empty string', function() {
            calcController.vectorHasValueTest('').should.be.false
        })
        it('should return false if vector has no numeric values', function() {
            calcController.vectorHasValueTest(',,null,undefined,n.a. ').should.be.false
        })
        it('should return true if vector has some numeric values', function() {
            calcController.vectorHasValueTest('1,0.22,n.a.,,').should.be.true
            calcController.vectorHasValueTest('null,0,n.a.').should.be.true
        })
    })
})
/* eslint-enable @typescript-eslint/no-unused-vars */
