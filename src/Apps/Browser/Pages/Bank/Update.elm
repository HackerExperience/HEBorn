module Apps.Browser.Pages.Bank.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        GlobalMsg _ ->
            -- Treated in Browser.Update
            Update.fromModel model

        UpdatePasswordField str ->
            Update.fromModel
                { model | password = Just str }
