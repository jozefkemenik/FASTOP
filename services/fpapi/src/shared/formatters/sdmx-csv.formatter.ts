import { IFpapiParams, IRaw } from '../shared-interfaces'
import { BaseFormatter } from './base.formatter'
import { ISdmxData } from '../../../../lib/dist/sdmx/shared-interfaces'

export class SdmxCsvFormatter extends BaseFormatter<ISdmxData, string> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method format
     *********************************************************************************************/
    public format(sdmxData: ISdmxData, params: IFpapiParams): string {
        const header = sdmxData.names.concat(['TIME_PERIOD', 'OBS_VALUE'])
        if (params.obsFlags) header.push('OBS_FLAG')
        const csv = (array: IRaw[]) => array.join(',')
        const lines = sdmxData.data.reduce((acc, data) => {

            for (const tsPeriod of Object.keys(data.item)) {
                const period = this.getPeriod(new Date(Number(tsPeriod)), sdmxData.freq)
                const line = data.index.concat([period, this.formatObservationValue(data.item[tsPeriod])])
                if (params.obsFlags) line.push(this.formatTextValue(data.flags ? data.flags[tsPeriod] : undefined))
                acc.push(csv(line))
            }
            return acc
        }, [csv(header)])

        return lines.join('\n')
    }

}
