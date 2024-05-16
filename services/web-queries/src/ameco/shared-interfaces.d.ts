import {
    IAmecoMetadataCountry,
    IAmecoMetadataDimension,
} from '../../../external-data/src/ameco/shared-interfaces'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { IWQRequestParams } from '../shared/shared-interfaces'

export interface IWQCtyIsoMap {
    [isoCode: string]: string // value is ISO other code (iso2 to iso3 or iso3 to iso2)
}

export interface IWQAmecoDictionary {
    countryIso2ToIso3: IWQCtyIsoMap
    countryIso3ToIso2: IWQCtyIsoMap
}

export interface IWQAmecoRequestParams extends IWQRequestParams {
    amecoType: AmecoType
    useIso2: boolean
    showName: boolean
    showCountryName: boolean
}

export interface IWQAmecoInternalMetadataTreeNode {
    code: string
    descr: string
    level: number
    isLeaf?: boolean
    orderBy: number
    children?: IWQAmecoInternalMetadataTreeNode[]
}

export interface IWQAmecoInternalMetadata {
    countries: IAmecoMetadataCountry[]
    trn: IAmecoMetadataDimension[]
    agg: IAmecoMetadataDimension[]
    unit: IAmecoMetadataDimension[]
    tree: IWQAmecoInternalMetadataTreeNode[]
}
