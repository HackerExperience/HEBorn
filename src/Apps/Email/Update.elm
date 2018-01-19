module Apps.Email.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.OS as OS
import Core.Dispatch.Storyline as Storyline
import Game.Data as Game
import Game.Storyline.Emails.Models as Emails exposing (Person)
import Apps.Email.Models exposing (..)
import Apps.Email.Messages as Email exposing (Msg(..))
import Apps.FloatingHeads.Models as FloatingHeads
import Apps.Apps as Apps


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> Email.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        SelectContact email ->
            onSelectContact email model


onSelectContact : String -> Model -> UpdateResponse
onSelectContact email model =
    let
        dispatch =
            email
                |> FloatingHeads.OpenAtContact
                |> Apps.FloatingHeadsParams
                |> OS.OpenApp Nothin
                |> Dispatch.os
    in
        ( model, Cmd.none, dispatch )
