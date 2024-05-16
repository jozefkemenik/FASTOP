import { NextFunction, Request, Response } from 'express'

import { AuthWqError, AuthzLibService, AuthzWqError } from '../../../lib/dist'

export class AuthzService {
    /**********************************************************************************************
     * @method checkWqAuthentication middleware function for web-query routes which require authentication check
     *********************************************************************************************/
    public static checkWqAuthentication(message = '') {
        return (req: Request, res: Response, next: NextFunction): void => {
            if (AuthzLibService.isInternalCall(req) || AuthzLibService.isAuthenticated(req)) {
                next()
            } else {
                next(new AuthWqError(message))
            }
        }
    }

    /**********************************************************************************************
     * @method checkWqAuthorisation middleware function for web-query routes which require authorisation check
     *********************************************************************************************/
    public static checkWqAuthorisation(...authzGroups: string[]) {
        return AuthzLibService.rolesAuthorisation(authzGroups, new AuthzWqError())
    }

    /**********************************************************************************************
     * @method checkWqCountryAuthorisation middleware function for web-query routes which require country access check
     *********************************************************************************************/
    public static checkWqCountryAuthorisation(
        countryGetter?: (req: Request) => string | string[],
        userGroups?: string[],
    ) {
        return AuthzLibService.checkCountryAuthorisation(countryGetter, userGroups, new AuthzWqError())
    }
}
