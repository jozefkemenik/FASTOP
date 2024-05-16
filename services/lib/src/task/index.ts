import { EApps } from 'config'

export type ComputationService = EApps.FDMSSTAR | EApps.HICP | EApps.NEER
export type TaskComputationService = { [taskId: string]: ComputationService }

export type ComputationServiceType = ComputationService | TaskComputationService
