import {} from 'mocha'
import * as sinon from 'sinon'
import { should as chaiShould } from 'chai'

import { IDBHeaderAttribute, IDBQuestionnaire, IQuestionnaire } from '../../src/shared/index'
import { EApps } from 'config'
import { ICustomHeaderAttr } from '../../src/questionnaires'
import { QuestionnaireController } from '../../src/questionnaires/questionnaire.controller'
import { QuestionnaireService } from '../../src/questionnaires/questionnaire.service'
import { SharedService } from '../../src/shared/shared.service'

/* eslint-disable-next-line @typescript-eslint/no-unused-vars */
const should = chaiShould()

describe('QuestionnaireController test suite', function() {
    const dbQuestionnaires: IDBQuestionnaire[] = [
        {QUESTIONNAIRE_SID: 1, APP_ID: 'NFR', DESCR: 'NFR Descr'},
        {QUESTIONNAIRE_SID: 2, APP_ID: 'IFI', DESCR: 'IFI Descr'},
    ]
    const expectedQuestionnaires: IQuestionnaire[] = [
        {QUESTIONNAIRE_SID: 1, APP_ID: 'NFR', DESCR: 'NFR Descr'},
        {QUESTIONNAIRE_SID: 2, APP_ID: 'IFI', DESCR: 'IFI Descr'}
    ]

    const dbCustomHeaderAttr: ICustomHeaderAttr[] = [
        {CUSTOM_ATTR_ID: 'ATTR1', IN_QUESTIONNAIRE: 'Attr1', WIDTH: 100, ORDER_BY: 1 },
        {CUSTOM_ATTR_ID: 'ATTR2', IN_QUESTIONNAIRE: 'Attr2', WIDTH: 80, ORDER_BY: 2 },
        {CUSTOM_ATTR_ID: 'ATTR3', IN_QUESTIONNAIRE: 'Attr3',  WIDTH: 40, ORDER_BY: 3 },
    ]
    const expectedCustomHeaderAttr: ICustomHeaderAttr[] = [
        {CUSTOM_ATTR_ID: 'ATTR1', IN_QUESTIONNAIRE: 'Attr1', WIDTH: 100, ORDER_BY: 1 },
        {CUSTOM_ATTR_ID: 'ATTR2', IN_QUESTIONNAIRE: 'Attr2', WIDTH: 80, ORDER_BY: 2 },
        {CUSTOM_ATTR_ID: 'ATTR3', IN_QUESTIONNAIRE: 'Attr3', WIDTH: 40, ORDER_BY: 3 },
    ]

    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    const dbHeaderAttr: IDBHeaderAttribute[] = [
    ]

    let questionnaireController: QuestionnaireController
    let questionnaireService: QuestionnaireService
    let sharedService: SharedService
    let getQuestionnaires: sinon.SinonSpy
    let getCustomHeaderAttributes: sinon.SinonSpy

    beforeEach(function() {
        getQuestionnaires = sinon.fake.returns(Promise.resolve(dbQuestionnaires))
        getCustomHeaderAttributes = sinon.fake.returns(Promise.resolve(dbCustomHeaderAttr))
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        sharedService = {getQuestionnaires} as any
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        questionnaireService = {getCustomHeaderAttributes} as any
        questionnaireController = new QuestionnaireController(questionnaireService, sharedService, EApps.NFR)
    })
    afterEach(function() {
        sinon.restore()
    })

    describe('getQuestionnaires', function() {
        it('should not be called with parameters', async function(){
            await questionnaireController.getQuestionnaires()
            getQuestionnaires.calledOnce.should.be.true
        })

        it('should get questionnaires without any grouping', async function() {
            const appQuestionnaires = await questionnaireController.getQuestionnaires()
            appQuestionnaires.should.eql(expectedQuestionnaires)
        })
    })

    describe('getCustomHeaderAttributes', function() {
        it('should be called with exactly 2 parameters', async function() {
            await questionnaireController.getCustomHeaderAttributes(1, 'questionnaire')
            getCustomHeaderAttributes.calledOnceWithExactly(1, 'questionnaire').should.be.true
        })

        it('should get header elements', async function() {
            const result = await questionnaireController.getCustomHeaderAttributes(1, 'questionnaire')
            result.should.eql(expectedCustomHeaderAttr)
        })
    })
})
