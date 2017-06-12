port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Core.Style
import OS.Style
import OS.WindowManager.Style
import OS.Dock.Style
import Apps.Explorer.Style
import Apps.LogViewer.Style
import Apps.Browser.Style
import Apps.TaskManager.Style


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "index.css"
          , Css.File.compile
                [ Core.Style.css
                , OS.Style.css
                , OS.WindowManager.Style.css
                , OS.Dock.Style.css
                , Apps.Explorer.Style.css
                , Apps.LogViewer.Style.css
                , Apps.Browser.Style.css
                , Apps.TaskManager.Style.css
                ]
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
