import {
    IDictionary,
    IDictionaryValue,
    ILibColumnConfig,
    ILibWorkbookConfig,
    IMeasuresRange,
    IObjectSIDs,
    IWizardDefinition,
} from '..'
import { IExcelValidation } from '../../excel'

export abstract class LibUploadService {

    public static CONTROL_WORKSHEET_NAME = 'List'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getWizardDefinition
     *********************************************************************************************/
    public async getWizardDefinition(
        countryId: string, roundSid: number, range?: IMeasuresRange,
    ): Promise<IWizardDefinition> {
        const workbookConfig = await this.getTemplateConfig(countryId, roundSid, range)
        return { range, workbookConfig }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTemplateConfig
     * Get the wizard template definition
     *********************************************************************************************/
    protected abstract getTemplateConfig(
        countryId: string, roundSid: number, range: IMeasuresRange,
    ): Promise<ILibWorkbookConfig>

    /**********************************************************************************************
     * @method convertToExcelFormula
     *********************************************************************************************/
    protected convertToExcelFormula(dictionary: IDictionary) {
        const name = LibUploadService.CONTROL_WORKSHEET_NAME
        return [`${name}!$${dictionary.column}$1:$${dictionary.column}$${dictionary.length}`]
    }

    /**********************************************************************************************
     * @method prepareListDataValidation
     *********************************************************************************************/
    protected prepareListDataValidation(
        dictionary: IDictionary, allowBlank: boolean, errorFieldName: string, prompt = ''
    ): IExcelValidation {
        const showPrompt = !(!prompt && allowBlank)
        if (showPrompt && !prompt) prompt = 'Mandatory value.'

        return {
            type: 'list',
            allowBlank,
            formulae: this.convertToExcelFormula(dictionary),
            showErrorMessage: true,
            errorTitle: `Invalid "${errorFieldName}"`,
            error: allowBlank ? 'The value must be one of the dropdown values.' :
                'The value cannot be empty and must be one of the dropdown values',
            showInputMessage: showPrompt,
            promptTitle: showPrompt ? prompt : undefined,
            prompt: ' '
        }
    }

    /**********************************************************************************************
     * @method prepareMultiListDataValidation
     *********************************************************************************************/
     protected prepareMultiListDataValidation(
        dictionary: IDictionary, allowBlank: boolean, errorFieldName: string, promptTitle?: string,
    ): IExcelValidation {
        const values = Object.getOwnPropertyNames(dictionary.data).join(', ')
        promptTitle = promptTitle ?? `Please enter one or more of the following (comma separated if more than one): ${values}`

        return {
            type: 'custom',
            allowBlank,
            formulae: [`${LibUploadService.CONTROL_WORKSHEET_NAME}!$A${dictionary.column}`],
            showErrorMessage: true,
            errorTitle: `Invalid "${errorFieldName}"`,
            error: `Incorrect label(s)! You may only enter one or more of the following: ${values}`,
            showInputMessage: true,
            promptTitle,
            prompt: ' '
        }
    }

    /**********************************************************************************************
     * @method calculateColumnWidth
     *********************************************************************************************/
    protected calculateColumnWidth(columns: ILibColumnConfig[]) {
        columns.forEach(column => {
            if (!column.width) {
                const itemLength = column.dictionary !== undefined ?
                    column.dictionary.itemMaxLength : column.label.length
                column.width = Math.max(10, itemLength)
            }
        })
    }

    /**********************************************************************************************
     * @method convertToDictionary
     * Convert DB data to dictionary:
     * - column: name of the db column
     * - data: dictionary, key = string (data text), value = sid (db key)
     * - dbData dictionary, key = sid (db key), value = string (data text)
     * - length: number of items in the dictionary
     * - itemMaxLength: length of the longest (in terms of character) item in the dictionary.
     *                  This is needed for calculating of column width.
     *********************************************************************************************/
    protected async convertToDictionary(
        column: string,
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        dataPromise: Promise<any>,
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        conversionFunction: (data: any, key: any) => string =
            (data: IObjectSIDs, item: number) => item !== -1 ? data[item] : null
    ): Promise<IDictionary> {
        return dataPromise.then(data => {
            const dictValue: IDictionaryValue = {}
            const dbDictValue: IDictionaryValue = {}
            const keys = Object.getOwnPropertyNames(data)
            let counter = 0
            let maxLength = 0
            keys.forEach(key => {
                const value: string = conversionFunction(data, key)
                if (value !== null && value !== undefined) {
                    dictValue[value] = Number(key)
                    dbDictValue[key] = value
                    counter++
                    if (value.length > maxLength) {
                        maxLength = value.length
                    }
                }
            })

            return {
                column,
                data: dictValue,
                dbData: dbDictValue,
                length: counter,
                itemMaxLength: maxLength
            }
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
