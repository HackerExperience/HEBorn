module Css.FontAwesome.Helper exposing (..)

import Css exposing (Style, Snippet, fontFamilies, before, property)


type alias UnicodeTag =
    String


fontAwesome : Style
fontAwesome =
    fontFamilies [ "FontAwesome" ]


faIcon : UnicodeTag -> Style
faIcon icon =
    icon
        |> (\tag -> "\"\\" ++ tag ++ "\"")
        |> property "content"


fa : UnicodeTag -> Style
fa icon =
    icon
        |> faIcon
        |> List.singleton
        |> (::) fontAwesome
        |> before
