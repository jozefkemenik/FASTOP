import { LoggingService } from '../../../lib/dist'

import { FileService } from './file.service'

export class FileController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private service: FileService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private logs: LoggingService) {
        this.service = new FileService(logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method readFile
     *********************************************************************************************/
    public readFile(name: string) {
        return this.service.readFile(name)
    }
}
