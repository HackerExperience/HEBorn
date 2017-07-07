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
import Apps.DBAdmin.Style
import Apps.ConnManager.Style
import Apps.Finance.Style
import Apps.BounceManager.Style
import Apps.Hebamp.Style


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
                , Apps.DBAdmin.Style.css
                , Apps.ConnManager.Style.css
                , Apps.Finance.Style.css
                , Apps.BounceManager.Style.css
                , Apps.Hebamp.Style.css
                ]
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
