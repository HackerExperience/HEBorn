module Apps.Browser.Pages.Webserver.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit
import Apps.Browser.Pages.Webserver.Config exposing (..)
import Apps.Browser.Pages.Webserver.Messages exposing (..)
import Apps.Browser.Pages.Webserver.Models exposing (..)


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
        Cracked target passwrd ->
            if (model.toolkit.target == target) then
                onUpdatePasswordField passwrd model
            else
                Update.fromModel model

        LoginFailed ->
            onLoginFailed model

        UpdatePasswordField str ->
            onUpdatePasswordField str model

        SetShowingPanel value ->
            onTogglePanel value model


onTogglePanel : Bool -> Model -> UpdateResponse msg
onTogglePanel value model =
    model
        |> setShowingPanel value
        |> Update.fromModel


onLoginFailed : Model -> UpdateResponse msg
onLoginFailed model =
    model
        |> setLoginFailed True
        |> Update.fromModel


onUpdatePasswordField : String -> Model -> UpdateResponse msg
onUpdatePasswordField newPassword model =
    model.toolkit
        |> HackingToolkit.setPassword newPassword
        |> flip setToolkit model
        |> setLoginFailed False
        |> Update.fromModel
