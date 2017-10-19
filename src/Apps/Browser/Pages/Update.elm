module Apps.Browser.Pages.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.Messages exposing (..)
import Apps.Browser.Pages.Models exposing (Model(..))
import Apps.Browser.Pages.Webserver.Messages as Webserver
import Apps.Browser.Pages.Webserver.Models as Webserver
import Apps.Browser.Pages.Webserver.Update as Webserver
import Apps.Browser.Pages.Bank.Messages as Bank
import Apps.Browser.Pages.Bank.Models as Bank
import Apps.Browser.Pages.Bank.Update as Bank
import Apps.Browser.Pages.DownloadCenter.Messages as DownloadCenter
import Apps.Browser.Pages.DownloadCenter.Models as DownloadCenter
import Apps.Browser.Pages.DownloadCenter.Update as DownloadCenter


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case ( model, msg ) of
        ( WebserverModel page, WebserverMsg msg ) ->
            handleWebserver data msg page

        ( BankModel page, BankMsg msg ) ->
            handleBank data msg page

        ( DownloadCenterModel page, DownloadCenterMsg msg ) ->
            handleDownloadCenter data msg page

        -- INVALIDS
        _ ->
            Update.fromModel model


handleWebserver :
    Game.Data
    -> Webserver.Msg
    -> Webserver.Model
    -> UpdateResponse
handleWebserver data msg page =
    Webserver.update data msg page
        |> Update.mapModel WebserverModel
        |> Update.mapCmd WebserverMsg


handleBank :
    Game.Data
    -> Bank.Msg
    -> Bank.Model
    -> UpdateResponse
handleBank data msg page =
    Bank.update data msg page
        |> Update.mapModel BankModel
        |> Update.mapCmd BankMsg


handleDownloadCenter :
    Game.Data
    -> DownloadCenter.Msg
    -> DownloadCenter.Model
    -> UpdateResponse
handleDownloadCenter data msg page =
    DownloadCenter.update data msg page
        |> Update.mapModel DownloadCenterModel
        |> Update.mapCmd DownloadCenterMsg
