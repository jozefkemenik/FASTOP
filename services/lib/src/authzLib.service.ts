import { NextFunction, Request, Response } from 'express'

import { ApiKeyError, AuthzError } from './error.service'
import { config } from '../../config/config'


export class AuthzLibService {

    /**********************************************************************************************
     * @method checkApiKey middleware function for inner services
     *********************************************************************************************/
    public static checkApiKey() {
        return (req: Request, res: Response, next: NextFunction): void => {
            const apiKey = req.get('apiKey')
            if (!config.apiKey || apiKey === config.apiKey) {
                next()
            } else {
                next(new ApiKeyError())
            }
        }
    }

    /**********************************************************************************************
     * @method checkAuthorisation middleware function for routes which require authorisation check
     *********************************************************************************************/
    public static checkAuthorisation(...authzGroups: string[]) {
        return this.rolesAuthorisation(authzGroups)
    }

    /**********************************************************************************************
     * @method checkCountryAuthorisation middleware function for routes which require country access check,
     * with default country accessor function: req => req.params.countryId
     * with optional userGroups that should only be checked
     * with optional error instance that should be used in case of failed check
     *********************************************************************************************/
    public static checkCountryAuthorisation(
        countryGetter: (req: Request) => string | string[] = req => req.params.countryId,
        userGroups?: string[],
        error = new AuthzError(),
    ) {
        return (req: Request, res: Response, next: NextFunction): void => {
            // skip check for superuser, admin and internal calls
            if (this.isAdmin(req) || this.isInternalCall(req)) {
                next()
                return
            }

            const reqCountries = countryGetter(req)
            if (!reqCountries?.length) {
                next(error)
                return
            }

            let countries = typeof reqCountries === 'string' ? reqCountries.split(',') : reqCountries
            const authzs = this.getUserAuthzs(req)
            for (const authz of authzs) {
                if (userGroups && !userGroups.includes(this.getAuthzGroup(authz))) continue

                const userCountries = this.getAuthzCountries(authz)
                countries = countries.filter(country => !userCountries.includes(country.trim().toUpperCase()))

                if (!countries.length) break
            }

            if (!countries.length) {
                next()
            } else {
                next(error)
            }
        }
    }

    /**********************************************************************************************
     * @method getUserCountries
     *********************************************************************************************/
    public static getUserCountries(req: Request): string[] {
        return [...new Set(this.getUserAuthzs(req).flatMap(this.getAuthzCountries))]
    }

    /**********************************************************************************************
     * @method getUserGroups
     *********************************************************************************************/
    public static getUserGroups(req: Request): string[] {
        return this.getUserAuthzs(req).map(this.getAuthzGroup)
    }

    /**********************************************************************************************
     * @method isAuthenticated
     *********************************************************************************************/
    public static isAuthenticated(req: Request): boolean {
        return Boolean(req.get('authLogin'))
    }

    /**********************************************************************************************
     * @method isCtyDesk
     *********************************************************************************************/
    public static isCtyDesk(req: Request): boolean {
        return this.getUserGroups(req).some(group => ['SU', 'ADMIN', 'CTY_DESK'].includes(group))
    }

    /**********************************************************************************************
     * @method isAdmin
     *********************************************************************************************/
    public static isAdmin(req: Request): boolean {
        return this.getUserGroups(req).some(group => ['SU', 'ADMIN'].includes(group))
    }

    /**********************************************************************************************
     * @method isMS
     *********************************************************************************************/
    public static isMS(req: Request): boolean {
        return this.getUserGroups(req).some(group => group === 'MS')
    }

    /**********************************************************************************************
     * @method isReadOnly
     *********************************************************************************************/
    public static isReadOnly(req: Request): boolean {
        return this.getUserGroups(req).some(group => group === 'READ_ONLY')
    }

    /**********************************************************************************************
     * @method isInternalCall
     *********************************************************************************************/
    public static isInternalCall(req: Request): boolean {
        return req.get('internal') === 'true'
    }

    /**********************************************************************************************
     * @method rolesAuthorisation
     *********************************************************************************************/
    public static rolesAuthorisation(authzGroups: string[], error = new AuthzError()) {
        return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
            const userGroups = this.getUserGroups(req)
            if (
                this.isInternalCall(req) ||
                userGroups.includes('SU') ||
                userGroups.some(userGroup => authzGroups.includes(userGroup))
            ) {
                next()
            } else {
                next(error)
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAuthzGroup
     *********************************************************************************************/
    private static getAuthzGroup(authz: string): string {
        return authz.split(',')[0]
    }

    /**********************************************************************************************
     * @method getAuthzCountries
     *********************************************************************************************/
    private static getAuthzCountries(authz: string): string[] {
        return authz.split(',').slice(1).filter(Boolean)
    }

    /**********************************************************************************************
     * @method getUserAuthzs
     *********************************************************************************************/
    private static getUserAuthzs(req: Request): string[] {
        return (req.get('authzs') ?? '').split('|').filter(Boolean)
    }
}
