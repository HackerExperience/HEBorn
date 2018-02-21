module Apps.Email.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Game.Storyline.Models exposing (Contact)
import Game.Storyline.Shared exposing (ContactId)
import Apps.Email.Config exposing (..)
import Apps.Email.Messages exposing (Msg(..))
import Apps.Email.Models exposing (..)
import Apps.Email.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view ({ story } as config) model =
    story
        |> Dict.foldr (contact config) []
        |> ul [ class [ Contacts ] ]
        |> List.singleton
        |> div []


contact :
    Config msg
    -> ContactId
    -> Contact
    -> List (Html msg)
    -> List (Html msg)
contact { toMsg } contactId { about } acu =
    let
        source =
            src about.picture

        image =
            img imageAttrs []

        imageAttrs =
            [ source, class [ Avatar ] ]

        attrs =
            [ onClick <| toMsg <| SelectContact contactId ]
    in
        li attrs [ image, text about.nick ]
            |> flip (::) acu
