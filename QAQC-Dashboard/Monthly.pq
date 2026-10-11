// Query name: Monthly. Create a Text parameter WorkbookPath pointing to your Excel file.
let
    Source = Excel.Workbook(File.Contents(WorkbookPath), null, true),
    Sheet = Source{[Item="KPI Engine (Final)", Kind="Sheet"]}[Data],
    Columns = Table.SelectColumns(Sheet, List.Transform({1..8}, each "Column" & Text.From(_))),
    Header = Table.FirstN(Table.Skip(Columns, 52), 1),
    Body = Table.Range(Columns, 53, 11),
    Promoted = Table.PromoteHeaders(Table.Combine({Header, Body}), [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(Promoted, {{Table.ColumnNames(Promoted){0}, type date}} & List.Transform(List.Skip(Table.ColumnNames(Promoted)), each {_, type number}))
in
    Typed
