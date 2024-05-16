import { IError } from '../error.service'

import { LibWorkflowService } from './workflow.service'

export class LibWorkflowController<S extends LibWorkflowService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(protected readonly service: S) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method openApplication
     *********************************************************************************************/
    public openApplication(): Promise<boolean> {
        return this.service.openApplication().then(
            result => result > 0,
            this.exceptionHandler('openApplication')
        )
    }

    /**********************************************************************************************
     * @method closeApplication
     *********************************************************************************************/
    public closeApplication(): Promise<boolean> {
        return this.service.closeApplication().then(
            result => result > 0,
            this.exceptionHandler('closeApplication')
        )
    }

    /**********************************************************************************************
     * @method exceptionHandler
     *********************************************************************************************/
    protected exceptionHandler(methodName: string) {
        return (err: IError) => {
            err.method = `WorkflowController.${methodName}`
            throw err
        }
    }
}
