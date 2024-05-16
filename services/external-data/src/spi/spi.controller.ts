import { catchAll } from '../../../lib/dist/catch-decorator'

import { IDBSpiIndicator, IDBSpiMatrixData } from './index'
import { ISpi, ISpiData, ISpiMatrix, ISpiMatrixParams, ISpiParams } from './shared-interfaces'
import { SpiService } from './spi.service'

@catchAll(__filename)
export class SpiController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    public constructor(private spiService: SpiService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getMatrixData(params: ISpiMatrixParams): Promise<ISpiMatrix> {
        const rows: IDBSpiMatrixData[] = await this.spiService.getMatrixData(
            params.indicator, params.countries, params.products,
            params.years, params.startYear, params.endYear
        )

        // group by country and year, get Product = 'code'
        const industrySet = new Set<string>(params.industries)
        const codeKey = (country, year) => `${country}_${year}`

        const codes: ICodes = rows.filter(r => r.PRODUCT.toUpperCase() === 'CODE').reduce((acc, row) => {
            acc[codeKey(row.COUNTRY, row.YEAR)] = row.VECTOR.split(',').reduce((vecAcc, industry, index) => {
                if (industrySet.has(industry)) vecAcc.push({ industry, index})
                return vecAcc
            }, [])
            return acc
        }, {})

        const matrix: ISpiMatrix = {
            industries: params.industries,
            update_date: new Date(
                await this.spiService.getIndicatorDownloadDate('sectoral interrelations')
            ).toLocaleString(),
            data: rows.filter(r => r.PRODUCT.toUpperCase() !== 'CODE').map(row => {
                const industryIndexes = codes[codeKey(row.COUNTRY, row.YEAR)]
                return {
                    country_id: row.COUNTRY,
                    year: row.YEAR,
                    product: row.PRODUCT,
                    values: industryIndexes.reduce((acc, industryIndex) => {
                        acc[industryIndex.industry] = row.VECTOR.split(',')[industryIndex.index]
                        return acc
                    }, {})
                }
            }),
            dictionary: {
                industries: await this.spiService.getIndustries(),
                products: await this.spiService.getProducts(),
            }
        }

        return matrix
    }

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(params: ISpiParams): Promise<ISpi> {
        const rows: IDBSpiIndicator[] = await this.spiService.getIndicatorData(
            params.domain, params.indicators, params.countries,
            params.nomenclatureCodes, params.nomenclature, params.destor
        )

        const yearsSet: Set<string> = new Set<string>(params.years)
        let vectorMinYear = Number.MAX_VALUE
        let vectorMaxYear = Number.MIN_VALUE

        const startYear = params.startYear ? Number(params.startYear) : Number.MIN_VALUE
        const endYear = params.endYear ? Number(params.endYear) : Number.MAX_VALUE

        const data: ISpiData[] = rows.reduce((acc, row) => {
            const vector = row.VECTOR?.split(',') || []

            vectorMinYear = Math.min(vectorMinYear, row.START_YEAR)
            vectorMaxYear = Math.max(vectorMaxYear, row.START_YEAR + vector.length)

            const spiData: ISpiData = {
                indicator_id: row.INDICATOR,
                indicator_descr: row.INDICATOR_LABEL,
                country_id: row.COUNTRY,
                partner_id: row.PARTNER,
                nomenclature_id: row.NOMENCLATURE,
                nomenclature_desc: row.NOMENCLATURE_LABEL,
                data: vector.reduce((vectorAcc, vectorData, vectorIndex) => {
                    const year = row.START_YEAR + vectorIndex
                    if (params.years?.length) {
                        if (yearsSet.has(String(year))) {
                            vectorAcc[row.START_YEAR + vectorIndex] = vectorData
                        }
                    } else if (year >= startYear && year <= endYear) {
                        vectorAcc[row.START_YEAR + vectorIndex] = vectorData
                    }

                    return vectorAcc
                }, {})
            }

            acc.push(spiData)

            return acc
        }, [])

        vectorMinYear = params.startYear ? Number(params.startYear) : vectorMinYear
        vectorMaxYear = params.endYear ? Number(params.endYear) : vectorMaxYear

        return {
            dictionary: {
                countries: await this.spiService.getCountries()
            },
            years: params.years?.length ? params.years :
                Array.from(
                    {length: vectorMaxYear - vectorMinYear + 1},
                    (_, index) => vectorMinYear + index
                ).map(String),
            update_date: new Date(await this.spiService.getIndicatorDownloadDate(params.domain)).toLocaleString(),
            type_prod: params.nomenclature?.toUpperCase(),
            data
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}

interface ICodes {
    [key: string]: IIndustryIndex[]
}

interface IIndustryIndex {
    industry: string
    index: number
}
