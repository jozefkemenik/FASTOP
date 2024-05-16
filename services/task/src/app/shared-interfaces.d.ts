export const enum ETasks {
    CALCULATION = 'CALCULATION',
    VALIDATION = 'VALIDATION',
    AGGREGATION = 'AGGREGATION',
    TCE = 'TCE',
    CYCL_ADJ = 'CYCLICAL-ADJUSTMENTS',
    IEA_CALC = 'IEA-CALCULATION',
    IEA_AGG = 'IEA-AGGREGATION',
    OIL_PRICE = 'OIL-PRICE',
    KNP = 'KNP',
    WORLD_AGG = 'WORLD-AGGREGATION',
    ESTAT_Q_LOAD = 'ESTAT-Q-LOAD',
    ESTAT_M_LOAD = 'ESTAT-M-LOAD',
    ESTAT_A_LOAD = 'ESTAT-A-LOAD',
    HICP_DATA_REFRESH = 'HICP-DATA-REFRESH',
    OG_AGG = 'OG-AGGREGATION',
    AMECO_UNEMPL = 'AMECO-UNEMPLOYMENT',
    AMECO_NSI = 'AMECO-NSI',
    EER_WEIGHTS = 'EER-WEIGHTS',
    NEER = 'NEER',
    REER = 'REER',
}

export const enum ETaskStatuses {
    READY = 'READY',
    RUNNING = 'RUNNING',
    SAVING = 'SAVING',
    DONE = 'DONE',
    ERROR = 'ERROR',
    WARNING = 'WARNING',
    ABORT = 'ABORT',
}

export const enum ETaskStepTypes {
    SAME_FREQ = 'SAME_FREQ',
    CROSS_FREQ = 'CROSS_FREQ',
    MISSING = 'MISSING',
}

interface ITaskRun {
    TASK_RUN_SID: number
    TASK_STATUS_ID: string
    USER_RUN: string
    END_RUN: string
}

export interface ICountryTask extends ITaskRun {
    ALL_STEPS: number
    STEPS_COMPLETED: number
    ALL_PREP_STEPS: number
    PREP_STEPS: number
}

export interface ICountryTaskRun extends ITaskRun {
    COUNTRY_ID: string
}

export interface ITaskLog {
    STEP_NUMBER: number
    STEP_DESCR: string
    STEP_STATUS_ID: string
    STEP_TIMESTAMP: Date
    STEP_MESSAGE: string
}

export interface ITaskLogs {
    taskStatusId: string
    taskLogs: ITaskLog[]
}

export interface ITaskException {
    STEP_NUMBER: number
    STEP_EXCEPTIONS: number
    TASK_STEP_TYPE_ID: string
}

export interface IValidationStepDetail {
    INDICATOR_ID: string
    DESCR: string
    LABELS: string
    ACTUAL: string
    VALIDATION1: string
    VALIDATION2: string
    FAILED: string
}

export interface IAddConcurrentSteps {
    steps: number[]
}

export interface IFinishTask {
    statusId: ETaskStatuses
    steps?: number
}

export interface ILogStep {
    exceptions: number
    statusId: ETaskStatuses
    stepTypeId?: ETaskStepTypes
    description?: string
    message?: string
}

export interface ILogStepValidations {
    labels: string
    indicators: string[]
    actual: string[]
    validation1: string[]
    validation2: string[]
    failed: string[]
}

export interface IPrepareTask {
    taskId: ETasks
    countryIds: string[]
    prepSteps: number
    user: string
    concurrency?: number
}

export interface ISetTaskRunAllSteps {
    steps: number
}
