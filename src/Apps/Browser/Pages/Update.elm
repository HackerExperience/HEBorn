module Apps.Browser.Pages.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.CommonActions exposing (..)
import Apps.Browser.Pages.Messages exposing (..)
import Apps.Browser.Pages.Models exposing (Model(..))
import Apps.Browser.Pages.NoWebserver.Messages as NoWebserver
import Apps.Browser.Pages.NoWebserver.Models as NoWebserver
import Apps.Browser.Pages.NoWebserver.Update as NoWebserver
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
        ( NoWebserverModel page, NoWebserverMsg msg ) ->
            handleNoWebserver data msg page

        ( BankModel page, BankMsg msg ) ->
            handleBank data msg page

        ( DownloadCenterModel page, DownloadCenterMsg msg ) ->
            handleDownloadCenter data msg page

        -- INVALIDS
        _ ->
            Update.fromModel model


handleNoWebserver :
    Game.Data
    -> NoWebserver.Msg
    -> NoWebserver.Model
    -> UpdateResponse
handleNoWebserver data msg page =
    NoWebserver.update data msg page
        |> Update.mapModel NoWebserverModel
        |> Update.mapCmd NoWebserverMsg


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
