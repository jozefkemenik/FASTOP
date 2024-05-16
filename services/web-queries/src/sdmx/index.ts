import { ISdmxData, SdmxProvider } from '../../../lib/dist/sdmx/shared-interfaces'

export type SdmxFunction = (provider: SdmxProvider, dataset: string, seriesCode: string, fetchLabels: boolean,
                            startPeriod: string, endPeriod: string) => Promise<ISdmxData>
