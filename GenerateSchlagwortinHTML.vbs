'=============================
' UpdateTooltips_UTF8.vbs
'=============================
Option Explicit

Dim fso, folderPath, jsFile, tooltipData

' === Pfad zum HTML-Ordner ===
folderPath = "D:\Code\GitHub\TestProject\Seiten"

' === Pfad zur JS-Datei mit TooltipData ===
jsFile = "D:\Code\GitHub\TestProject\tooltipdata.js"

Set fso = CreateObject("Scripting.FileSystemObject")

' === TooltipData aus JS-Datei auslesen ===
Set tooltipData = CreateObject("Scripting.Dictionary")
Call LoadTooltipData(jsFile, tooltipData)

' === Alle HTML Dateien im Ordner und Unterordner durchgehen ===
Call ProcessFolder(folderPath, tooltipData)

WScript.Echo "Fertig: Tooltips aktualisiert."

'=============================
' Funktion: Alle HTML Dateien im Ordner bearbeiten
'=============================
Sub ProcessFolder(fPath, dict)
    Dim f, subF, file
    Set f = fso.GetFolder(fPath)
    
    ' Dateien
    For Each file In f.Files
        If LCase(fso.GetExtensionName(file.Name)) = "html" Then
            Call ProcessHTMLFile(file.Path, dict)
        End If
    Next
    
    ' Unterordner
    For Each subF In f.SubFolders
        Call ProcessFolder(subF.Path, dict)
    Next
End Sub

'=============================
' Funktion: einzelne HTML-Datei bearbeiten
'=============================
Sub ProcessHTMLFile(filePath, dict)
    Dim html, key, re

    ' === HTML-Datei mit UTF-8 einlesen ===
    html = ReadFileUTF8(filePath)

    ' --- 1. bestehende tooltips entfernen ---
    Set re = New RegExp
    re.Pattern = "<span class=""tooltip"" data-key=""[^""]*"">([^<]*)</span>"
    re.Global = True
    html = re.Replace(html, "$1") ' nur den Text zurücksetzen

    ' --- 2. für jeden Key Tooltip einfügen ---
    For Each key In dict.Keys
        html = InsertTooltip(html, key)
    Next

    ' --- 3. HTML-Datei wieder als UTF-8 speichern ---
    WriteFileUTF8 filePath, html
End Sub

'=============================
' Funktion: Tooltip in HTML einfügen (nur Text zwischen Tags)
'=============================
Function InsertTooltip(content, key)
    Dim regex, replacement
    Set regex = CreateObject("VBScript.RegExp")
    regex.Global = True
    regex.IgnoreCase = False ' Case-sensitive
    ' Pattern: alles zwischen > und <, dann den exakten Key
    regex.Pattern = "(>[^<]*?)(" & key & ")([^<]*?<)"
    
    replacement = "$1<span class=""tooltip"" data-key=""" & key & """>$2</span>$3"
    InsertTooltip = regex.Replace(content, replacement)
End Function

'=============================
' Funktion: JS-Datei auslesen und Dictionary füllen
'=============================
Sub LoadTooltipData(jsPath, dict)
    Dim ts, line, regex, matches, m
    Set ts = fso.OpenTextFile(jsPath, 1, False, -1)
    
    Set regex = New RegExp
    regex.Pattern = """([^""]+)""\s*:\s*""([^""]*)"""
    regex.Global = True

    Do While Not ts.AtEndOfStream
        line = ts.ReadLine
        Set matches = regex.Execute(line)
        For Each m In matches
            dict(m.SubMatches(0)) = m.SubMatches(1)
        Next
    Loop
    ts.Close
End Sub

'=============================
' UTF-8 lesen
'=============================
Function ReadFileUTF8(filePath)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 2 ' Text
    stream.Charset = "utf-8"
    stream.Open
    stream.LoadFromFile filePath
    ReadFileUTF8 = stream.ReadText
    stream.Close
    Set stream = Nothing
End Function

'=============================
' UTF-8 schreiben
'=============================
Sub WriteFileUTF8(filePath, text)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 2 ' Text
    stream.Charset = "utf-8"
    stream.Open
    stream.WriteText text
    stream.SaveToFile filePath, 2 ' 2 = overwrite
    stream.Close
    Set stream = Nothing
End Sub