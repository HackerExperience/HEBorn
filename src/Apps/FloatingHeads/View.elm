module Apps.FloatingHeads.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Css
import Css.Utils exposing (styles)
import Utils.Html.Events exposing (onClickMe, onKeyDown)
import Game.Data as Game
import Game.Models as Game
import Game.Storyline.Models as Storyline
import Game.Storyline.Emails.Models as Emails exposing (ID, Person)
import Game.Storyline.Emails.Contents as Emails
import Apps.FloatingHeads.Messages exposing (Msg(..))
import Apps.FloatingHeads.Models exposing (..)
import Apps.FloatingHeads.Resources exposing (Classes(..), prefix)
import Apps.FloatingHeads.Menu.View exposing (..)


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
                viewExpanded person model


viewExpanded : Maybe Person -> Model -> Html Msg
viewExpanded person model =
    div
        []
        [ windowHeader model
        , div
            [ class [ Super ]
            ]
            [ renderHeader person
            , renderChat person
            , menuView model
            ]
        ]


viewCompact : Maybe Person -> Model -> Html Msg
viewCompact person model =
    div
        []
        [ windowHeader model
        , div
            [ class [ Super ]
            ]
            [ renderHeader person
            , menuView model
            ]
        ]


windowHeader : Model -> Html Msg
windowHeader model =
    div
        [ class [ WindowHeader ] ]
        [ div
            [ class [ WindowHeaderButtons ] ]
            [ closeBtn ]
        ]


closeBtn : Html Msg
closeBtn =
    span
        [ class [ HeaderButtons ] ]
        [ span
            [ class [ HeaderBtnClose ]
            , onClickMe (Close)
            ]
            []
        ]


renderHeader : Maybe Person -> Html Msg
renderHeader person =
    let
        fallbackLink =
            "https://pbs.twimg.com/profile_images/928805578679431168/zwSXRn0K_400x400.jpg"

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
        div [ class [ Header ] ]
            [ div [ class [ Head ] ]
                [ img
                    [ imgSource
                    , headSize
                    , onClick ToggleMode
                    ]
                    []
                ]
            ]


headSize : Attribute msg
headSize =
    [ Css.width (Css.pct 100)
    , Css.height (Css.pct 100)
    , Css.borderRadius (Css.pct 100)
    ]
        |> styles


renderChat : Maybe Person -> Html Msg
renderChat active =
    active
        |> Maybe.map Emails.getAvailableReplies
        |> Maybe.withDefault []
        |> List.map reply
        |> div []
        |> List.singleton
        |> (::) (ul [] (chatMessages active))
        |> div [ class [ Chat ] ]


reply : Emails.Content -> Html Msg
reply msg =
    Emails.toString msg
        |> text
        |> List.singleton
        |> span [ onClick <| Reply msg ]


chatMessages : Maybe Person -> List (Html Msg)
chatMessages active =
    active
        |> Maybe.map (Emails.getMessages >> Dict.values)
        |> Maybe.withDefault []
        |> List.map
            (\v ->
                case v of
                    Emails.Sent msg ->
                        baloon To msg

                    Emails.Received msg ->
                        baloon From msg
            )


baloon : Classes -> Emails.Content -> Html Msg
baloon direction msg =
    li
        [ class [ direction ] ]
        [ content msg ]


content : Emails.Content -> Html Msg
content msg =
    Emails.toString msg
        |> text
        |> List.singleton
        |> span []
