export interface IDwhIndicator {
    indicatorId: string
    periodicityId: string
    descr: string
}

export interface IDwhIndicatorData {
    indicatorId: string
    periodicityId: string
    startYear: number
    vector: number[]
    updateDate: string
    updateUser: string
}
