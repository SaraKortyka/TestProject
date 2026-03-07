'=============================
' GenerateTooltipJS_UTF8_MultiKeys.vbs
'=============================
Option Explicit

Dim xlApp, xlBook, xlSheet
Dim lastRow, i, j, k
Dim keyCell, keys, cell, charCount, txt, prevStyle, ch, chStyle, colorHex, key
Dim jsFilePath, jsContent
Dim excelPath

' === Pfad zur Excel-Datei ===
excelPath = "D:\Code\GitHub\TestProject\Tooltipliste.xlsx"

' === Pfad zur JS-Datei, die erzeugt wird ===
jsFilePath = "D:\Code\GitHub\TestProject\tooltipdata.js"

' === Excel starten ===
Set xlApp = CreateObject("Excel.Application")
xlApp.Visible = False
Set xlBook = xlApp.Workbooks.Open(excelPath)
Set xlSheet = xlBook.Sheets(1) ' erste Tabelle

' === Letzte Zeile mit Daten in Spalte A ===
lastRow = xlSheet.Cells(xlSheet.Rows.Count, 1).End(-4162).Row ' xlUp=-4162

' === JS-Datei vorbereiten ===
jsContent = "const TooltipData = {" & vbCrLf

For i = 2 To lastRow ' Annahme: erste Zeile Überschrift
    keyCell = Trim(xlSheet.Cells(i, 1).Value)
    If keyCell <> "" Then
        ' Mehrere Keys durch Komma
        keys = Split(keyCell, ",")

        Set cell = xlSheet.Cells(i, 2) ' Beschreibung
        txt = ""
        prevStyle = ""

        charCount = Len(cell.Value)
        If charCount > 0 Then
            ' Zeichen für Zeichen durchgehen
            For j = 1 To charCount
                ch = Mid(cell.Value, j, 1)
                ' Zeilenumbruch in Excel erkennen (Chr(10)) -> <br>
                If Asc(ch) = 10 Then
                    ch = "<br>"
                End If

                ' Stil auslesen
                chStyle = ""
                If cell.Characters(j, 1).Font.Bold Then
                    chStyle = chStyle & "font-weight:bold;"
                End If
                chStyle = chStyle & "font-size:" & cell.Characters(j, 1).Font.Size & "pt;"
                colorHex = FontColorToHex(cell.Characters(j, 1).Font.Color)
                chStyle = chStyle & "color:" & colorHex & ";"

                ' Stilwechsel: neuen Span öffnen
                If chStyle <> prevStyle Then
                    If prevStyle <> "" Then txt = txt & "</span>"
                    txt = txt & "<span style=""" & chStyle & """>"
                    prevStyle = chStyle
                End If

                txt = txt & ch
            Next
            If prevStyle <> "" Then txt = txt & "</span>"
        End If

        ' Anführungszeichen escapen
        txt = Replace(txt, """", "\""")
        
        ' Jeden Key in JS einfügen
        For k = 0 To UBound(keys)
            key = Trim(keys(k))
            If key <> "" Then
                jsContent = jsContent & "  """ & key & """: """ & txt & """," & vbCrLf
            End If
        Next
    End If
Next

' Letztes Komma entfernen
If Right(jsContent, 3) = "," & vbCrLf Then
    jsContent = Left(jsContent, Len(jsContent) - 3) & vbCrLf
End If

jsContent = jsContent & "};" & vbCrLf

' === JS-Datei in UTF-8 schreiben ===
WriteTextFileUTF8 jsFilePath, jsContent

' === Excel schließen ===
xlBook.Close False
xlApp.Quit
Set xlSheet = Nothing
Set xlBook = Nothing
Set xlApp = Nothing

WScript.Echo "Tooltip JS erzeugt: " & jsFilePath

'=============================
' Hilfsfunktionen
'=============================
Function FontColorToHex(colorValue)
    Dim r, g, b
    r = colorValue Mod 256
    g = (colorValue \ 256) Mod 256
    b = (colorValue \ 65536) Mod 256
    FontColorToHex = "#" & Right("0" & Hex(r),2) & Right("0" & Hex(g),2) & Right("0" & Hex(b),2)
End Function

Sub WriteTextFileUTF8(filePath, content)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 2 ' Text
    stream.Charset = "utf-8"
    stream.Open
    stream.WriteText content
    stream.SaveToFile filePath, 2 ' Overwrite
    stream.Close
End Sub