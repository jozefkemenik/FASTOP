import {} from 'mocha'
import * as sinon from 'sinon'
import { should as chaiShould } from 'chai'

import { EMenuRepoTypes, IBuildMenuOptions, IDBCountry, IDBMenu, IMenu } from '../src/menu'
import { LibMenuController } from '../src/menu/menu.controller'

/* eslint-disable @typescript-eslint/no-unused-vars, @typescript-eslint/no-explicit-any */
const should = chaiShould()

describe('MenuController test suite', function() {
    const countries: IDBCountry[] = [
        {COUNTRY_ID: 'AT', DESCR: 'Austria', CODEISO3: 'AUT', CODE_FGD: 1},
        {COUNTRY_ID: 'BE', DESCR: 'Belgium', CODEISO3: 'BEL', CODE_FGD: 2},
        {COUNTRY_ID: 'BG', DESCR: 'Bulgaria', CODEISO3: 'BGR', CODE_FGD: 3},
    ]
    const appMenus: IDBMenu[] = [
        {MENU_REPO_SID: 1, MENU_REPO_ID: 'id1', TITLE: 't1', ICON: null, LINK: null, LINK_PARAMS: null,
         MENU_REPO_TYPE_ID: EMenuRepoTypes.MAIN_MENU, HELP_MESSAGE: null},
        {MENU_REPO_SID: 2, MENU_REPO_ID: 'id2', TITLE: 't2', ICON: null, LINK: null, LINK_PARAMS: null,
         MENU_REPO_TYPE_ID: EMenuRepoTypes.MAIN_MENU, HELP_MESSAGE: null},
    ]
    const submenus: IDBMenu[][] = [
        [],
        [
            {MENU_REPO_SID: 3, MENU_REPO_ID: 'id3', TITLE: 'p3', ICON: null, LINK: 'l3', LINK_PARAMS: null,
                MENU_REPO_TYPE_ID: EMenuRepoTypes.PAGE, HELP_MESSAGE: null},
            {MENU_REPO_SID: 4, MENU_REPO_ID: 'id4', TITLE: 's4', ICON: null, LINK: null, LINK_PARAMS: null,
                MENU_REPO_TYPE_ID: EMenuRepoTypes.PAGE, HELP_MESSAGE: null},
        ],
        [
            {MENU_REPO_SID: 5, MENU_REPO_ID: 'id5', TITLE: 'p5', ICON: null, LINK: '/l5', LINK_PARAMS: null,
                MENU_REPO_TYPE_ID: EMenuRepoTypes.PAGE, HELP_MESSAGE: null},
            {MENU_REPO_SID: 6, MENU_REPO_ID: 'id6', TITLE: 'p6', ICON: null, LINK: '/l6', LINK_PARAMS: null,
                MENU_REPO_TYPE_ID: EMenuRepoTypes.PAGE, HELP_MESSAGE: null},
        ],
        [],
        [
            {MENU_REPO_SID: 7, MENU_REPO_ID: 'id7', TITLE: 'p7', ICON: null, LINK: '/l7', LINK_PARAMS: null,
                MENU_REPO_TYPE_ID: EMenuRepoTypes.PAGE, HELP_MESSAGE: null},
        ]
    ]
    const menuService = {
        get menuRepoTypeMapping$() {return Promise.resolve({page: 3})},
        getCountries: sinon.fake(() => Promise.resolve(countries)),
        getAppMenus: sinon.fake((userGroups: string[]) => Promise.resolve(appMenus)),
        getMenuItems: (menuSid: number) => Promise.resolve(submenus[menuSid]),
    }
    const menuController = new LibMenuController(menuService as any)

    afterEach(function() {
        sinon.restore()
    })

    describe('getCountries', function() {
        it('should return all countries when user countries not passed', async function() {
            const result = await menuController.getCountries(undefined, true)
            result.should.eql(countries)
        })
        it('should return no countries if user has access to no countries', async function() {
            const result = await menuController.getCountries([], true)
            result.should.be.empty
        })
        it('should return filtered countries if user countries are passed', async function() {
            const result = await menuController.getCountries(['BE', 'PL'], true)
            result.should.eql([{COUNTRY_ID: 'BE', DESCR: 'Belgium', CODEISO3: 'BEL', CODE_FGD: 2}])
        })
    })

    describe('getMenus', function() {
        const options: IBuildMenuOptions = {userId: 'user1', userGroups: ['GROUP1', 'XYZ']}
        it('should call getAppMenus for specific user groups', async function() {
            await menuController.getMenus(options)
            menuService.getAppMenus.calledOnceWith(options.userGroups).should.be.true
        })
        it('should return hierarchical menus', async function() {
            const subm = [
                [...submenus[0]],
                [submenus[1][0], Object.assign({}, submenus[1][1], {ITEMS: [...submenus[4]]})],
                [...submenus[2]],
            ]
            const expected = appMenus.map((dbMenu, idx) => {
                const menu: IMenu = dbMenu
                menu.ITEMS = subm[idx]
                return menu
            })
            const result = await menuController.getMenus(options)
            result.should.eql(expected)
        })
    })
})
/* eslint-enable @typescript-eslint/no-unused-vars, @typescript-eslint/no-explicit-any */
