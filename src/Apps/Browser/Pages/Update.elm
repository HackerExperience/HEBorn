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
    ( ( Model, Cmd Msg, Dispatch ), Maybe CommonActions )


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

        ( _, Ignore ) ->
            ( Update.fromModel model, Nothing )

        -- INVALIDS
        _ ->
            ( Update.fromModel model, Nothing )


handleNoWebserver :
    Game.Data
    -> NoWebserver.Msg
    -> NoWebserver.Model
    -> UpdateResponse
handleNoWebserver data msg page =
    let
        updateFirst =
            NoWebserver.update data msg page
                |> Update.mapModel NoWebserverModel
                |> Update.mapCmd NoWebserverMsg

        updateSecond =
            case msg of
                NoWebserver.GlobalMsg msg ->
                    Just msg

                _ ->
                    Nothing
    in
        ( updateFirst, updateSecond )


handleBank :
    Game.Data
    -> Bank.Msg
    -> Bank.Model
    -> UpdateResponse
handleBank data msg page =
    let
        updateFirst =
            Bank.update data msg page
                |> Update.mapModel BankModel
                |> Update.mapCmd BankMsg

        updateSecond =
            case msg of
                Bank.GlobalMsg msg ->
                    Just msg

                _ ->
                    Nothing
    in
        ( updateFirst, updateSecond )


handleDownloadCenter :
    Game.Data
    -> DownloadCenter.Msg
    -> DownloadCenter.Model
    -> UpdateResponse
handleDownloadCenter data msg page =
    let
        updateFirst =
            DownloadCenter.update data msg page
                |> Update.mapModel DownloadCenterModel
                |> Update.mapCmd DownloadCenterMsg

        updateSecond =
            case msg of
                DownloadCenter.GlobalMsg msg ->
                    Just msg

                _ ->
                    Nothing
    in
        ( updateFirst, updateSecond )
