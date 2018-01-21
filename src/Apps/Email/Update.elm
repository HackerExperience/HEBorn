module Apps.Email.Update exposing (update)

import Utils.React as React exposing (React)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.OS as OS
import Core.Dispatch.Storyline as Storyline
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
            onSelectContact email model



-- CONFREFACT : Dispatch this properly


onSelectContact : String -> Model -> UpdateResponse msg
onSelectContact email model =
    --let
    --  dispatch =
    --     email
    --      |> FloatingHeads.OpenAtContact
    --      |> Apps.FloatingHeadsParams
    --      |> OS.OpenApp Nothing
    --      |> Dispatch.os
    --in
    ( model, React.none )
