module Apps.Browser.Pages.DownloadCenter.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Game.Models as Game
import Game.Network.Types exposing (NIP)
import Game.Servers.Shared as Servers
import Game.Servers.Processes.Messages as Processes
import Apps.Browser.Pages.CommonActions exposing (..)
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit
import Apps.Browser.Pages.DownloadCenter.Models exposing (..)
import Apps.Browser.Pages.DownloadCenter.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        GlobalMsg (Cracked target passwrd) ->
            if (model.toolkit.target == target) then
                onUpdatePasswordField passwrd model
            else
                Update.fromModel model

        GlobalMsg LoginFailed ->
            onLoginFailed model

        GlobalMsg _ ->
            -- Treated in Browser.Update
            Update.fromModel model

        UpdatePasswordField str ->
            onUpdatePasswordField str model

        SetShowingPanel value ->
            onTogglePanel value model

        ReqDownload source fileId ->
            onReqDownload data source fileId model


onTogglePanel : Bool -> Model -> UpdateResponse
onTogglePanel value model =
    model
        |> setShowingPanel value
        |> Update.fromModel


onLoginFailed : Model -> UpdateResponse
onLoginFailed model =
    model
        |> setLoginFailed True
        |> Update.fromModel


onUpdatePasswordField : String -> Model -> UpdateResponse
onUpdatePasswordField newPassword model =
    model.toolkit
        |> HackingToolkit.setPassword newPassword
        |> flip setToolkit model
        |> setLoginFailed False
        |> Update.fromModel


onReqDownload :
    Game.Data
    -> NIP
    -> String
    -> Model
    -> UpdateResponse
onReqDownload data source fileId model =
    let
        me =
            requireGateway data

        dispatch =
            Dispatch.processes me <|
                Processes.StartPublicDownload source fileId "storage id"
    in
        ( model, Cmd.none, dispatch )


requireGateway : Game.Data -> Servers.ID
requireGateway data =
    case (Game.getGateway <| data.game) of
        Just ( id, _ ) ->
            id

        Nothing ->
            Native.Panic.crash "WTF_ASTRAL_PROJECTION"
                "There is no gateway server in this session!"
