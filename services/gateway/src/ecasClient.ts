import { URLSearchParams } from 'url'
import { xml2js } from 'xml-js'

import { Level, LoggingService } from '../../lib/dist/logging.service'
import { RequestService } from '../../lib/dist/request.service'

import { IEcasUser } from './interfaces'

export enum ASSURANCE_LEVEL { LOW = 10, MEDIUM = 20, HIGH = 30, TOP = 40 }
export enum AUTHENTICATION_LEVEL { BASIC = 'BASIC', MEDIUM = 'MEDIUM', HIGH = 'HIGH' }

const userAgent = 'EcasNodeClient/0.0.0'
const supportedLocales = [
    'bg', 'cs', 'da', 'de', 'et', 'el', 'en', 'es', 'fr', 'hr', 'it', 'lv', 'lt', 'hu', 'mt', 'nl',
    'pl', 'pt', 'ro', 'sk', 'sl', 'fi', 'sv'
]

interface IEcasOptions {
    // Comma separated list of groups your application is interested in.
    // Only the specified or matching groups will be returned if the user is a member of them.
    // Accepts the '*' wildcard. (Default = no group requested)
    requestedGroups?: string

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////// ECAS server related URL's //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // ECAS host fragment to be used for all ECAS URLs (login, init, validate and proxy).
    ecasBaseUrl?: string

    // The url of the ECAS server login page you would like to use (Default = ECAS production login page)
    ecasLoginUrl?: string

    // The ECAS Server URL where an ECAS login request transaction is initiated
    ecasInitLoginUrl?: string

    // The ECAS ticket validation URL
    ecasValidateUrl?: string

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////// Authentication parameters //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Array of authentication strengths your application accepts.
    // Possible candidates are:
    // - 'BASIC' to authenticate on an ECAS Mockup,
    // - 'NTLM' for authentication with a Windows domain,
    // - 'CLIENT_CERT' to allow end-to-end monitoring,
    // - 'PASSWORDS_SMS' or 'PASSWORD_TOKEN for two-factor authentication (registration needed).
    // Default: 'PASSWORD,CLIENT_CERT'
    // the ECAS producion password strength plus certificate authentication for monitoring).
    acceptedStrengths?: string[]

    // Array of ticket types your application accepts.
    // Possible options are SERVICE, PROXY and DESKTOP.
    acceptedTicketTypes?: string[]

    // User identity assurance level required by the application, default to TOP.
    // Options:
    // - TOP (EC internale population only),
    // - HIGH (=TOP+interinstitutional),
    // - MEDIUM (=HIGH+sponsored accounts),
    // - LOW (=MEDIUM+self registered accounts)
    assuranceLevel?: ASSURANCE_LEVEL

    // A service provider that accepts a level allows all authentication mechanisms in it and
    // automatically accepts all levels above.
    // - BASIC (PASSWORD, NTLM, SOCIAL_NETWORKS, FEDERATION): Self-service requiring the Basic level or above
    // - MEDIUM (PASSWORD_SMS, PASSWORD_SOFTWARE_TOKEN, PASSWORD_MOBILE_APP, MOBILE_APP, PASSWORD_WEBAUTHN,
    //           MDM_CERT, EIDAS, FEDERATION): Self-service requiring the highest available level
    // - HIGH (PASSWORD_TOKEN, PASSWORD_TOKEN_CRAM, CLIENT_CERT): No self-service
    authenticationLevel?: AUTHENTICATION_LEVEL

    // Indicate that your application wants the user locale to be propagated to ECAS,
    // for this to work you must set the client locale first.
    // Note: language propagation is limited to registered applications which supports all european languages.
    propagateLocale?: boolean

    // User locale to propagate to ECAS, init param to dispense from calling setLocale function.
    // Note: only useful with propagateLocale=true. See setLocale() for details.
    locale?: string

    // Flag to ask for user details
    userDetails?: boolean

    // Flag to force the user to re-enter his password, reject SSO login for this application
    renew?: boolean

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////// ECAS proxy parameters //////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // The callback URL to receive proxy tickets from ECAS.
    // This argument is the trigger for proxy authentication mechanism.
    // If you specify a callback URL, you MUST also specify a proxyCacheDataSource.
    proxyCallbackUrl?: string

    // The ECAS url used to obtain proxy tickets
    ecasProxyUrl?: string

    // Name of the data source for storing proxy granting tickets.
    // The related database must contain the cache table before executing this code.
    proxyCacheDataSource?: string

    // Name of the database table for storing proxy granting tickets
    proxyCacheTable?: string

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////// ECAS client behaviour settings /////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Indicate the client to redirect to ECAS in case of invalid ECAS ticket.
    redirectOnInvalidTicket?: boolean

