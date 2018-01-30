module Apps.Browser.Pages.Home.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick)
import Apps.Params as AppParams exposing (AppParams)
import Apps.Browser.Pages.Home.Config exposing (..)
import Apps.Hebamp.Shared as Hebamp


view : Config msg -> Html msg
view { onNewTabIn, onGoAddress, onOpenApp } =
    div []
        [ node "center"
            []
            [ p [] [ text "Welcome to the internet, here you find everything!" ] ]
        , ul
            []
            [ li
                [ onClick <| onNewTabIn "1.2.3.4" ]
                [ text "Download Center" ]
            , li
                [ onClick <| onNewTabIn "profile.dmy" ]
                [ text "My profile" ]
            , li
                [ onClick <| onGoAddress "directory.dmy" ]
                [ text "Directory" ]
            , li
                [ onClick <| onGoAddress "headquarters.dmy" ]
                [ text "Mission Center" ]
            , li
                [ onClick <| onGoAddress "meuisp.dmy" ]
                [ text "ISP" ]
            , li
                [ onClick <| onGoAddress "fbi.dmy" ]
                [ text "FBI" ]
            , li
                [ onClick <| onGoAddress "lulapresoamanha.dmy" ]
                [ text "News" ]
            , li
                [ { mediaUrl = "https://archive.org/download/vitas_201706/vitas.ogg"
                  , mediaType = "audio/ogg"
                  , label = "7th Element by Vitas"
                  , duration = 247
                  }
                    |> List.singleton
                    |> Hebamp.OpenPlaylist
                    |> AppParams.Hebamp
                    |> onOpenApp
                    |> onClick
                ]
                [ text "Blblbl" ]
            ]
        ]
