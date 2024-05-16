export interface IFmrMeta {
    id: string
    test: boolean
    schema: string
    prepared: string
    contentLanguages: string[]
    sender?: {
        id: string
    }
}

export interface IFmrAttributeRelationship {
    dimensions?: string[]
    primaryMeasure?: string
}

export interface IFmrLocalRepresentation {
    textFormat?: {
        maxLength?: number
        textType: string
    }
    enumeration?: string
}

export interface IFmrAttribute {
    id: string
    assignmentStatus: string
    attributeRelationship?: IFmrAttributeRelationship
    localRepresentation: IFmrLocalRepresentation
    conceptIdentity: string
}

export interface IFmrDimension {
    id: string
    position: number
    type: string
    localRepresentation: IFmrLocalRepresentation
    conceptIdentity: string
    links?: IFmrStructLink[]
}

export interface IFmrAnnotation {
    title: string
    type: string
}

export interface IFmrDatastructure {
    id: string
    annotations: IFmrAnnotation[]
    name: string
    names?: IFmrLangName
    version: string
    agencyID: string
    isExternalReference: boolean
    isFinal: boolean
    dataStructureComponents: {
        attributeList: {
            id: string
            attributes: IFmrAttribute[]
            links?: IFmrStructLink[]
        }
        dimensionList: {
            id: string
            dimensions: IFmrDimension[]
            timeDimensions: IFmrDimension[]
            links?: IFmrStructLink[]
        }
        measureList: {
            id: string
            primaryMeasure: {
                id: string
                localRepresentation: IFmrLocalRepresentation
                conceptIdentity: string
                links?: IFmrStructLink[]
            }
            links?: IFmrStructLink[]
        }
    }
    links?: IFmrStructLink[]
}

export interface IFmrLangName {
    [lang: string]: string
}

export interface IFmrStructLink {
    rel: string
    urn: string
    uri: string
    type: string
    hreflang: string
}

export interface IFmrDataflow {
    id: string
    name: string
    names?: IFmrLangName
    version: string
    agencyID: string
    isFinal: boolean
    isExternalReference: boolean
    structure: string
    links: IFmrStructLink[]
}

export interface IFmrAgency {
    id: string
    name: string
    names?: IFmrLangName
    links?: IFmrStructLink[]
}

export interface IFmrAgencyScheme {
    id: string
    name: string
    names?: IFmrLangName
    version: string
    agencyID: string
    isExternalReference: boolean
    isFinal: boolean
    isPartial: boolean
    agencies: IFmrAgency[]
    links?: IFmrStructLink[]
}

export interface IFmrResponse {
    meta: IFmrMeta
}

export interface IFmrDatastructureResponse extends IFmrResponse {
    data: {
        agencySchemes?: IFmrAgencyScheme[]
        dataStructures: IFmrDatastructure[]
        dataflows?: IFmrDataflow[]
    }
}

export interface IFmrDataflowResponse extends IFmrResponse {
    data: {
        dataflows: IFmrDataflow[]
    }
}

export interface IFpDataflow {
    id: string
    name: string
}

export interface IFpSerieAttribute {
    id: string
    dimensions: string[]
}

export interface IFpAttributes {
    observation?: string[] // observation level attributes
    series?: IFpSerieAttribute[] // series level attributes
    dataset?: string[] // dataset level attributes
}

export interface IFpDatastructure {
    id: string
    name: string
    dimensions: string[]
    timeDimensions: string[]
    measure: string
    attributes?: IFpAttributes
}


/*-------------------------------------------------
  ---------------------- XLSX ---------------------
  -------------------------------------------------*/
export interface IXlsxValue {
    t: 'n' | 's' // type, n - numeric, s - string (SheetJS standard)
    v?: string | number // value
    f?: string // formula
}

export interface IXlsxRow {
    [key: string]: IXlsxValue
}

export interface IXlsxSheet {
    name: string
    header: string[]
    rows: IXlsxRow[]
}

export interface IXlsxFile {
    name: string
    sheets: IXlsxSheet[]
}

export interface ILogUploadStatus{
    upload_status_id: string
    step: number
}

export interface IUploadFile {
    name: string
    size: number
}

// base model for state info
export interface IBaseState {
    error?: string
}

export interface IStateUpload extends IBaseState {
    files?: IUploadFile[]
}


export interface IStateValidation extends IBaseState {
    // TODO: define model
    result?: string
}

export interface IStatePublication extends IBaseState {
    result?: string
    warning?: string
}

export interface IUploadState {
    upload?: IStateUpload
    validation?: IStateValidation
    publication?: IStatePublication
}

export interface ILogUpload {
    uploadSid? :number
    userId?: string
    latestDate?: Date
    dataset: string
    provider: string
    status: string
    folder?: string
    state: IUploadState
}

export interface ILogUploadDataset {
    provider: string
    dataset: string
}

export interface ILogUploadUpdate {
    status: string
    state?: IUploadState
}

export const enum eLogStatus {
    DATASET = 'DATASET',
    UPLOADING = 'UPLOADING',
    UPLOADED = 'UPLOADED',
    VALIDATED = 'VALIDATED',
    VALIDATING = 'VALIDATING',
    PUBLISHING = 'PUBLISHING',
    PUBLISHED = 'PUBLISHED',
    FINISHED = 'FINISHED',
    CANCELLED = 'CANCELLED ',

}





