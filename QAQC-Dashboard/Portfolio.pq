// Query name: Portfolio. Create a Text parameter WorkbookPath pointing to your Excel file.
let
    Source = Excel.Workbook(File.Contents(WorkbookPath), null, true),
    Sheet = Source{[Item="KPI Engine (Final)", Kind="Sheet"]}[Data],
    Columns = Table.SelectColumns(Sheet, List.Transform({1..11}, each "Column" & Text.From(_))),
    Header = Table.FirstN(Table.Skip(Columns, 67), 1),
    Body = Table.Range(Columns, 68, 24),
    Promoted = Table.PromoteHeaders(Table.Combine({Header, Body}), [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(Promoted, {{Table.ColumnNames(Promoted){0}, type text}} & List.Transform(List.Skip(Table.ColumnNames(Promoted)), each {_, type number}))
in
    Typed
