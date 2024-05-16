
import { ISemiElasticityData } from '../shared/shared-interfaces'
import { SemiElasticityService } from './semi-elasticity.service'

export class SemiElasticityController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private elasticityService: SemiElasticityService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public getCountries(): Promise<string[]> {
        return this.elasticityService.getEU27CountyCodes()
    }

    /**********************************************************************************************
     * @method storeElasticity
     *********************************************************************************************/
    public storeElasticity(roundSid: number, elasticity: Record<string, number>): Promise<number> {
        const lists: { countries: string[], values: number[] } = Object.entries(elasticity).reduce(
            (acc, [countryId, value]) => {
                acc.countries.push(countryId)
                acc.values.push(value)
                return acc
            }, { countries: [], values: [] })

        return this.elasticityService.storeElasticity(roundSid, lists.countries, lists.values)
    }

    /**********************************************************************************************
     * @method getElasticityData
     *********************************************************************************************/
     public getElasticityData(): Promise<ISemiElasticityData[]> {
        return this.elasticityService.getElasticityData()
    }

}
