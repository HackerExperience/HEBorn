port module Stylesheets exposing (..)


import Css.File exposing (CssFileStructure, CssCompilerProgram)


import Core.Style
import OS.Style
import OS.WindowManager.Style
import Apps.Explorer.Style


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "index.css", Css.File.compile
                [ Core.Style.css
                , OS.Style.css
                , OS.WindowManager.Style.css
                , Apps.Explorer.Style.css
                ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
