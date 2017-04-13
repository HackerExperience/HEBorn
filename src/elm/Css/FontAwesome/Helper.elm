module Css.FontAwesome.Helper exposing (..)

import Css exposing (Mixin, fontFamilies)
import Css.Utils exposing(pseudoContent)

fontAwesome : Mixin
fontAwesome =
    fontFamilies ["FontAwesome"]

type alias UnicodeTag =
    String

contentStrWrap : UnicodeTag -> String
contentStrWrap unicode_tag =
    "\"\\"++(unicode_tag)++"\""

faIcon : UnicodeTag -> Mixin
faIcon icon =
    pseudoContent (contentStrWrap icon)