    // Flag to request for an exception to be thrown on authentication or proxy ticket request failure
    throwOnError?: boolean

    // For development and problem solving purposes,
    // will fill the variable 'ecasDebug' with the XML returned from ECAS
    // and log detailed information to the loggingFile
    debug?: boolean

    // Name of the log file to write log statements, if the debug flag is set
    loggingFile?: string
}

export interface IRequestInfo {
    protocol: string
    secure: boolean
    originalUrl: string
    query: {[key: string]: string}
}

export class EcasClient {

    private ecasBaseUrl = 'https://ecas.cc.cec.eu.int:7002'
    private ecasInitLoginUrl: string
    private ecasLoginUrl: string
    private ecasProxyUrl: string
    private ecasValidateUrl: string

    private acceptedStrengths: string[] = ['PASSWORD', 'CLIENT_CERT']
    private acceptedTicketTypes: string[] = ['SERVICE', 'PROXY']
    private assuranceLevel: ASSURANCE_LEVEL = ASSURANCE_LEVEL.TOP
    private authenticationLevel: AUTHENTICATION_LEVEL = AUTHENTICATION_LEVEL.MEDIUM
    private requestedGroups: string

    private locale: string
    private propagateLocale = false
    private userDetails = false
    private renew = false
    private redirectOnInvalidTicket = true

    private proxyCacheDataSource: string
    private proxyCacheTable = 'ECAS_PROXY_CACHE'
    private proxyCallbackUrl: string

    private debug = false
    private loggingFile = 'ecasclient'
    private throwOnError = false

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        // The url of your application server, where the ECAS server will redirect the user after authentication.
        // This must be your application's host part of the URL only,
        // the path is setup automatically by default or through the serviceUrlPath parameter if needed.
        // By default the complete redirection URL is dynamically build so, after authentication,
        // the user goes back to the exact page he requested.
        private serviceUrl: string,
        private unsecurePort: number,
        private securePort: number,
        private logs: LoggingService,

