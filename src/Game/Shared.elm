module Game.Shared exposing (..)

import Game.Network.Types exposing (IP)


type alias ID =
    String


type alias ServerUser =
    String


isLocalHost : IP -> Bool
isLocalHost addr =
    (addr == "localhost" || addr == "127.0.0.1" || addr == "::1")


isRoot : ServerUser -> Bool
isRoot user =
    (user == "root" || user == "0")
