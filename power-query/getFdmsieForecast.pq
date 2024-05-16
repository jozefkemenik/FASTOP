// *** Use in: FDMSIE forecast data (International environment table) ***
// *** Authorization: Ecas (access code) + user must be ADMIN or be assigned to FORECAST group in secunda ***
// *** Example: getForecastData("table0")

let getForecastData=(ParametersNamedRange as text, optional archive as logical) =>

let
    archive_p  = if archive = true then true else false,
    restricted_p = if archive = true then false else true,
    ForecastData = getData(ParametersNamedRange, "fdmsie/forecast", restricted_p, archive_p)
in
    ForecastData
in getForecastData
