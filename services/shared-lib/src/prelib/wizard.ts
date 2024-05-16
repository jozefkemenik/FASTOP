import { ELibColumn } from './shared-interfaces/wizard'

export * from './shared-interfaces/wizard'

export function getMeasureWizardColumnYearKey(year: number) {
    return 'M_' + year as ELibColumn
}
