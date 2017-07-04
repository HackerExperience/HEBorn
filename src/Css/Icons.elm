module Css.Icons exposing (..)

import Css exposing (Style)
import Css.FontAwesome.Icons as FA
import Css.FontAwesome.Helper exposing (faIcon, fontAwesome)


type alias Icon =
    Style


fontFamily : Style
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


directoryExpanded : Icon
directoryExpanded =
    faIcon FA.folderOpen


directoryUntouched : Icon
directoryUntouched =
    faIcon FA.folder


branchExpanded : Icon
branchExpanded =
    faIcon FA.plusSquare


branchUntouched : Icon
branchUntouched =
    faIcon FA.minusSquare


fileGeneric : Icon
fileGeneric =
    faIcon FA.fileO


dirUp : Icon
dirUp =
    faIcon FA.levelUp


add : Icon
add =
    faIcon FA.plusCircle


virus : Icon
virus =
    faIcon FA.bug


firewall : Icon
firewall =
    faIcon FA.shield


modeActive : Icon
modeActive =
    faIcon FA.bomb


modePassive : Icon
modePassive =
    faIcon FA.wpExplorer


logvw : Icon
logvw =
    faIcon FA.book


view : Icon
view =
    faIcon FA.eye


user : Icon
user =
    faIcon FA.addressBookO


edit : Icon
edit =
    faIcon FA.pencil


filter : Icon
filter =
    faIcon FA.filter


locationTarget : Icon
locationTarget =
    faIcon FA.thumbTack


person : Icon
person =
    faIcon FA.user


lock : Icon
lock =
    faIcon FA.lock


trash : Icon
trash =
    faIcon FA.trash


unlock : Icon
unlock =
    faIcon FA.key


apply : Icon
apply =
    faIcon FA.check


cancel : Icon
cancel =
    faIcon FA.times


home : Icon
home =
    faIcon FA.home


divExpand : Icon
divExpand =
    faIcon FA.chevronDown


divContract : Icon
divContract =
    faIcon FA.chevronUp


dangerous : Icon
dangerous =
    faIcon FA.exclamationTriangle


browser : Icon
browser =
    faIcon FA.globe


taskMngr : Icon
taskMngr =
    faIcon FA.listAlt


dbAdmin : Icon
dbAdmin =
    faIcon FA.database


connMngr : Icon
connMngr =
    faIcon FA.wifi
