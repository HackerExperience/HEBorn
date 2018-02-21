module Apps.FloatingHeads.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Utils.Html.Events exposing (onClickMe, onKeyDown)
import Game.Storyline.Models as Storyline exposing (Contact)
import Game.Storyline.Shared as Storyline
import Game.Storyline.Emails.View as Emails
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
            Storyline.getContact
                model.activeContact
                config.story
    in
        case model.mode of
            Compact ->
                viewCompact config person model

            Expanded ->
                viewExpanded config person model


viewExpanded : Config msg -> Maybe Contact -> Model -> Html msg
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


viewCompact : Config msg -> Maybe Contact -> Model -> Html msg
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


renderHeader : Config msg -> Maybe Contact -> Html msg
renderHeader { draggable, toMsg } person =
    let
        imgSource =
            case person of
                Just person ->
                    src person.about.picture

                Nothing ->
                    src "images/avatar.jpg"
    in
        div [ class [ AvatarContainer ], draggable ]
            [ img
                [ class [ Avatar ]
                , imgSource
                , onClick <| toMsg <| ToggleMode
                ]
                []
            ]


renderChat : Config msg -> Maybe Contact -> Html msg
renderChat config active =
    active
        |> Maybe.map Storyline.getAvailableReplies
        |> Maybe.withDefault []
        |> List.map (reply config)
        |> div []
        |> List.singleton
        |> (::) (ul [] (chatMessages config active))
        |> div [ class [ Chat ] ]


reply : Config msg -> Storyline.Reply -> Html msg
reply config msg =
    msg
        |> Emails.view (contentConfig config)
        |> span [ onClick <| config.toMsg <| Reply msg ]


chatMessages : Config msg -> Maybe Contact -> List (Html msg)
chatMessages config active =
    active
        |> Maybe.map (Storyline.getPastEmails >> Dict.values)
        |> Maybe.withDefault []
        |> List.map (messageSerialize >> uncurry (baloon config))


messageSerialize : Storyline.PastEmail -> ( Classes, Storyline.Reply )
messageSerialize msg =
    case msg of
        Storyline.FromPlayer msg ->
            ( To, msg )

        Storyline.FromContact msg ->
            ( From, msg )


baloon : Config msg -> Classes -> Storyline.Reply -> Html msg
baloon config direction msg =
    li
        [ class [ direction ] ]
        [ content config msg ]


content : Config msg -> Storyline.Reply -> Html msg
content config msg =
    msg
        |> Emails.view (contentConfig config)
        |> span []
