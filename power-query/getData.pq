let getData=(ParametersNamedRange as text, endpoint as text, restricted as logical, archive as logical) =>

let
    series= getParameter(ParametersNamedRange, "Indicators", true),
    cty = getParameter(ParametersNamedRange, "Countries", true),
    cty_grp = getParameter(ParametersNamedRange, "Country Group"),
    from = getParameter(ParametersNamedRange, "Start year"),
    to = getParameter(ParametersNamedRange, "End year"),
    show_round = getParameter(ParametersNamedRange, "Show round"),
    null_value = getParameter(ParametersNamedRange, "Null value"),

    year_arch = if archive = true then "&year=" & getParameter(ParametersNamedRange, "Year") else "",
    period_arch = if archive = true then "&period=" & getParameter(ParametersNamedRange, "Period") else "",
    storage_arch = if archive = true then "&storage=" & getParameter(ParametersNamedRange, "Storage") else "",
    archive_q = if archive = true then year_arch & period_arch & storage_arch else "",

    freq = getParameter(ParametersNamedRange, "Frequency"),
    cty_q = if cty <> null then "&cty=" & cty else "",
    cty_grp_q = if cty_grp <> null then "&cty_grp=" & cty_grp else "",
    from_q = if from <> null then "&from=" & from else "",
    to_q = if to <> null then "&to=" & to else "",
    show_round_q = if show_round = "Y" then "&show_round" else "",
    null_q = if null_value <> null then "&null=" & null_value else "",
    freq_q = if freq <> null then "&freq=" & freq else "",

    url = "https://intragate.ec.europa.eu/fastop/wq/" & endpoint & "?series=" & series & cty_q & cty_grp_q & from_q & to_q & freq_q & show_round_q & null_q & "&show_update" & archive_q,

    user = getParameter("Auth", "username"),
    pass = getParameter("Auth", "access code"),
    AuthToken= Binary.ToText(Text.ToBinary(user & ":" & pass), BinaryEncoding.Base64),

    commaSplitter = Splitter.SplitTextByDelimiter(","),
    commaCombiner = Combiner.CombineTextByDelimiter(","),
    seriesList = List.Transform(List.Split(commaSplitter(series), 100), commaCombiner),
    fetch = (s) => Web.Page(Web.Contents(url, if restricted = true then [Headers = [#"Authorization" = "Basic " & AuthToken]] else [])){0}[Data],

    dataList = List.Transform(seriesList, fetch),
    Data = Table.Combine(dataList),

    Data_no_header = Table.RemoveColumns(Data,{"Header"}),

    updated_column = "Update date",
    series_column = "Series code",

    // add series code column
    DataSeriesCode = Table.AddColumn(Data_no_header, series_column, each [Code]&"."&[TRN]&"."&[AGG]&"."&[UNIT]&"."&[REF]),
    ColumnNames = Table.ColumnNames(DataSeriesCode),
    ReorderedList = List.Combine({{updated_column, series_column}, List.Select(ColumnNames, (name) => name <> updated_column and name <> series_column)}),
    ReorderedData = Table.ReorderColumns(DataSeriesCode, ReorderedList),

    // change update date column type
    TransformedData = Table.TransformColumnTypes(ReorderedData, {{updated_column, type datetime}}),

    // format values as numbers
    YearColumns = List.Select(Table.ColumnNames(TransformedData), (column) => try Number.FromText(Text.Range(column, 0, 4)) > 0 otherwise false),
    ColumnTypes = List.Transform(YearColumns, (column) => { column, type number }),
    ConvertedData = Table.TransformColumnTypes(TransformedData, ColumnTypes , "en-US"),

    // remove unnecessary column
    ResultTable = Table.RemoveColumns(ConvertedData, {"Code", "TRN", "AGG", "UNIT", "REF", "Frequency"})
in
    ResultTable
in getData
