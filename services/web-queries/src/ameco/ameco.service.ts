import {
    IAmecoData,
    IAmecoInternalMetadataTree,
    IAmecoMetadataCountry,
    IAmecoMetadataDimension
} from '../../../external-data/src/ameco/shared-interfaces'
import {
    IWQAmecoDictionary,
    IWQAmecoInternalMetadataTreeNode,
    IWQAmecoRequestParams,
    IWQCtyIsoMap
} from './shared-interfaces'
import { IWQCountryIndicators, IWQInputParams } from '../shared/shared-interfaces'
import { ExternalDataApi } from '../../../lib/dist/api/external-data.api'
import { WqService } from '../shared/wq.service'


export class AmecoService extends WqService<IWQAmecoRequestParams, IWQAmecoDictionary> {

    public static readonly DEFAULT_COUNTRIES = 'DEFAULT'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _dictionary: IWQAmecoDictionary

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(
        params: IWQAmecoRequestParams, dictionary: IWQAmecoDictionary
    ): Promise<IWQCountryIndicators> {
        const countries = this.convertToIso3(
            !params.countryGroup ? params.countries : params.ctyGroupCountries, dictionary.countryIso2ToIso3
        )
        const ctyGrp = params.countryGroup ? params.countryGroup.toUpperCase() : undefined

        return ExternalDataApi.getAmecoFullData(
            params.amecoType, countries, params.indicators, ctyGrp === AmecoService.DEFAULT_COUNTRIES
        ).then(amecoData => this.formatIndicatorData(amecoData, params, dictionary))
    }

    /**********************************************************************************************
     * @method getDictionary
     *********************************************************************************************/
    public async getDictionary(): Promise<IWQAmecoDictionary> {
        if (!this._dictionary) {
            const countries: IAmecoMetadataCountry[] = await ExternalDataApi.getAmecoInternalMetadataCountries()
            this._dictionary = {
                countryIso2ToIso3: countries.reduce(
                    (acc, cty) => (acc[cty.ctyIso2] = cty.ctyIso3, acc), {}
                ),
                countryIso3ToIso2: countries.reduce(
                    (acc, cty) => (acc[cty.ctyIso3] = cty.ctyIso2, acc), {}
                ),
            }
        }
        return this._dictionary
    }

    /**********************************************************************************************
     * @method buildAmecoMetadataTree
     *********************************************************************************************/
    public buildAmecoMetadataTree(
        series: IAmecoMetadataDimension[], treeData: IAmecoInternalMetadataTree[]
    ): IWQAmecoInternalMetadataTreeNode[] {
        const serieMap = series.reduce((curr, val) => {
            // eslint-disable-next-line @typescript-eslint/no-unused-vars
            const [code, ...rest] = `${val.id}`.split('.')
            if (!curr[code]) curr[code] = []
            curr[code].push(val)
            return curr
        }, {})

        const nodesSet: Map<string, IWQAmecoInternalMetadataTreeNode> = treeData.reduce((curr, val) => {
            const node: IWQAmecoInternalMetadataTreeNode = this.treeNode(val)
            if (val.level === 1) {
                curr.set(this.levelKey(val.level, val.code), node)
            } else if (val.level === 2) {
                curr.set(this.levelKey(val.level, val.code, val.parentCode), node)
                this.addChild(curr.get(this.levelKey(1, val.parentCode)), node)
            } else if (val.level === 3) {
                const serie_ids = serieMap[val.code]
                if (serie_ids) {
                    if (serie_ids.length > 1) {
                        node.children = serie_ids.map(
                            (s: IAmecoMetadataDimension, index: number) => ({
                                code: `${s.id}`,
                                descr: s.descr,
                                level: val.level + 1,
                                orderBy: 1 + index + val.orderBy,
                                isLeaf: true,
                            })
                        )
                    } else {
                        const serie: IAmecoMetadataDimension = serie_ids[0]
                        node.code = `${serie.id}`
                        node.descr = serie.descr
                        node.isLeaf = true
                    }
                }

                const code = Math.floor((val.orderBy - (Number(val.parentCode) * 100000)) / 1000)
                this.addChild(curr.get(this.levelKey(2, code, val.parentCode)), node)
            }

            return curr
        }, new Map<string, IWQAmecoInternalMetadataTreeNode>())

        return Array.from(nodesSet.values()).filter(n => n.level === 1)
    }

