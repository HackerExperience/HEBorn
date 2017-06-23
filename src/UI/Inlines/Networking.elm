module UI.Inlines.Networking exposing (user, addr, file)

import Html exposing (Html, Attribute, text, node)
import Html.Attributes exposing (attribute)
import Game.Shared exposing (IP, ServerUser, isRoot, isLocalHost)


renderAddrAttrs : IP -> List (Attribute msg)
renderAddrAttrs addr =
    if (isLocalHost addr) then
        [ attribute "data-localhost" "1" ]
    else
        []


renderUserAttrs : ServerUser -> List (Attribute msg)
renderUserAttrs user =
    if (isRoot user) then
        [ attribute "data-root" "1" ]
    else
        []


addr : IP -> Html msg
addr addr =
    node "linkAddr"
        (renderAddrAttrs addr)
        [ node "ico" [] []
        , text " "
        , node "label" [] [ text addr ]
        ]


user : ServerUser -> Html msg
user user =
    node "linkUser"
        (renderUserAttrs user)
        [ node "ico" [] []
        , text " "
        , node "label" [] [ text user ]
        ]


file : String -> Html msg
file fileName =
    node "linkFile" [] [ text fileName ]
