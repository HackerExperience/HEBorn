port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import App.Dashboard.Style


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "index.css", Css.File.compile [ App.Dashboard.Style.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
