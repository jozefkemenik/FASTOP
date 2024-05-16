import { IError } from '../../../lib/dist'

import { SharedService } from '../shared/shared.service'

export class SectionsController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private sharedService: SharedService) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getSectionHdrAttributes
     *********************************************************************************************/
    public getSectionHdrAttributes(
        qstnnrVersionSid: number, sectionVersionSid: number
    ) {
        return this.sharedService.getSectionHdrAttributes(qstnnrVersionSid, sectionVersionSid).catch(
                (err: IError) => {
                    err.method = 'SectionsController.getSectionHdrAttributes'
                    throw err
                }
            )

    }

    /**********************************************************************************************
     * @method getSectionQuestions
     *********************************************************************************************/
    public getSectionQuestions(
        qstnnrSectionSid: number, ruleSid: number, roundSid: number, periodSid: number, applyConditions = true
    ) {

        return this.sharedService.getSectionQuestions(qstnnrSectionSid, ruleSid, roundSid, periodSid, applyConditions)
            .catch((err: IError) => {
                    err.method = 'SectionsController.getSectionQuestions'
                    throw err
                }
        )
    }

    /**********************************************************************************************
     * @method getSectionSubsections
     *********************************************************************************************/
    public async getSectionSubsections(
        qstnnrSectionSid: number
    ) {
        return this.sharedService.getSectionSubsections(qstnnrSectionSid).catch(
                (err: IError) => {
                    err.method = 'SharedService.getSectionSubsections'
                    throw err
                }
            )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
