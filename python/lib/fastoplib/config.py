from os import getenv

apiKey = getenv('FASTOP_API_KEY', 'qgSZ],X9vHs49HM~|@u{"D8A[ae^fB')

# internal Node apps
daService = 'http://localhost:3101'
dashboardService = 'http://localhost:3103'
csService = 'http://localhost:3105'
taskService = 'http://localhost:3110'
dfmService = 'http://localhost:3210'
fdmsService =  'http://localhost:3260'
auxToolsService = 'http://localhost:3270'
dsloadService = 'http://localhost:3273'
bcsService = 'http://localhost:3290'

# internal python apps
sdmxService = 'http://localhost:3501'
amecoService = 'http://localhost:3505'
lakeManagerService = 'http://localhost:3510'

# external apps (public endpoints, api-key not required)
sdmxDisseminationService = 'http://localhost:3099/sdmx/dissemination'
