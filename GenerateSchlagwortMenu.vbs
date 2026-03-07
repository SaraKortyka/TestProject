'=============================
' TooltipExport.vbs (angepasst für VBScript)
'=============================
Option Explicit

Dim xlApp, xlBook, xlSheet
Dim fso, outFile
Dim lastRow, r, keys, key, allKeys
Dim jsLine, desc, cell
Dim wsPath, outputPath

' === Pfad zur Excel-Datei ===
wsPath = "D:\Code\GitHub\TestProject\Schlagwörter.xlsx"
' === Pfad zur Ausgabe-JS-Datei ===
outputPath = "D:\Code\GitHub\TestProject\tooltipdata.js"

' === Excel öffnen ===
Set xlApp = CreateObject("Excel.Application")
xlApp.Visible = False
Set xlBook = xlApp.Workbooks.Open(wsPath)
Set xlSheet = xlBook.Sheets(1)

' === Datei schreiben ===
Set fso = CreateObject("Scripting.FileSystemObject")
Set outFile = fso.CreateTextFile(outputPath, True, True) ' True = überschreiben, True = Unicode

outFile.WriteLine "const TooltipData = {"

' === letzte Zeile in Spalte A ermitteln ===
lastRow = xlSheet.Cells(xlSheet.Rows.Count, 1).End(-4162).Row ' -4162 = xlUp

' Alle JS-Zeilen sammeln
allKeys = ""

For r = 2 To lastRow ' Annahme: Überschrift in Zeile 1
    cell = xlSheet.Cells(r, 1).Value
    desc = ConvertCellToHTML(xlSheet.Cells(r, 2))
    
    ' mehrere Keys verarbeiten
    keys = Split(cell, ",")
    For Each key In keys
        key = Trim(key)
        If key <> "" Then
            ' Escape von " im JS-String
            jsLine = "  """ & key & """: """ & Replace(desc, """", "\""") & """"
            allKeys = allKeys & jsLine & "," & vbCrLf
        End If
    Next
Next

' letztes Komma entfernen
If Right(allKeys, 3) = "," & vbCrLf Then
    allKeys = Left(allKeys, Len(allKeys) - 3)
End If

outFile.WriteLine allKeys
outFile.WriteLine "};"

outFile.Close
xlBook.Close False
xlApp.Quit

Set xlSheet = Nothing
Set xlBook = Nothing
Set xlApp = Nothing
Set outFile = Nothing
Set fso = Nothing

WScript.Echo "TooltipData.js erfolgreich erzeugt unter " & outputPath

'=============================
' Funktion: Zellinhalt + Format -> HTML
'=============================
Function ConvertCellToHTML(cell)
    Dim txt
    txt = cell.Text

    ' Fettschrift
    If cell.Font.Bold Then txt = "<b>" & txt & "</b>"
    ' Kursiv
    If cell.Font.Italic Then txt = "<i>" & txt & "</i>"
    ' Farbe
    If cell.Font.Color <> 0 Then
        Dim hexColor
        hexColor = Right("000000" & Hex(cell.Font.Color Mod 16777216), 6)
        txt = "<span style=""color:#" & hexColor & """>" & txt & "</span>"
    End If
    ' Zeilenumbruch
    txt = Replace(txt, vbLf, "<br>")
    
    ConvertCellToHTML = txt
End Function