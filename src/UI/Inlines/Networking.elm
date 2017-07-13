module UI.Inlines.Networking exposing (user, addr, file)

import Html exposing (Html, Attribute, text, node)
import Html.Attributes exposing (attribute)
import Game.Network.Types exposing (IP)
import Game.Shared exposing (ServerUser, isRoot, isLocalHost)


addrAttrs : IP -> List (Attribute msg)
addrAttrs addr =
    if (isLocalHost addr) then
        [ attribute "localhost" "1" ]
    else
        []


userAttrs : ServerUser -> List (Attribute msg)
userAttrs user =
    if (isRoot user) then
        [ attribute "root" "1" ]
    else
        []


addr : IP -> Html msg
addr addr =
    node "linkAddr"
        (addrAttrs addr)
        [ node "ico" [] []
        , text " "
        , node "label" [] [ text addr ]
        ]


user : ServerUser -> Html msg
user user =
    node "linkUser"
        (userAttrs user)
        [ node "ico" [] []
        , text " "
        , node "label" [] [ text user ]
        ]


file : String -> Html msg
file fileName =
    node "linkFile" [] [ text fileName ]
