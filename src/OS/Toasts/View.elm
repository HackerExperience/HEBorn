module OS.Toasts.View exposing (view)

import Dict exposing (foldl)
import Html exposing (Html, div, text, h6, p)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Game.Account.Notifications.OnClick as AccountNotifications
import Game.Account.Notifications.Shared as AccountNotifications
import Game.Servers.Notifications.OnClick as ServersNotifications
import Game.Servers.Notifications.Shared as ServersNotifications
import OS.Toasts.Config exposing (..)
import OS.Toasts.Messages exposing (..)
import OS.Toasts.Models exposing (..)
import OS.Toasts.Resources as R


{ id, class, classList } =
    Html.CssHelpers.withNamespace R.prefix


view : Config msg -> Model -> Html msg
view config model =
    model
        |> Dict.foldl
            (\k v acu ->
                if v.state == Garbage then
                    acu
                else
                    (toast config k v) :: acu
            )
            []
        |> div [ class [ R.Toasts ] ]


toast : Config msg -> Int -> Toast -> Html msg
toast config id { notification, state } =
    let
        addClassAttr other =
            if state == Fading then
                [ class [ R.Fading ]
                , other
                ]
            else
                [ other ]

        ( ( title, message ), onClick_ ) =
            case notification of
                Server _ content ->
                    ( ServersNotifications.renderToast content
                    , (ServersNotifications.grabOnClick <| serverActionConfig config)
                        content
                    )

                Account content ->
                    ( AccountNotifications.renderToast content
                    , (AccountNotifications.grabOnClick <| accountActionConfig config)
                        content
                    )

        attrs =
            [ onClick_, config.toMsg <| Remove id ]
                |> config.batchMsg
                |> onClick
                |> addClassAttr
    in
        div attrs <|
            [ h6 [] [ text title ]
            , p [] [ text message ]
            ]
