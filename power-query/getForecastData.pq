// *** Use in: FDMS Forecast files (annual and quarterly) ***
// *** Authorization: Ecas (access code) + user must be ADMIN or be assigned to FORECAST group in secunda ***
// *** Example: getForecastData("ea_ms_annual")

let getForecastData=(ParametersNamedRange as text, optional archive as logical) =>

let
    archive_p  = if archive = true then true else false,
    restricted_p = if archive = true then false else true,
    ForecastData = getData(ParametersNamedRange, "fdms/forecast", restricted_p, archive_p)
in
    ForecastData
in getForecastData
