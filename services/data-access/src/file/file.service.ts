import * as fs from 'fs'
import * as path from 'path'

import { Level, LoggingService } from '../../../lib/dist'

export class FileService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private logs: LoggingService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method readFile
     *********************************************************************************************/
    public readFile(name: string): Promise<string> {
        const filePath = path.join(__dirname, '..', '..', 'files', name)
        this.logs.log(`FileService: Reading file: ${filePath}`, Level.DEBUG)
        return fs.promises.readFile(filePath, {encoding: 'utf8'})
            .then(text => {
                this.logs.log(`FileService: File content: ${text}`, Level.DEBUG)
                return text
            })
    }
}
