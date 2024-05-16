export interface IAmecoBaseData {
    amecoAgg: number
    numTrn: number
    numUnit: number
    numRef: number
    code: string
    name: string
    unit: string
    serie: {[year: string]: string}
}

export interface IAmecoData {
    indicatorId: string
    countryIdIso2: string
    countryIdIso3: string
    countryDesc: string
    name: string
    scale: string
    startYear: number
    vector: number[]
}

export interface IAmecoInternalLastUpdate {
    current: Date
    annex: Date
    restricted: Date
}

export type IAmecoLastUpdate = Date | IAmecoInternalLastUpdate

export interface IAmecoMetadataCountry {
    ctyIso3: string
    ctyIso2: string
    descr: string
    orderBy: number
    isDefault: number
}

export interface IAmecoMetadataDimension {
    id: number | string
    descr: string
}

export interface IAmecoInternalMetadataTree {
    code: string
    descr: string
    level: number
    orderBy: number
    parentCode: string
}
