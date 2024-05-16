import { EMenuRepoTypes, IBuildMenuOptions, ICountry, IMenu } from '../../../lib/dist/menu'
import { LibMenuController } from '../../../lib/dist/menu/menu.controller'

import { IDBQuestionnaire } from '../shared'
import { IQuestionnaireIndex } from '../questionnaires'
import { MenuService } from './menu.service'

import { EApps } from 'config'

export class MenuController extends LibMenuController<MenuService> {
    constructor(
        private appId: EApps,
        public menuService: MenuService) {
            super(menuService)
        }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method fillSubmenu
     * @overrides
     *********************************************************************************************/
    protected async fillSubmenu(
        menu: IMenu, {userId, userGroups}: IBuildMenuOptions
    ): Promise<IMenu[]> {
        const items = await this.menuService.getMenuItems(menu.MENU_REPO_SID, userGroups)
        let menuItems = await this.getMenuItems(items, {userId, userGroups})

        if (menu.MENU_REPO_TYPE_ID === EMenuRepoTypes.QUESTIONNAIRE) {

            // Add a separator if there are static menu items before
            if (menuItems.length) {
                menuItems.push(null)
            }

            menuItems = menuItems.concat(
                this.questionnairesToMenu(
                    menu.LINK,
                    await this.menuService.getQuestionnaires()
                )
            )
        } else if (menu.MENU_REPO_TYPE_ID === EMenuRepoTypes.INDEX) {

            // Add a separator if there are static menu items before
            if (menuItems.length) {
                menuItems.push(null)
            }

            menuItems = menuItems.concat(
                this.indexesToMenu(
                    menu.LINK,
                    await this.menuService.getQuestionnaireIndexes(this.appId)
                )
            )
        } else if (menu.MENU_REPO_TYPE_ID === EMenuRepoTypes.VINTAGE) {

            // Add a separator if there are static menu items before
            if (menuItems.length) {
                menuItems.push(null)
            }

            menuItems = menuItems.concat(
                this.vintagesToMenu(
                    menu.LINK,
                    await this.menuService.getVintageYears()
                )
            )
        }

        return menuItems
    }

    /**********************************************************************************************
     * @method filterCountry
     *********************************************************************************************/
    protected filterCountry(userCountries: string[]) {
        userCountries = userCountries.map(countryStr => countryStr.split('/')[0])
        return (country: ICountry) => userCountries.includes(country.COUNTRY_ID)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method questionnairesToMenu
     *********************************************************************************************/
    private questionnairesToMenu(baseRoute: string, questionnaires: IDBQuestionnaire[]): IMenu[] {
        return questionnaires.map(questionnaire => ({
            LINK: `${baseRoute}/${questionnaire.QUESTIONNAIRE_SID}`,
            MENU_REPO_TYPE_ID: EMenuRepoTypes.PAGE,
            TITLE: questionnaire.APP_ID,
            MENU_REPO_SID: questionnaire.QUESTIONNAIRE_SID,
        } as IMenu))
    }

    /**********************************************************************************************
     * @method indexesToMenu
     *********************************************************************************************/
    private indexesToMenu(baseRoute: string, questionnaires: IQuestionnaireIndex[]): IMenu[] {
        return questionnaires.map(questionnaire => ({
            LINK: `${baseRoute}/${questionnaire.INDEX_SID}`,
            MENU_REPO_TYPE_ID: EMenuRepoTypes.PAGE,
            TITLE: questionnaire.INDEX_ID,
        } as IMenu))
    }

    /**********************************************************************************************
     * @method vintagesToMenu
     *********************************************************************************************/
    private vintagesToMenu(baseRoute: string, years: number[]): IMenu[] {
        return years.map(year => ({
            LINK: `${baseRoute}/${year - 1}`,
            MENU_REPO_TYPE_ID: EMenuRepoTypes.PAGE,
            TITLE: `${year - 1}`,
        } as IMenu))
    }
}
