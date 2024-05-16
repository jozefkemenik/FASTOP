export interface IAmecoInternalLegacyInputParams {
    transpose?: boolean
    showVariable: boolean
    useIso3: boolean
    showFullVariable: boolean
    showFullCode: boolean
    showLabel: boolean
}

export interface IAmecoLegacyInputParams {
    indicators: string[]
    countries: string[]
    defaultCountries: boolean
    years: number[]
    lastYear: boolean
    orderDesc: boolean
    internal?: IAmecoInternalLegacyInputParams
}
