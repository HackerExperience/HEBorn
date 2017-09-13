module Apps.Email.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Game.Data as Game
import Game.Storyline.Emails.Models as Emails exposing (PersonID, Person)
import Apps.Email.Messages exposing (Msg(..))
import Apps.Email.Models exposing (..)
import Apps.Email.Resources exposing (Classes(..), prefix)
import Apps.Email.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    let
        emails =
            data.game.story.emails

        contactList =
            emails
                |> Dict.foldr (contactProcessor model.activeContact) []
                |> ul [ class [ Contacts ] ]

        active =
            model.activeContact
                |> Maybe.andThen (\k -> Dict.get k emails)
    in
        div
            [ menuForDummy
            , class [ Super ]
            ]
            [ contactList
            , mainChat active
            , menuView model
            ]


mainChat : Maybe Person -> Html Msg
mainChat active =
    active
        |> Maybe.map Emails.getAvailableResponses
        |> Maybe.withDefault []
        |> List.map (text >> List.singleton >> span [])
        |> div []
        |> List.singleton
        |> (::) (ul [] (mainChatMessages active))
        |> div [ class [ MainChat ] ]


mainChatMessages : Maybe Person -> List (Html Msg)
mainChatMessages active =
    active
        |> Maybe.map (Emails.getMessages >> Dict.values)
        |> Maybe.withDefault []
        |> List.map
            (\v ->
                case v of
                    Emails.Sended msg ->
                        baloon To msg

                    Emails.Received msg ->
                        baloon From msg
            )


baloon : Classes -> String -> Html Msg
baloon dir msg =
    li [ class [ dir ] ] [ span [] [ text msg ] ]


contactProcessor :
    Maybe PersonID
    -> PersonID
    -> Person
    -> List (Html Msg)
    -> List (Html Msg)
contactProcessor activeKey k { about } acu =
    let
        activeAttr =
            case activeKey of
                Just activeKey ->
                    (if k == activeKey then
                        [ class [ Active ] ]
                     else
                        []
                    )

                _ ->
                    []

        attrs =
            (onClick <| SelectContact k) :: activeAttr
    in
        about
            |> Maybe.map (.name)
            |> Maybe.withDefault "[UNKNOWN]"
            |> text
            |> List.singleton
            |> li attrs
            |> flip (::) acu
