module Apps.Browser.Pages.Store.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Store.Config exposing (..)
import Apps.Browser.Pages.Store.Models exposing (..)
import Apps.Browser.Pages.Store.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update :
    Config msg
    -> Game.Data
    -> Msg
    -> Model
    -> UpdateResponse msg
update config data msg model =
    case msg of
        UpdatePasswordField str ->
            Update.fromModel
                { model | password = Just str }
