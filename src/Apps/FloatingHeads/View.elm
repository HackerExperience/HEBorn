module Apps.FloatingHeads.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Utils.Html.Events exposing (onClickMe, onKeyDown)
import Game.Models as Game
import Game.Storyline.Models as Storyline
import Game.Storyline.Emails.Models as Emails exposing (ID, Person)
import Game.Storyline.Emails.Contents as Emails
import Game.Storyline.Emails.Contents.View as Emails
import Apps.FloatingHeads.Config exposing (..)
import Apps.FloatingHeads.Messages exposing (Msg(..))
import Apps.FloatingHeads.Models exposing (..)
import Apps.FloatingHeads.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    let
        person =
            config.emails
                |> Emails.getPerson model.activeContact

        view_ =
            case model.mode of
                Compact ->
                    viewCompact person model

                Expanded ->
                    viewExpanded config person model
    in
        Html.map config.toMsg <| view_


viewExpanded : Config msg -> Maybe Person -> Model -> Html Msg
viewExpanded config person model =
    div
        []
        [ windowHeader model
        , div
            [ class [ Super ] ]
            [ renderHeader person
            , renderChat config person
            ]
        ]


viewCompact : Maybe Person -> Model -> Html Msg
viewCompact person model =
    div
        []
        [ windowHeader model
        , div
            [ class [ Super ] ]
            [ renderHeader person ]
        ]


windowHeader : Model -> Html Msg
windowHeader model =
    div
        [ class [ PseudoHeader ] ]
        [ span [ class [ HeaderBtnDrag ] ] []
        , text " "
        , closeBtn
        , text " "
        , span [ class [ HeaderBtnDrag ] ] []
        ]


closeBtn : Html Msg
closeBtn =
    span
        [ class [ HeaderBtnClose ]
        , onClickMe (Close)
        ]
        []


renderHeader : Maybe Person -> Html Msg
renderHeader person =
    let
        fallbackLink =
            "images/avatar.jpg"

        imgSource =
            case person of
                Just person ->
                    case person.about of
                        Just about ->
                            src about.picture

                        Nothing ->
                            src fallbackLink

                Nothing ->
                    src fallbackLink
    in
        div [ class [ AvatarContainer ] ]
            [ img
                [ class [ Avatar ]
                , imgSource
                , onClick ToggleMode
                ]
                []
            ]


renderChat : Config msg -> Maybe Person -> Html Msg
renderChat config active =
    active
        |> Maybe.map Emails.getAvailableReplies
        |> Maybe.withDefault []
        |> List.map (reply config)
        |> div []
        |> List.singleton
        |> (::) (ul [] (chatMessages config active))
        |> div [ class [ Chat ] ]


reply : Config msg -> Emails.Content -> Html Msg
reply config msg =
    let
        config_ =
            contentConfig config
    in
        msg
            |> Emails.view config_
            |> List.map (Html.map ContentMsg)
            |> span [ onClick <| Reply msg ]


chatMessages : Config msg -> Maybe Person -> List (Html Msg)
chatMessages config active =
    active
        |> Maybe.map (Emails.getMessages >> Dict.values)
        |> Maybe.withDefault []
        |> List.map
            (\v ->
                case v of
                    Emails.Sent msg ->
                        baloon config To msg

                    Emails.Received msg ->
                        baloon config From msg
            )


baloon : Config msg -> Classes -> Emails.Content -> Html Msg
baloon config direction msg =
    li
        [ class [ direction ] ]
        [ content config msg ]


content : Config msg -> Emails.Content -> Html Msg
content config msg =
    let
        config_ =
            contentConfig config
    in
        msg
            |> Emails.view config_
            |> List.map (Html.map ContentMsg)
            |> span []
