port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Core.Style as Core
import Landing.Style as Landing
import UI.Style as UI
import Setup.Style as Setup
import OS.Style as OS
import OS.Header.Style as Header
import OS.Console.Style as Console
import OS.Toasts.Style as Toasts
import OS.WindowManager.Style as WindowManager
import OS.WindowManager.Dock.Style as Dock
import OS.WindowManager.Sidebar.Style as Sidebar
import Apps.Style as Apps
import Apps.Browser.Pages.Style as BrowserPages


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "index.css"
          , Css.File.compile
                ([ Core.css
                 , Landing.css
                 , Setup.css
                 , Header.css
                 , Console.css
                 , Toasts.css
                 , OS.css
                 , UI.css
                 , WindowManager.css
                 , Dock.css
                 , Sidebar.css
                 ]
                    ++ Apps.cssList
                    ++ BrowserPages.cssList
                )
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
