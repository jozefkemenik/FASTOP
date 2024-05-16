export interface ITcePartner {
    code: string
    descr: string
}

export interface ITceTradeIndicator {
    indicatorId: string
    partner: string
}

export interface ITceTradeItem {
    name: string
    goods: ITceTradeIndicator
    services: ITceTradeIndicator
    goodsAndServices: ITceTradeIndicator
}
