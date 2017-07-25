module Apps.Browser.Pages.Home.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick)
import Apps.Browser.Pages.Home.Messages exposing (Msg(..))


view : Html Msg
view =
    div []
        [ node "center"
            []
            [ p [] [ text "Welcome to the internet, here you find everything!" ] ]
        , ul
            []
            [ li
                [ onClick <| BrowserTabAddress "baixaki.dmy" ]
                [ text "Download Center" ]
            , li
                [ onClick <| BrowserTabAddress "profile.dmy" ]
                [ text "My profile" ]
            , li
                [ onClick <| BrowserGoAddress "directory.dmy" ]
                [ text "Directory" ]
            , li
                [ onClick <| BrowserGoAddress "headquarters.dmy" ]
                [ text "Mission Center" ]
            , li
                [ onClick <| BrowserGoAddress "meuisp.dmy" ]
                [ text "ISP" ]
            , li
                [ onClick <| BrowserGoAddress "fbi.dmy" ]
                [ text "FBI" ]
            , li
                [ onClick <| BrowserGoAddress "lulapresoamanha.dmy" ]
                [ text "News" ]
            ]
        ]
