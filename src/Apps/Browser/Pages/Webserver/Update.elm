module Apps.Browser.Pages.Webserver.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Game.Models as Game
import Game.Network.Types exposing (NIP)
import Game.Servers.Shared as Servers
import Game.Servers.Processes.Messages as Processes
import Apps.Browser.Pages.CommonActions exposing (..)
import Apps.Browser.Pages.Webserver.Models exposing (..)
import Apps.Browser.Pages.Webserver.Messages exposing (..)
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit


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
