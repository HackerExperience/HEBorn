module Css.Icons exposing (..)

import Css exposing (Mixin)
import Css.FontAwesome.Icons as FA
import Css.FontAwesome.Helper exposing (faIcon, fontAwesome)


type alias Icon =
    Mixin


fontFamily : Mixin
fontFamily =
    fontAwesome


explorer : Icon
explorer =
    faIcon FA.fileArchiveO


windowMinimize : Icon
windowMinimize =
    faIcon FA.windowMinimize


windowMaximize : Icon
windowMaximize =
    faIcon FA.expand


windowClose : Icon
windowClose =
    faIcon FA.timesCircle


directory : Icon
directory =
    faIcon FA.folderOpenO


fileGeneric : Icon
fileGeneric =
    faIcon FA.fileO


dirUp : Icon
dirUp =
    faIcon FA.levelUp


add : Icon
add =
    faIcon FA.plusCircle
