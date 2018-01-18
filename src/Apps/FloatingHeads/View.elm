module Apps.FloatingHeads.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Css.Utils exposing (styles)
import Utils.Html.Events exposing (onClickMe, onKeyDown)
import Game.Data as Game
import Game.Models as Game
import Game.Storyline.Models as Storyline
import Game.Storyline.Emails.Models as Emails exposing (ID, Person)
import Game.Storyline.Emails.Contents as Emails
import Game.Storyline.Emails.Contents.View as Emails
import Apps.FloatingHeads.Messages exposing (Msg(..))
import Apps.FloatingHeads.Models exposing (..)
import Apps.FloatingHeads.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    let
        person =
            data
                |> Game.getGame
                |> Game.getStory
                |> Storyline.getEmails
                |> Emails.getPerson model.activeContact
    in
        case model.mode of
            Compact ->
                viewCompact person model

            Expanded ->
                viewExpanded data person model


viewExpanded : Game.Data -> Maybe Person -> Model -> Html Msg
viewExpanded data person model =
    div
        []
        [ windowHeader model
        , div
            [ class [ Super ] ]
            [ renderHeader person
            , renderChat data person
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


renderChat : Game.Data -> Maybe Person -> Html Msg
renderChat data active =
    active
        |> Maybe.map Emails.getAvailableReplies
        |> Maybe.withDefault []
        |> List.map (reply data)
        |> div []
        |> List.singleton
        |> (::) (ul [] (chatMessages data active))
        |> div [ class [ Chat ] ]


reply : Game.Data -> Emails.Content -> Html Msg
reply data msg =
    msg
        |> Emails.view data
        |> List.map (Html.map ContentMsg)
        |> span [ onClick <| Reply msg ]


chatMessages : Game.Data -> Maybe Person -> List (Html Msg)
chatMessages data active =
    active
        |> Maybe.map (Emails.getMessages >> Dict.values)
        |> Maybe.withDefault []
        |> List.map
            (\v ->
                case v of
                    Emails.Sent msg ->
                        baloon data To msg

                    Emails.Received msg ->
                        baloon data From msg
            )


baloon : Game.Data -> Classes -> Emails.Content -> Html Msg
baloon data direction msg =
    li
        [ class [ direction ] ]
        [ content data msg ]


content : Game.Data -> Emails.Content -> Html Msg
content data msg =
    msg
        |> Emails.view data
        |> List.map (Html.map ContentMsg)
        |> span []
