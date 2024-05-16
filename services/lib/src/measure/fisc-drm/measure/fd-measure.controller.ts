import { LibMeasureController, LibMeasureService, MeasureUploadService } from '../..'
import { IDictionaries } from '../shared'
import { IFDMeasureDetails } from '.'

export abstract class FDMeasureController<
    D extends IFDMeasureDetails,
    U extends MeasureUploadService<D>,
    S extends LibMeasureService,
> extends LibMeasureController<D, U, S> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method denormaliseMeasure
     *********************************************************************************************/
     protected denormaliseMeasure(
        {dbpAccPrinciples, dbpAdoptStatues, ...rest}: IDictionaries,
    ) {
        return ({ACC_PRINCIP_SID, ADOPT_STATUS_SID, ...restMeasure}: IFDMeasureDetails) => ({
            ACC_PRINIP_DESCR: dbpAccPrinciples[ACC_PRINCIP_SID],
            ADOPT_STATUS_DESCR: dbpAdoptStatues[ADOPT_STATUS_SID],
            ...super.denormaliseMeasure(rest)(restMeasure)
        })
    }
}
