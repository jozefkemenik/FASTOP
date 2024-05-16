import {
    CosnapComponents,
    IDBBar,
    IDBChart,
    IDBChartData,
    IDBChartDataItem,
    IDBChartTypeData,
    IDBData,
    IDBDataTexts,
    IDBGeoRefValue,
    IDBLatestComForecast,
    IDBLine,
    IDBMtStatus,
    IDBName,
    IDBRrpData,
    IDBRrpRow,
    IDBRrpTable,
    IDBText,
} from './'
import { EProperty, IName, IRrp, IRrpData, IRrpRow } from './model/rrp'
import { IBar, ILatestComForecast, ILine } from './model/latest-forecast'
import { IChart, IChartData, ICou, IDataCharts, IItem } from './model/data-chart'
import { ICosnapReport, IMTStatus, IOtherEuFunds, IText } from './model/shared-interfaces'
import { IMongoDoc } from '../../../lib/dist/mongo/shared-interfaces'
import { MongoDbService } from '../../../lib/dist'

export class ReportService {

    private static readonly COUNTRY_CODE_REGEXP = /[A-Z]{2}/
    private static readonly METADATA_COLLECTION = '_metadata'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private db: MongoDbService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryCodes
     * Collections prefixed with underscore contain metadata. Everything else is countries data.
     *********************************************************************************************/
    public async getCountryCodes(): Promise<string[]> {
        return this.db.listCollections().then(
            collections => collections.filter(c => ReportService.COUNTRY_CODE_REGEXP.test(c))
        )
    }

    /**********************************************************************************************
     * @method getReport
     *********************************************************************************************/
     public async getReport(countryId: string): Promise<ICosnapReport> {
        const report = await this.db.find(countryId)

        const components: { [key: string]: IMongoDoc } =
            report.reduce((acc, doc) => (acc[doc._id.toString()] = doc, acc), {})

         return {
             lastUpdate: await this.getLastUpdate(),
             keyData: this.toDataCharts(components[CosnapComponents.KEY_DATA]),
             digitalTransition: this.toDataCharts(components[CosnapComponents.DIGITAL_TRANSITION]),
             greenTransition: this.toDataCharts(components[CosnapComponents.GREEN_TRANSITION]),
             latestComForecast: this.toLatestComForecast(components[CosnapComponents.LATEST_COM_FORECAST]),
             rrp: this.toRrp(components[CosnapComponents.RRP]),
             mtStatus: this.toMtStatus(components[CosnapComponents.MT_STATUS]),
             otherFunds: this.toOtherFunds(components[CosnapComponents.OTHER_EU_FUNDS]),

             keyFacts: this.toText(components[CosnapComponents.KEY_FACTS]),
             implementationRisks: this.toText(components[CosnapComponents.IMPLEMENTATION_RISKS]),
             gtKeyChallenges: this.toText(components[CosnapComponents.GT_KEY_CHALLENGES]),
             gtKeyCommitments: this.toText(components[CosnapComponents.GT_KEY_COMMITMENTS]),
             dtKeyChallenges: this.toText(components[CosnapComponents.DT_KEY_CHALLENGES]),
             dtKeyCommitments: this.toText(components[CosnapComponents.DT_KEY_COMMITMENTS]),
             reforms: this.toText(components[CosnapComponents.REFORMS]),
             investments: this.toText(components[CosnapComponents.INVESTMENTS]),
             tsiProjects: this.toText(components[CosnapComponents.TSI_PROJECTS]),
             countrySpecific: this.toText(components[CosnapComponents.COUNTRY_SPECIFIC]),
         }
    }

