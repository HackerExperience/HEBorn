module Apps.Browser.Pages.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Models exposing (Model(..))
import Apps.Browser.Pages.Messages exposing (..)
import Apps.Browser.Pages.NoWebserver.Update as NoWebserver
import Apps.Browser.Pages.Bank.Update as Bank


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case ( model, msg ) of
        ( NoWebserverModel page, NoWebserverMsg msg ) ->
            NoWebserver.update data msg page
                |> Update.mapModel NoWebserverModel
                |> Update.mapCmd NoWebserverMsg

        ( BankModel page, BankMsg msg ) ->
            Bank.update data msg page
                |> Update.mapModel BankModel
                |> Update.mapCmd BankMsg

        _ ->
            Update.fromModel model
