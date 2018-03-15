module OS.Toasts.View exposing (view)

import Dict exposing (foldl)
import Html exposing (Html, div, text, h6, p)
import Html.CssHelpers
import OS.Toasts.Resources as R
import Game.Account.Notifications.Shared as AccountNotifications
import Game.Servers.Notifications.Shared as ServersNotifications
import OS.Toasts.Messages exposing (..)
import OS.Toasts.Models exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace R.prefix


view : Model -> Html Msg
view model =
    model
        |> Dict.foldl
            (\k v acu ->
                if v.state == Garbage then
                    acu
                else
                    (toast k v) :: acu
            )
            []
        |> div [ class [ R.Toasts ] ]


toast : Int -> Toast -> Html Msg
toast id { notification, state } =
    let
        classAttr =
            if state == Fading then
                Just <| class [ R.Fading ]
            else
                Nothing

        attrs =
            List.filterMap identity [ classAttr ]

        ( title, message ) =
            case notification of
                Server _ content ->
                    ServersNotifications.renderToast content

                Account content ->
                    AccountNotifications.renderToast content
    in
        div attrs <|
            [ h6 [] [ text title ]
            , p [] [ text message ]
            ]
