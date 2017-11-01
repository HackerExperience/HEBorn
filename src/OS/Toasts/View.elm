module OS.Toasts.View exposing (view)

import Dict exposing (foldl)
import Html exposing (Html, div, text, h6, p)
import Html.CssHelpers
import Game.Data as Game
import Game.Notifications.Models exposing (Content(..))
import OS.Resources as Res
import OS.Toasts.Messages exposing (..)
import OS.Toasts.Models exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


view : Game.Data -> Model -> Html Msg
view _ model =
    model
        |> Dict.foldl
            (\k v acu ->
                if v.state == Garbage then
                    acu
                else
                    (toast k v) :: acu
            )
            []
        |> div [ class [ Res.Toasts ] ]


toast : Int -> Toast -> Html Msg
toast id { notification, state } =
    let
        classAttr =
            if state == Fading then
                Just <| class [ Fading ]
            else
                Nothing

        attrs =
            [ classAttr ]
                |> List.filterMap identity
    in
        div attrs <|
            case notification of
                Simple title msg ->
                    [ h6 [] [ text title ]
                    , p [] [ text msg ]
                    ]

                NewEmail from msg ->
                    [ h6 [] [ text <| "New email from: " ++ from ]
                    , p [] [ text msg ]
                    ]

                DownloadStarted origin file ->
                    [ h6 [] [ text <| "Download started" ]
                    , p [] [ text <| file.name ++ " download has started!" ]
                    ]
