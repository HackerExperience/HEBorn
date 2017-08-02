port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Core.Style as Core
import Landing.Style as Landing
import UI.Style as UI
import Setup.Style as Setup
import OS.Style as OS
import OS.SessionManager.WindowManager.Style as WindowManager
import OS.SessionManager.Dock.Style as Dock
import Apps.Style as Apps


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "index.css"
          , Css.File.compile
                ([ Core.css
                 , Landing.css
                 , Setup.css
                 , OS.css
                 , UI.css
                 , WindowManager.css
                 , Dock.css
                 ]
                    ++ Apps.cssList
                )
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
