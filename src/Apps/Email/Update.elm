module Apps.Email.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Storyline.Emails.Models as Emails exposing (Person)
import Apps.Email.Config exposing (..)
import Apps.Email.Models exposing (..)
import Apps.Email.Messages as Email exposing (Msg(..))
import Apps.FloatingHeads.Models as FloatingHeads
import Apps.Apps as Apps


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Email.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        -- -- Context
        SelectContact email ->
            onSelectContact config email model


onSelectContact : Config msg -> String -> Model -> UpdateResponse msg
onSelectContact { onOpenApp } email model =
    email
        |> FloatingHeads.OpenAtContact
        |> Apps.FloatingHeadsParams
        |> onOpenApp Nothing
        |> React.msg
        |> (,) model
