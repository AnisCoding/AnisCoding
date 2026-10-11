let
    Source = SharePoint.Files("https://4ce.darriyadh.com/projects/S25183-0100S/", [ApiVersion = 15]),
    #"Filtered Rows" = Table.SelectRows(Source, each ([Extension] = ".xlsx")),
    #"Dirab Planning Data - Planning xlsx_https://4ce darriyadh com/projects/S25183-0100S/Dirab Dashboard all/2) planning/" = #"Filtered Rows"{[Name="Dirab Planning Data - Planning.xlsx",#"Folder Path"="https://4ce.darriyadh.com/projects/S25183-0100S/Dirab Dashboard all/2) planning/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(#"Dirab Planning Data - Planning xlsx_https://4ce darriyadh com/projects/S25183-0100S/Dirab Dashboard all/2) planning/"),
    #"02 - Flyovers Code_Sheet" = #"Imported Excel Workbook"{[Item="02 - Flyovers Code",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(#"02 - Flyovers Code_Sheet", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"02 - Flyovers", type text}, {"02 - Flyovers Description", type text}}),
    Base = Table.Buffer(#"Changed Type"),
    FlyGroup = Table.AddColumn(Base, "Flyover Group", (row as record) => Text.BeforeDelimiter(Record.Field(row, "02 - Flyovers"), "."), type text),
    GroupLookup = Table.Group(Base, {"02 - Flyovers"}, {{"Group Description", each List.First([#"02 - Flyovers Description"], null), type nullable text}}),
    JoinedGroups = Table.NestedJoin(FlyGroup, {"Flyover Group"}, GroupLookup, {"02 - Flyovers"}, "GroupLookupRows", JoinKind.LeftOuter),
    GroupDescription = Table.AddColumn(JoinedGroups, "Flyover Group Description", (row as record) => if Table.IsEmpty(Record.Field(row, "GroupLookupRows")) then Record.Field(row, "Flyover Group") else Record.Field(Record.Field(row, "GroupLookupRows"){0}, "Group Description"), type nullable text),
    FlyGroupDesc = Table.RemoveColumns(GroupDescription, {"GroupLookupRows"})
in
    FlyGroupDesc
