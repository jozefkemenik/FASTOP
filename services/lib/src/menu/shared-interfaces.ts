export const enum EMenuRepoTypes {
    MAIN_MENU = 'main_menu',
    SUBMENU = 'submenu',
    PAGE = 'page',
    URL = 'url',
    GRID = 'grid',
    QUESTIONNAIRE = 'fgd_quest',
    INDEX = 'fgd_index',
    VINTAGE = 'fgd_vintage'
}

export interface ICountry {
    CODEISO3: string
    CODE_FGD: number
    COUNTRY_ID: string
    DESCR: string
}

export interface IMenuBase {
    HELP_MESSAGE: string
    ICON: string
    LINK: string
    LINK_PARAMS: string
    MENU_REPO_SID: number
    MENU_REPO_ID: string
    MENU_REPO_TYPE_ID: EMenuRepoTypes
    TITLE: string
}

export interface IMenu extends IMenuBase {
    ITEMS?: IMenu[]
    width?: number
}

export interface ICountryGroup extends ICountry {
    members: ICountry[]
}