    /**********************************************************************************************
     * @method normalizeCountry
     * @param countryId iso2 or iso3 country code
     * @return iso2 country code if params.useIso2 else iso2 country code
     *********************************************************************************************/
    public normalizeCountry(
        countryId: string, dictionary: IWQAmecoDictionary, params: IWQInputParams
    ): string {
        const useIso2 = (params as IWQAmecoRequestParams).useIso2

        if (countryId.length === 2) {
            const iso3Code = dictionary.countryIso2ToIso3[countryId]
            return useIso2 ? (iso3Code !== undefined ? countryId : undefined) : iso3Code
        }

        if (countryId.length === 3) {
            const iso2Code = dictionary.countryIso3ToIso2[countryId]
            return useIso2 ? iso2Code : (iso2Code !== undefined ? countryId : undefined)
        }

        // country groups have longer names
        return dictionary.countryIso3ToIso2[countryId] ? countryId : undefined
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method treeNode
     *********************************************************************************************/
    private treeNode(node: IAmecoInternalMetadataTree, isLeaf?: boolean): IWQAmecoInternalMetadataTreeNode {
        return {
            code: node.code,
            descr: node.descr,
            isLeaf,
            orderBy: node.orderBy,
            level: node.level,
        }
    }

    /**********************************************************************************************
     * @method key
     *********************************************************************************************/
    private key(...items: (string | number)[]): string {
        return items.join('_')
    }

    /**********************************************************************************************
     * @method levelKey
     *********************************************************************************************/
    private levelKey(level: number, code: string | number, parentCode?: string | number): string {
        return parentCode === undefined ? this.key(level, code) : this.key(level, parentCode, code)
    }

    /**********************************************************************************************
     * @method addTreeChild
     *********************************************************************************************/
    private addChild(parent: IWQAmecoInternalMetadataTreeNode, child: IWQAmecoInternalMetadataTreeNode)  {
        if (!parent.children) parent.children = []
        parent.children.push(child)
    }

    /**********************************************************************************************
     * @method convertToIso3
     *********************************************************************************************/
    private convertToIso3(countries: string[], countryIso2ToIso3: IWQCtyIsoMap): string[] {
        return countries?.map(cty => countryIso2ToIso3[cty] || cty)
    }

    /**********************************************************************************************
     * @method formatIndicatorData
     *********************************************************************************************/
    private formatIndicatorData(
        amecoData: IAmecoData[], params: IWQAmecoRequestParams, dictionary: IWQAmecoDictionary
    ): IWQCountryIndicators {
        if (!amecoData?.length) return { startYear: 0, vectorLength: -1, indicators: [] }

        const yearsRange = params.yearRange
        const useIso2 = params.useIso2

        let range = yearsRange
        if (!yearsRange || !yearsRange[0] || !yearsRange[1]) {
            range = this.getYearsRange(amecoData)
            range[0] = yearsRange[0] ?? range[0]
            range[1] = yearsRange[1] ?? range[1]
        }
        const vectorLength = 1 + range[1] - range[0]

        const indicators = amecoData.map(d => ({
            indicatorId: d.indicatorId,
            // ameco online doesn't provide iso2 country codes, so it has to be normalized from dictionary
            countryId: this.normalizeCountry(
                useIso2 && d.countryIdIso2 ? d.countryIdIso2 : d.countryIdIso3, dictionary, params
                ),
            name: d.name,
            countryDesc: d.countryDesc,
            scale: d.scale,
            vector: this.normalizeVector(d.vector, d.startYear, range[0])
        }))

        return { startYear: range[0], vectorLength, indicators }
    }

    /**********************************************************************************************
     * @method normalizeVector
     *********************************************************************************************/
    private normalizeVector(vector: number[], startYear: number, newStartYear: number): number[] {
        let normalized: number[] = vector
        if (newStartYear > startYear) {
            normalized  = vector.slice(newStartYear - startYear)
        } else if (newStartYear < startYear) {
            normalized = Array.from({ length: startYear - newStartYear }, () => null).concat(vector)
        }

        return normalized
    }

    /**********************************************************************************************
     * @method getYearsRange
     *********************************************************************************************/
    private getYearsRange(amecoData: IAmecoData[]): number[] {
        return amecoData.reduce(([minYear, maxYear], val) => {
            return [Math.min(minYear, val.startYear), Math.max(maxYear, val.startYear + val.vector.length - 1)]
        }, [3000, 0])
    }
}
