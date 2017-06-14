port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Core.Style as Core
import UI.Style as UI
import OS.Style as OS
import OS.SessionManager.WindowManager.Style as WindowManager
import OS.SessionManager.Dock.Style as Dock
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
                [ Core.css
                , OS.css
                , UI.css
                , WindowManager.css
                , Dock.css
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
