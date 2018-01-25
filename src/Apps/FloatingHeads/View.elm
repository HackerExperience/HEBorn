module Apps.FloatingHeads.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Utils.Html.Events exposing (onClickMe, onKeyDown)
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
    in
        case model.mode of
            Compact ->
                viewCompact config person model

            Expanded ->
                viewExpanded config person model


viewExpanded : Config msg -> Maybe Person -> Model -> Html msg
viewExpanded config person model =
    div
        []
        [ windowHeader config model
        , div
            [ class [ Super ] ]
            [ renderHeader config person
            , renderChat config person
            ]
        ]


viewCompact : Config msg -> Maybe Person -> Model -> Html msg
viewCompact config person model =
    div
        []
        [ windowHeader config model
        , div
            [ class [ Super ] ]
            [ renderHeader config person ]
        ]


windowHeader : Config msg -> Model -> Html msg
windowHeader config model =
    div
        [ class [ PseudoHeader ] ]
        [ closeBtn config ]


closeBtn : Config msg -> Html msg
closeBtn { toMsg } =
    span
        [ class [ HeaderBtnClose ]
        , onClickMe <| toMsg <| Close
        ]
        []


renderHeader : Config msg -> Maybe Person -> Html msg
renderHeader { draggable, toMsg } person =
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
        div [ class [ AvatarContainer ], draggable ]
            [ img
                [ class [ Avatar ]
                , imgSource
                , onClick <| toMsg <| ToggleMode
                ]
                []
            ]


renderChat : Config msg -> Maybe Person -> Html msg
renderChat config active =
    active
        |> Maybe.map Emails.getAvailableReplies
        |> Maybe.withDefault []
        |> List.map (reply config)
        |> div []
        |> List.singleton
        |> (::) (ul [] (chatMessages config active))
        |> div [ class [ Chat ] ]


reply : Config msg -> Emails.Content -> Html msg
reply config msg =
    msg
        |> Emails.view (contentConfig config)
        |> span [ onClick <| config.toMsg <| Reply msg ]


chatMessages : Config msg -> Maybe Person -> List (Html msg)
chatMessages config active =
    active
        |> Maybe.map (Emails.getMessages >> Dict.values)
        |> Maybe.withDefault []
        |> List.map (messageSerialize >> uncurry (baloon config))


messageSerialize : Emails.Message -> ( Classes, Emails.Content )
messageSerialize msg =
    case msg of
        Emails.Sent msg ->
            ( To, msg )

        Emails.Received msg ->
            ( From, msg )


baloon : Config msg -> Classes -> Emails.Content -> Html msg
baloon config direction msg =
    li
        [ class [ direction ] ]
        [ content config msg ]


content : Config msg -> Emails.Content -> Html msg
content config msg =
    msg
        |> Emails.view (contentConfig config)
        |> span []