        options: IEcasOptions = {},
    ) {
        // Define all ECAS URL's
        if (options.ecasBaseUrl) this.ecasBaseUrl = options.ecasBaseUrl
        this.ecasInitLoginUrl = options.ecasInitLoginUrl || this.ecasBaseUrl + '/cas/login/init'
        this.ecasLoginUrl = options.ecasLoginUrl || this.ecasBaseUrl + '/cas/login'
        this.ecasValidateUrl = options.ecasValidateUrl || this.ecasBaseUrl + '/cas/TicketValidationService'
        this.ecasProxyUrl = options.ecasProxyUrl || this.ecasBaseUrl + '/cas/proxy'

        if (options.acceptedStrengths !== undefined) this.acceptedStrengths = options.acceptedStrengths
        if (options.acceptedTicketTypes !== undefined) this.acceptedTicketTypes = options.acceptedTicketTypes
        if (options.assuranceLevel !== undefined) this.assuranceLevel = options.assuranceLevel
        if (options.authenticationLevel !== undefined) this.authenticationLevel = options.authenticationLevel
        this.requestedGroups = options.requestedGroups
        if (options.propagateLocale !== undefined) this.propagateLocale = options.propagateLocale
        if (options.locale) this.setLocale(options.locale)
        if (options.userDetails) this.userDetails = options.userDetails
        if (options.renew) this.renew = options.renew
        if (options.redirectOnInvalidTicket !== undefined) {
            this.redirectOnInvalidTicket = options.redirectOnInvalidTicket
        }

        this.proxyCacheDataSource = options.proxyCacheDataSource
        if (options.proxyCacheTable) this.proxyCacheTable = options.proxyCacheTable
        this.proxyCallbackUrl = options.proxyCallbackUrl

        if (options.debug !== undefined) this.debug = options.debug
        if (options.loggingFile) this.loggingFile = options.loggingFile
        if (options.throwOnError !== undefined) this.throwOnError = options.throwOnError

        this.logs.log('Initialization of new ECAS client object done', Level.DEBUG)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method authenticate
    Authentication function.
    Must be called on new user or when the forceRenew flag is set.

    Takes an optional forceRenew flag, set to true to request re-authentication of logged-in users.

    Authentication process:
     - if the user presents a ticket, the function validates the ticket with ECAS, establishing
       an SSL connection and receiving the XML validation containing user data
     - if the user has no ticket or forceRenew is true, it will be redirected to the ECAS server.
       If the current browser contains a valid ECAS_TGC cookie for single sign-on,
       the login screen will not be presented.
       The user will be redirected after manual or automatic authentication, with a valid ticket, to this application.
     - if the user was in fact requesting a specific page with parameters (with a get),
       he will be redirected back to that specific page.

     Returns a promise with either login url in case of redirection or ecas user information if authenticated
     *********************************************************************************************/
    public authenticate(req: IRequestInfo, forceRenew = false, serviceUrlPath = ''): Promise<string|IEcasUser> {

        this.logs.log('Starting user authentication', Level.DEBUG)
        // Test if the user presents a ticket
        if (req.query.ticket) {
            this.logs.log(`Ticket present: ${req.query.ticket.substring(0, 30)}`, Level.DEBUG)
            return this.validateTicket(req, req.query.ticket, forceRenew, serviceUrlPath)
        } else {
            // Redirect to ECAS
            this.logs.log('No ticket, negotiating ECAS transaction', Level.DEBUG)
            return this.redirectToEcasLogin(req, forceRenew, serviceUrlPath)
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method addUrlAttribute
     *********************************************************************************************/
     private addUrlAttribute(url: string, key: string, value: string): string {
         let resultUrl = url

         if (url.indexOf('?') < 0) resultUrl += '?'
         else if (!url.endsWith('?')) resultUrl += '&'

         return `${resultUrl}${key}=${value}`
     }

    /**********************************************************************************************
     * @method assembleUrl assemble url from domain and path
     *********************************************************************************************/
    private assembleUrl(domain: string, path: string): string {
        return domain.trim().replace(/\/$/, '') + '/' + path.trim().replace(/^\//, '')
    }

    /**********************************************************************************************
     * @method buildServiceUrl
     *********************************************************************************************/
    private buildServiceUrl(req: IRequestInfo, serviceUrlPath: string): string {
        const port = req.secure ? this.securePort : this.unsecurePort
        const domain = req.secure ? this.serviceUrl.replace('http://', 'https://') : this.serviceUrl
        const portString = port ? `:${port}` : ''
        return this.assembleUrl(
            `${domain}${portString}`,
            serviceUrlPath ? serviceUrlPath : req.originalUrl.replace(/(\?|&)ticket=(\w|_|-)*/, ''),
        )
    }

    /**********************************************************************************************
     * @method parseAuthenticationSuccess
     *********************************************************************************************/
    private parseAuthenticationSuccess(success): IEcasUser {
        this.logs.log('Parsing authentication success', Level.DEBUG)

        const user: IEcasUser = {
            userId: success['cas:user'][0]._text[0],
            loginDate: success['cas:loginDate'][0]._text[0],
            groups: this.parseUserGroup(success['cas:groups'][0]['cas:group']),
        }

        if (this.userDetails) {
            user.departmentNumber = this.parseUserDetail(success['cas:departmentNumber'])
            user.email = this.parseUserDetail(success['cas:email'])
            user.employeeType = this.parseUserDetail(success['cas:employeeType'])
            user.firstName = this.parseUserDetail(success['cas:firstName'])
            user.lastName = this.parseUserDetail(success['cas:lastName'])
            user.domain = this.parseUserDetail(success['cas:domain'])
            user.domainUsername = this.parseUserDetail(success['cas:domainUsername'])
            user.telephoneNumber = this.parseUserDetail(success['cas:telephoneNumber'])
            user.locale = this.parseUserDetail(success['cas:locale'])
            user.userManager = this.parseUserDetail(success['cas:userManager'])
            user.pgtIou = this.parseUserDetail(success['cas:proxyGrantingTicket'])
        }

        this.logs.log(JSON.stringify(user), Level.DEBUG)
        return user
    }

    /**********************************************************************************************
     * @method parseUserGroup
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private parseUserGroup(group: any[]): string[] {
        return group ? group.map(g => g._text[0]) : []
    }

    /**********************************************************************************************
     * @method parseUserDetail
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private parseUserDetail(detail: any[]): string {
        if (detail) return detail[0]._text[0]
        else return undefined
    }

    /**********************************************************************************************
     * @method postToEcas Send an http request (POST) to the given ECAS url with the optional form content.
     * Return the reply as XML object
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private postToEcas(url: string, params: any): Promise<string> {
        this.logs.log(`Sending POST request to ECAS ${url} (${JSON.stringify(params)})`, Level.DEBUG)
        return RequestService.requestUri(
            url, 'post', new URLSearchParams(params),
            {
                'User-Agent': userAgent,
                // "Accept-Encoding":
                //     "identity;q=1.0, deflate;q=0, gzip;q=0, compress;q=0, x-gzip;q=0, x-compress;q=0, *;q=0",
                // "TE": "identity;q=1.0, deflate;q=0, gzip;q=0, compress;q=0, *;q=0",
                'Cache-Control': 'no-cache,no-store,no-transform',
                'Pragma': 'no-cache',
            },
            {
                maxRedirects: 0,
                timeout: 10000,
            },
        )
    }

    /**********************************************************************************************
     * @method redirectToEcasLogin
     *********************************************************************************************/
    private async redirectToEcasLogin(req: IRequestInfo, forceRenew: boolean, serviceUrlPath: string): Promise<string> {
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const loginRequestParams: any = {
            service: this.buildServiceUrl(req, serviceUrlPath),
            acceptStrengths: this.acceptedStrengths.join(),
            authenticationLevel: this.authenticationLevel,
        }
        if (this.renew || forceRenew) loginRequestParams.renew = true
        if (this.propagateLocale && this.locale) loginRequestParams.locale = this.locale

        const response = await this.postToEcas(this.ecasInitLoginUrl, loginRequestParams)
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const res: any = xml2js(response, { compact: true })
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const reqId: any = res.loginRequest.loginRequestSuccess.loginRequestId

        if (reqId) {
            const reqIdText: string = reqId._text
            this.logs.log(`Successfully received a login transaction id: ${reqIdText.substring(0, 30)}`, Level.DEBUG);
            const loginUrl = this.addUrlAttribute(this.ecasLoginUrl, 'loginRequestId', reqIdText)
            this.logs.log(`Redirecting user to ECAS: ${loginUrl.substring(0, 60)}`, Level.DEBUG);
            return loginUrl;
        } else {
            return Promise.reject(new Error(`Login transaction reply could not be parsed [${response}]`))
        }
    }

    /**********************************************************************************************
     * @method setLocale Set the ECAS required user locale as ISO-639-1 code,
     * useful only if propagateLocale was set and if the application is registered in ECAS.
     *********************************************************************************************/
    private setLocale(locale: string) {
        try {
            if (supportedLocales.indexOf(locale) < 0) {
                throw new Error(`Locale '${locale}' is not supported by ECAS`)
            }
            this.logs.log(`Setting user locale to ${locale}`, Level.INFO)
            this.locale = locale
        } catch (e) {
            this.logs.log(`Unable to set locale due to: ${e.message}`, Level.WARNING)
            if (this.throwOnError) throw e
        }
    }

    /**********************************************************************************************
     * @method validateTicket
     *********************************************************************************************/
    private async validateTicket(
        req: IRequestInfo,
        ticket: string,
        forceRenew: boolean,
        serviceUrlPath: string
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    ): Promise<any> {
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const ticketValidationParams: any = {
            ticket,
            service: this.buildServiceUrl(req, forceRenew ? serviceUrlPath : ''),
            ticketTypes: this.acceptedTicketTypes.join(),
            assuranceLevel: this.assuranceLevel,
            groups: this.requestedGroups,
            acceptedStrengths: this.acceptedStrengths.join(),
            authenticationLevel: this.authenticationLevel,
        }

        if (this.userDetails) ticketValidationParams.userDetails = this.userDetails
        if (this.proxyCallbackUrl) ticketValidationParams.pgtUrl = this.proxyCallbackUrl
        if (this.renew || forceRenew) ticketValidationParams.renew = true

        const response = await this.postToEcas(this.ecasValidateUrl, ticketValidationParams)
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const res: any = xml2js(response, { compact: true, alwaysArray: true })

        const serviceResponse = res['cas:serviceResponse'][0]
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        let success: any
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        let failure: any
        if (serviceResponse) {
            success = serviceResponse['cas:authenticationSuccess']
            failure = serviceResponse['cas:authenticationFailure']
        }
        if (failure) {
            this.logs.log(JSON.stringify(failure[0]), Level.DEBUG)
            const failureCode = failure[0]._attributes.code
            if (failureCode === 'INVALID_TICKET' || failureCode === 'INVALID_STRENGTH') {
                if (this.redirectOnInvalidTicket) {
                    // Ticket is not good, let's try to get another one
                    this.logs.log(`Invalid ticket, negociating new ECAS transaction`, Level.DEBUG);
                    return this.redirectToEcasLogin(req, forceRenew, serviceUrlPath);
                } else {
                    return Promise.reject(new Error('Invalid ticket provided'));
                }
            } else {
                // Ticket validation has failed beyond recovery
                return Promise.reject(new Error(`ECAS returned an authentication failure : ${failureCode}`));
            }
        } else if (success) {
            const user = this.parseAuthenticationSuccess(success[0]);
            this.logs.log('ECAS authentication succeeded', Level.DEBUG);
            return user;
        } else {
            return Promise.reject(new Error(`Ticket validation reply could not be parsed [${response}]`));
        }
    }
}
