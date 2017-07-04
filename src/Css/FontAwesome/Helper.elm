module Css.FontAwesome.Helper exposing (..)

import Css exposing (Style, fontFamilies)
import Css.Utils exposing (pseudoContent)


fontAwesome : Style
fontAwesome =
    fontFamilies [ "FontAwesome" ]


type alias UnicodeTag =
    String


contentStrWrap : UnicodeTag -> String
contentStrWrap unicode_tag =
    "\"\\" ++ (unicode_tag) ++ "\""


faIcon : UnicodeTag -> Style
faIcon icon =
    pseudoContent (contentStrWrap icon)
