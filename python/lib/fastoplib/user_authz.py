from fastapi import Depends, Header

class UserAuthz:

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(
        self,
        authLogin: str = Header(None),
        authDept: str = Header(None),
        authGroup: str = Header(None),
        authCountries: str = Header(None),
        internal: str = Header(None),
    ):
        self.__login = authLogin
        self.__dept = authDept
        self.__group = authGroup
        self.__countries = authCountries.split(',') if authCountries else [],
        self.__internal = internal == 'true'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    def is_su(self) -> bool:
        return self.__internal or 'SU' == self.__group

    ###############################################################################################
    def is_admin(self, or_higher = True) -> bool:
        return self.__internal or 'ADMIN' == self.__group or (or_higher and self.is_su())

    ###############################################################################################
    def is_cty_desk(self, or_higher = True) -> bool:
        return self.__internal or 'CTY_DESK' == self.__group or (or_higher and self.is_admin())
