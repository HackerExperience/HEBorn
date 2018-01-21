module Apps.Email.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Game.Data as Game
import Game.Models as Game
import Game.Storyline.Models as Storyline
import Game.Storyline.Emails.Models as Emails exposing (ID, Person)
import Game.Storyline.Emails.Contents as Emails
import Apps.Email.Config exposing (..)
import Apps.Email.Messages exposing (Msg(..))
import Apps.Email.Models exposing (..)
import Apps.Email.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html Msg
view config model =
    let
        emails =
            config.emails

        contactList =
            emails
                |> Dict.foldr contact []
                |> ul [ class [ Contacts ] ]
    in
        div
            []
            [ contactList ]


contact :
    ID
    -> Person
    -> List (Html Msg)
    -> List (Html Msg)
contact k { about } acu =
    let
        name =
            about
                |> Maybe.map (.name)
                |> Maybe.withDefault "[UNKNOWN]"

        source =
            case about of
                Just about_ ->
                    src about_.picture

                Nothing ->
                    src "images/avatar.jpg"

        image =
            img imageAttrs []

        imageAttrs =
            [ source, class [ Avatar ] ]

        attrs =
            [ onClick <| SelectContact k ]
    in
        li attrs [ image, text name ]
            |> flip (::) acu
