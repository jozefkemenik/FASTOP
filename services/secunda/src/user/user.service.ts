import * as crypto from 'crypto'
import { UsernameToken } from 'wsse'
import { create} from 'xmlbuilder2'
import { xml2json } from 'xml-js'

import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { RequestService } from '../../../lib/dist/request.service'
import { config } from '../../../config/config'

import { IAPIGWRole, IDBAuth, IDBUserAppGroup, IToken } from '.'

export class UserService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    private _fastopApps: Record<number, IDBUserAppGroup[]> = {}
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getFastopApps call the SOAP service to get the user Apps
     *********************************************************************************************/
    public async getFastopApps(external: boolean): Promise<IDBUserAppGroup[]> {
        const key = Number(external)
        if (!this._fastopApps[key]) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_only_external', type: NUMBER, value: key },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('mn_accessors.getFastopApps', options)
            this._fastopApps[key] = dbResult.o_cur
        }
        return this._fastopApps[key]
    }

    /**********************************************************************************************
     * @method getUserAuthzsUM
     *********************************************************************************************/
    public async getUserAuthzsUM(userId: string, unit: string): Promise<IDBAuth[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_user_id', type: STRING, value: userId },
                { name: 'p_unit_id', type: STRING, value: unit },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('um_user_accessors.getUserAuthzs', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getUserAuthzs call the SOAP service to get the user Authzs
     *********************************************************************************************/
    public async getUserAuthzs(userId: string, appId: string) {
        const result = await RequestService.requestUri(
            config.secunda.serviceUrl, 'post', this.generateSoapXML(userId, appId),
            {
                'Content-Type': 'text/xml;charset=UTF-8',
                'Connection': 'Keep-Alive',
                'User-Agent': 'Apache-HttpClient/4.1.1 (java 1.5)',
                'Accept-Encoding': 'gzip,deflate'
            },
        )
        return JSON.parse(xml2json(result, { compact: true }))
    }

    /**********************************************************************************************
     * @method getSecundaRoles call the APIGW to get the token
     *********************************************************************************************/
    public async getSecundaRoles(token: IToken, userId: string, roleId?: string, appId?: string): Promise<IAPIGWRole[]> {
        let url = ''
        if (roleId) {
            url = `${config.secunda.secundaEndpoint}/v1/roleRights`+
            `?serviceDomain=ECFIN&userId=${userId}&roleId=${roleId}&includeScopes=all&q=applicationId%3A%22FASTOP%2F${appId}%22`
        } else {
            url = `${config.secunda.secundaEndpoint}/v1/roleRights`+
            `?serviceDomain=ECFIN&userId=${userId}&includeScopes=no`
        }
        return RequestService.requestUri(
            url,
            'get', undefined, 
            {
                'Accept': 'application/json',
                'Authorization': `${token.token_type} ${token.access_token}`,
                'Authorization-Propagation': `${token.access_token}`
            }
        )
    }

    /**********************************************************************************************
     * @method getToken call the APIGW to get the token
     *********************************************************************************************/
     public async getToken() {
        const authString = Buffer.from(`${config.secunda.consumerKey}:${config.secunda.consumerSecret}`).toString('base64')
        return RequestService.requestUri(
            config.secunda.apiGatewayEndpoint,
            'post', 'grant_type=client_credentials',
            {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': `Basic ${authString}`
            }, {}, false, false
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method generateSecHeader generates security header for the SOAP envelope
     *********************************************************************************************/
    private generateSecHeader() {
        // generate token
        const token = new UsernameToken({
            username: config.secunda.username,
            password: config.secunda.password,
            created: new Date().toISOString(),
            sha1encoding: 'base64'
        })

        // generate encoded WSS
        const digest = token.getNonce() + token.getCreated() + token.getPassword()
        const sha1 = crypto.createHash('sha1');
        sha1.update(digest, 'utf8');
        const passDigest = sha1.digest().toString('base64')

        // define the XML Security header as object
        const soapSecHeader = {
            'wsse:Security': {
                '@xmlns:wsse': 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
                '@xmlns:wsu': 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd',
                'wsse:UsernameToken': {
                    'wsse:Username': token.getUsername(),
                    'wsse:Password': {
                        /* eslint-disable-next-line max-len */
                        '@Type': 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest',
                        '#text': passDigest
                    },
                    'wsse:Nonce': {
                        /* eslint-disable-next-line max-len */
                        '@EncodingType': 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary',
                        '#text': token.getNonceBase64()
                    },
                    'wsu:Created': token.getCreated()
                },
            }
        }

        return soapSecHeader
    }

    /**********************************************************************************************
     * @method generateSoapXML generates SOAP XML
     *********************************************************************************************/
    private generateSoapXML(userId: string, appId: string): string {
        const envelope = {
            'soapenv:Envelope': {
                '@xmlns:soapenv': `http://schemas.xmlsoap.org/soap/envelope/`,
                '@xmlns:typ': `http://ec.europa.eu/research/fp/service/secunda/author/types`,
                'soapenv:Header': this.generateSecHeader(),
                'soapenv:Body': {
                    'typ:AssignedRoleRightCriteria': {
                        'typ:userId': userId,
                        'typ:applicationId': 'FASTOP/' + appId,
                    }
                }
            }
        }
        // const xmlOptions = {compact: true }

        return create({ encoding: 'utf-8' }, envelope).end()
    }

}
