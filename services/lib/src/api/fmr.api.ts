import { RequestService } from '../request.service'
import { config } from '../../../config/config'

import {
    IFmrAttribute, IFmrAttributeRelationship,
    IFmrDataflowResponse,
    IFmrDatastructure,
    IFmrDatastructureResponse,
    IFmrDimension,
    IFpDataflow,
    IFpDatastructure,
} from 'fmr'

export class FmrApi {

    private static AGENCY = 'EC_ECFIN'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDataflows
     *********************************************************************************************/
    public static getDataflows(): Promise<IFpDataflow[]> {
        return FmrApi.getFmrDataflows().then(
            response => response.data.dataflows.map(
                dataflow => ({ id: dataflow.id, name: dataflow.name })
            )
        )
    }

    /**********************************************************************************************
     * @method getDatastructure
     *********************************************************************************************/
    public static async getDatastructure(dataflowId: string): Promise<IFpDatastructure> {
        const response = await FmrApi.getFmrDatastructureByDataflow(dataflowId)

        if (!response.data.dataStructures || !response.data.dataStructures.length) return undefined

        const dsd: IFmrDatastructure = response.data.dataStructures[0]
        const sortDims = (a: IFmrDimension, b: IFmrDimension) => a.position - b.position
        const attributes: IFmrAttribute[] = dsd.dataStructureComponents.attributeList?.attributes
        return {
            id: dsd.id,
            name: dsd.name,
            dimensions: dsd.dataStructureComponents.dimensionList.dimensions
                .sort(sortDims)
                .map(dim => dim.id),
            timeDimensions: dsd.dataStructureComponents.dimensionList.timeDimensions
                .sort(sortDims)
                .map(dim => dim.id),
            measure: dsd.dataStructureComponents.measureList.primaryMeasure.id,
            attributes: attributes ? attributes.reduce((acc, attr) => {
                const attrRel: IFmrAttributeRelationship = attr.attributeRelationship
                if (!attrRel || (!attrRel.dimensions && !attrRel.primaryMeasure)) {
                    // dataset level attribute
                    acc.dataset.push(attr.id)
                } else if (attrRel.dimensions !== undefined && attrRel.dimensions.length > 0) {
                    // series level attributes
                    acc.series.push({ id: attr.id, dimensions: attrRel.dimensions })
                } else if (attrRel.primaryMeasure !== undefined) {
                    // observation level attributes
                    acc.observation.push(attr.id)
                }
                return acc
            }, { observation: [], series: [], dataset: [] }) : undefined,
        }
    }

    /**********************************************************************************************
     * @method getFmrDataflows
     *********************************************************************************************/
    public static getFmrDataflows(): Promise<IFmrDataflowResponse> {
        return RequestService.requestUri(
            FmrApi.buildUrl('dataflow', 'all'),
        )
    }

    /**********************************************************************************************
     * @method getFmrDatastructureByDataflow
     *********************************************************************************************/
    public static getFmrDatastructureByDataflow(dataflowId: string): Promise<IFmrDatastructureResponse> {
        return RequestService.requestUri(
            FmrApi.buildUrl('dataflow', dataflowId, { references: 'children' }),
        )
    }

    /**********************************************************************************************
     * @method getFmrDatastructure
     *********************************************************************************************/
    public static getFmrDatastructure(dsdId: string): Promise<IFmrDatastructureResponse> {
        return RequestService.requestUri(
            FmrApi.buildUrl('datastructure', dsdId),
        )
    }

    /**********************************************************************************************
     * @method buildUrl
     *********************************************************************************************/
    private static buildUrl(objType: string, objId: string, urlParams?: IUrlParams): string {
        let query = ''
        if (urlParams !== undefined) {
           const searchParams = Object.entries(urlParams).reduce(
               (acc, [key, value]) => (acc.append(key, value), acc), new URLSearchParams()
           )
            query = `&${searchParams.toString()}`
        }

        return `${config.fmr}/structure/${objType}/${FmrApi.AGENCY}/${objId.toUpperCase()}/latest?format=sdmx-json${query}`
    }
}

interface IUrlParams {
    [key: string]: string
}
