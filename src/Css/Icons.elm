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


windowUnmaximize : Icon
windowUnmaximize =
    faIcon FA.compress


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
    faIcon FA.wpexplorer


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


bounceMngr : Icon
bounceMngr =
    faIcon FA.exchange


upload : Icon
upload =
    faIcon FA.upload


download : Icon
download =
    faIcon FA.download


finance : Icon
finance =
    faIcon FA.money


hebamp : Icon
hebamp =
    faIcon FA.bolt


cpanel : Icon
cpanel =
    faIcon FA.sliders


srvgr : Icon
srvgr =
    faIcon FA.wrench


locpk : Icon
locpk =
    faIcon FA.streetView


lanvw : Icon
lanvw =
    faIcon FA.podcast


osLogo : Icon
osLogo =
    faIcon FA.superpowers


gateway : Icon
gateway =
    faIcon FA.home


bounce : Icon
bounce =
    faIcon FA.exchange


endpoint : Icon
endpoint =
    faIcon FA.flagCheckered


contextSelected : Icon
contextSelected =
    faIcon FA.crosshairs


contextSelect : Icon
contextSelect =
    faIcon FA.circleThin


notifications : Icon
notifications =
    faIcon FA.bellO


chat : Icon
chat =
    faIcon FA.commentO
