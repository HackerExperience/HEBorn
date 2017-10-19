module Apps.Browser.Pages.Home.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick)
import Apps.Browser.Pages.CommonActions exposing (..)


view : Html CommonActions
view =
    div []
        [ node "center"
            []
            [ p [] [ text "Welcome to the internet, here you find everything!" ] ]
        , ul
            []
            [ li
                [ onClick <| NewTabIn "1.2.3.4" ]
                [ text "Download Center" ]
            , li
                [ onClick <| NewTabIn "profile.dmy" ]
                [ text "My profile" ]
            , li
                [ onClick <| GoAddress "directory.dmy" ]
                [ text "Directory" ]
            , li
                [ onClick <| GoAddress "headquarters.dmy" ]
                [ text "Mission Center" ]
            , li
                [ onClick <| GoAddress "meuisp.dmy" ]
                [ text "ISP" ]
            , li
                [ onClick <| GoAddress "fbi.dmy" ]
                [ text "FBI" ]
            , li
                [ onClick <| GoAddress "lulapresoamanha.dmy" ]
                [ text "News" ]
            ]
        ]
