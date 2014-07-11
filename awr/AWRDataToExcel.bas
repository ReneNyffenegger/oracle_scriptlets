'
'      See also
'          o https://github.com/ReneNyffenegger/development_misc/blob/master/vba/excel/some_data_import.bas    and
'          o https://github.com/ReneNyffenegger/development_misc/blob/master/vba/excel/CSV_import.bas
'
option explicit

public sub Run(csvFileName as string, lineCharacteristics as string) ' {

    dim diagram as chart

    createDataAndDiagramSheet

    importCsv csvFileName

    set diagram = application.sheets("diagram")

    assignDataToChart diagram
    formatChart       diagram, lineCharacteristics


end sub ' }

private sub createDataAndDiagramSheet() ' {

   ' There need to be two work sheets. One for the data (that is «imported» 
   ' from a csv file, and one for the created diagram that is based on that
   ' data
   '
   ' When Excel starts, there is one sheet.

   dim sh_diagram as chart 

   if application.sheets.count <> 1 then
      msgBox "Assumption about count of sheets was wrong, the count is: " & application.sheets.count
   end if

   ' Name this first sheet data

   application.sheets(1).name = "data"

   ' Insert the second sheet for the diagram:

   set sh_diagram = application.sheets.add (type := xlChart)

   sh_diagram.name = "diagram"

   
end sub ' }

private sub importCsv(csvFileName as string) ' {
'
'       https://github.com/ReneNyffenegger/development_misc/blob/master/vba/excel/some_data_import.bas
'

    dim qt      as queryTable
    dim dest    as range
    dim sh      as workSheet

    set sh   = application.sheets("data")
    set dest = application.range("data!$a$1")

    set qt   = sh.queryTables.add(connection   := "TEXT;" & csvFileName, _
                                  destination  :=  dest)


    qt.textFileParseType          = xlDelimited
    qt.textFileSemicolonDelimiter = true

    qt.name = "imported_data"

    qt.refresh

end sub ' }

private sub assignDataToChart(diagram as chart) ' {

  diagram.setSourceData source := range("data!imported_data")

end sub ' }

private sub setPageUp(diagram as chart) ' {

  dim ps as pageSetup

  set ps = diagram.pageSetup

  ps.leftMargin   = application.centimetersToPoints(0.5)
  ps.rightMargin  = application.centimetersToPoints(0.5)
  ps.topMargin    = application.centimetersToPoints(0.5)
  ps.bottomMargin = application.centimetersToPoints(0.5)

  ps.headerMargin = application.centimetersToPoints( 0 )
  ps.footerMargin = application.centimetersToPoints( 0 )

end sub ' }

private sub formatChart(diagram as chart, lineCharacteristics as string) ' {

  dim leg as legend
  dim ser as series

  dim characteristicsArray() as string
  dim columnNameAndvalues () as string
  dim columnValues           as string
  dim valuesArray         () as string
  dim rgb_s                  as string
  dim width                  as double
  dim rgbArray            () as string
  dim i                      as long

  dim columnName as string

  dim s as string

  diagram.chartType = xlLine

  diagram.plotArea.top    =   9
  diagram.plotArea.left   =  45
  diagram.plotArea.width  = 748
  diagram.plotArea.height = 480

  setPageUp diagram

  ' { legend

  set leg = diagram.legend

  leg.includeInLayout = false

  leg.format.fill.foreColor.objectThemeColor = msoThemeColorBackground1
  leg.format.fill.transparency = 0.3
  leg.format.fill.solid

  ' }


  '   Split the line charactersistics into its components...
  characteristicsArray = split(lineCharacteristics, ";")

  '   and iterate over each element for the line characteristics
  for i = lbound(characteristicsArray) to ubound(characteristicsArray) ' {

  '   A component is supposed to be
  '
  '  "Column Name:values...."
  '
  '   So, we split on the ":" ...

      columnNameAndvalues = split(characteristicsArray(i), ":")

  '   in order to get columnName and columnNameAndvalues
      columnName   = columnNameAndvalues(0)
      columnValues = columnNameAndvalues(1)

  '   The values itself are supposed to be divided by a "|":

      valuesArray  = split(columnValues, "|")

  '   Left of the bar is the desired rgb value ("red,green,blue"), right of the
  '   bar the width of the line

      rgb_s   = valuesArray(0)
      width   = valuesArray(1)

      rgbArray = split(rgb_s, ",")

   '  cstr()? 
   '  See http://stackoverflow.com/questions/12620239/what-is-the-difference-between-string-variable-and-cstrstring-variable
      set ser = diagram.seriesCollection.item(cstr(columnName))

      ser.format.line.foreColor.rgb = rgb(rgbArray(0),rgbArray(1),rgbArray(2))
      ser.format.line.weight        = width

    ' i = i + 1

  next i ' }

end sub ' }
