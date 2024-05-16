import * as path from 'path'
import * as pug from 'pug'
import { compileTemplate } from 'pug'

import { BaseFpapiRouter, CacheMap} from '../../../lib/dist'
import { ITplColumn, IWQCountryIndicators } from './shared-interfaces'

export class SharedService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public readonly notAuthenticatedMessage =
        `User not authenticated. In order to execute this web-query you must authenticate first.\r\n` +
        `Please open the following page in your browser and login: ${BaseFpapiRouter.HOST}/wqIpLogin.html\r\n` +
        `After successful login you should return to this sheet and refresh the data.`

    // cache
    private readonly _templates: CacheMap<string, compileTemplate> = new CacheMap()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method buildIqyContent
     *********************************************************************************************/
    public buildIqyContent(address: string, params: string): string {
        const buffer: string[] = [
            'WEB',
            '1',
            address,
            params,
            '',
            'Selection=EntirePage',
            'Formatting=All',
            'PreFormattedTextToColumns=False',
            'ConsecutiveDelimitersAsOne=True',
            'SingleBlockTextImport=False',
            'DisableDateRecognition=False',
            'DisableRedirections=True',
        ]

        return buffer.join('\n')
    }

    /**********************************************************************************************
     * @method buildYearsColumns
     *********************************************************************************************/
    public buildYearsColumns(
        data: IWQCountryIndicators,
        periodicityId: string,
        minYear: number,
    ): [ITplColumn[], number] {
        const [startYear, vectorLength] = [Math.max(minYear, data.startYear), Math.max(0, data.vectorLength)]
        const mod = periodicityId === 'Q' ? 4 : periodicityId === 'M' ? 12 : 1

        return [
            Array.from(Array(vectorLength), (_, idx) => {
                const [year, period] = this.getYearAndPeriod(idx, mod, periodicityId)
                return {
                    label: `${startYear + year}${period}`,
                    field: this.getYearField(startYear + year, period),
                    observation: true,
                }
            }),
            mod,
        ]
    }

    /**********************************************************************************************
     * @method getCompiledTemplate
     *********************************************************************************************/
    public getCompiledTemplate(templatePath: string): compileTemplate {
        if (!this._templates.has(templatePath)) {
            this._templates.set(templatePath, pug.compileFile(path.resolve(templatePath)))
        }

        return this._templates.get(templatePath)
    }

    /**********************************************************************************************
     * @method getYearField
     *********************************************************************************************/
    public getYearField(year: number, period: string): string {
        return `${year}${period}`
    }

    /**********************************************************************************************
     * @method getYearAndPeriod
     *********************************************************************************************/
    public getYearAndPeriod(index: number, mod: number, periodicityId: string): [number, string] {
        return periodicityId === 'A' ? [index, ''] : [Math.floor(index / mod), `${periodicityId}${(index % mod) + 1}`]
    }

    /**********************************************************************************************
     * @method renderTemplate
     *********************************************************************************************/
    public renderTemplate(firstColumnTitle: string, indicators: unknown, templateName: string, pageTitle = ''): string {
        const renderFn = this.getCompiledTemplate(`../templates/${templateName}`)

        return renderFn(
            Object.assign({ pageTitle, firstColumnTitle, lastRefresh: new Date().toLocaleString() }, indicators),
        )
    }
}
