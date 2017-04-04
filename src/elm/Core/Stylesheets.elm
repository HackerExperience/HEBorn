port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Apps.Dashboard.Style


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "index.css", Css.File.compile [ Apps.Dashboard.Style.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