    /**********************************************************************************************
     * @method updateText
     *********************************************************************************************/
    public async updateText(countryId: string, id: string, text: string): Promise<number> {

        const doc: IMongoDoc = await this.db.findOne(countryId, { _id: id }, )
        if (!doc.editable) throw Error(`Provided component id: ${id} is not editable!`)

        const result = await this.db.update(
            countryId, { _id: id }, { $set: { text: text } }
        )
        return result.modifiedCount
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method toText
     *********************************************************************************************/
    private toText(doc: IMongoDoc): IText {
        if (!doc) return null
        const db: IDBText = doc as IDBText

        return {
            id: db._id,
            text: db.text,
            editable: db.editable
        }
    }

    /**********************************************************************************************
     * @method getLastUpdate
     *********************************************************************************************/
    private async getLastUpdate(): Promise<Date> {
        const doc: IMongoDoc = await this.db.findOne(ReportService.METADATA_COLLECTION, { '_id': 'last_update' })
        return new Date(doc.value)
    }

    /**********************************************************************************************
     * @method toDataCharts
     *********************************************************************************************/
    private toDataCharts(doc: IMongoDoc): IDataCharts {
        if (!doc) return null
        const db: IDBChartData = doc as IDBChartData

        return {
            items: this.toChartDataItems(db.items)
        }
    }

    /**********************************************************************************************
     * @method toLatestComForecast
     *********************************************************************************************/
    private toLatestComForecast(doc: IMongoDoc): ILatestComForecast {
        if (!doc) return null
        const db: IDBLatestComForecast = doc as IDBLatestComForecast

        return {
            country_code: db.items.country_code,
            years: db.items.years,
            line: this.toLineData(db.items.line),
            bar: this.toBarData(db.items.bar),
        }
    }

    /**********************************************************************************************
     * @method toMtStatus
     *********************************************************************************************/
    private toMtStatus(doc: IMongoDoc): IMTStatus {
        if (!doc) return null
        const db: IDBMtStatus = doc as IDBMtStatus

        return {
            title: db.items.title,
            data: db.items.data,
            legend: db.items.legend,
        }
    }

    /**********************************************************************************************
     * @method toOtherFunds
     *********************************************************************************************/
    private toOtherFunds(doc: IMongoDoc): IOtherEuFunds {
        if (!doc) return null
        const db: IDBDataTexts = doc as IDBDataTexts

        return {
            header: db.header,
            footnotes: db.footnotes,
            data: db.items.map(item => item[Object.keys(item)[0]]),
        }
    }

    /**********************************************************************************************
     * @method toRrp
     *********************************************************************************************/
    private toRrp(doc: IMongoDoc): IRrp {
        if (!doc) return null
        const db: IDBRrpTable = doc as IDBRrpTable

        return {
            rows: db.items.map(item => this.toRrpRow(item))
        }
    }

    /**********************************************************************************************
     * @method toRrp
     *********************************************************************************************/
    private toRrpRow(db: IDBRrpRow): IRrpRow {
        return {
            color_group: db.color_group,
            data: this.toRrpData(db.data)
        }
    }

    /**********************************************************************************************
     * @method toRrpData
     *********************************************************************************************/
    private toRrpData(db: IDBRrpData): IRrpData {
        if (!db) return null
        return {
            char: this.toName(db.char),
            name: this.toName(db.name),
            value: this.toName(db.value),
            perc: db.perc !== undefined && db.perc !== null ? Number(db.perc) : null,
        }
    }

    /**********************************************************************************************
     * @method toName
     *********************************************************************************************/
    private toName(db: IDBName): IName {
        if (!db) return null
        return {
            text: db.text,
            property: this.toNameProperty(db.property),
        }
    }

    /**********************************************************************************************
     * @method toNameProperty
     *********************************************************************************************/
    private toNameProperty(db: string): EProperty {
        if (!db) return null
        switch (db) {
            case EProperty.Bold: return EProperty.Bold
            default: return null
        }
    }

    /**********************************************************************************************
     * @method toChartDataItems
     *********************************************************************************************/
    private toChartDataItems(dbItems: IDBChartDataItem[]): IItem[] {
        const items: IItem[] = dbItems ? dbItems.map(item => ({
            title: item.title,
            chart: this.toChart(item.chart),
            order: item.order,
        })) : []

        items.sort((a, b) => a.order - b.order)

        return items
    }

    /**********************************************************************************************
     * @method toChart
     *********************************************************************************************/
    private toChart(dbChart: IDBChart): IChart {
        return dbChart ? {
            chart_type: dbChart.chart_type,
            data: this.toData(dbChart.chart_type, dbChart.data, dbChart.legend)
        } : null
    }

    /**********************************************************************************************
     * @method toData
     *********************************************************************************************/
    private toData(chartType: string, dbData: IDBChartTypeData, legend?: string[]): IChartData {
        if (!dbData) return null

        if (chartType.toLowerCase() === 'line') {
            const db: IDBData = dbData as IDBData
            return {
                min: this.toCou(db.min),
                max: this.toCou(db.max),
                median: this.toCou(db.median),
                eu: this.toCou(db.eu),
                cou: this.toCou(db.cou),
            }
        } else {
            return legend.reduce((acc, legend, index) => (acc[legend] = dbData[index], acc), {})
        }
    }

    /**********************************************************************************************
     * @method toCou
     *********************************************************************************************/
    private toCou(db: IDBGeoRefValue): ICou {
        return db ? {
            value: db.value,
            georef: db.georef,
        } : null
    }

    /**********************************************************************************************
     * @method toLineData
     *********************************************************************************************/
    private toLineData(db: IDBLine): ILine {
        return db??undefined
    }

    /**********************************************************************************************
     * @method toBarData
     *********************************************************************************************/
    private toBarData(db: IDBBar): IBar {
        return db ? {
            Debt: db.Debt,
        } : undefined
    }
}
