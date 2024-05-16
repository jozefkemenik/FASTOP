import {
    IEerCountry,
    IEerGeoGroup,
    IEerIndicatorData,
    IPublicationEertData,
    IPublicationWeightData
} from './shared-interfaces'
import { IProviderUpload } from '../../../fdms/src/upload/shared-interfaces'

export interface IDBEerIndicatorData extends Omit<IEerIndicatorData, 'timeserie'> {
    timeserieData: string
    periodicityId: string
}

export interface IDBPublicationEertData extends Omit<IPublicationEertData, 'timeserie'> {
    timeserieData: string
}

export type IDBProviderUpload = IProviderUpload
export type IDBEerCountry = IEerCountry
export type IDBEerGeoGroup = IEerGeoGroup
export type IDBPublicationWeightData = IPublicationWeightData

export interface IDBPublicationGeoArea {
    groupAlias: string
    groupId: string
    descr: string
    geoAreaId: string
    orderBy: number
}

export interface IPublicationConfig {
    provider: string
    indicator: string
}

export interface IGroupedWeightData {
    exporters: Set<string>
    importers: Set<string>
    data: { [key: string] : number }
}

export interface IGroupedWeights {
    [year: number]: IGroupedWeightData
}


export interface IReerPubGroupPeriod {
    [group: string]: { [periond:string]: IPublicationConfig[] }
}

export interface IGroupedPublicationGeo {
    [groupAlias: string]: IDBPublicationGeoArea[]
}

export interface IPublicationGeoAreas {
    eerColumns: IGroupedPublicationGeo
    weightColumns: IGroupedPublicationGeo
}

export interface IReerPeriodYear {
    [period: string]: { year: number, multiplier: number }
}
