module Apps.Browser.Pages.DownloadCenter.Update exposing (update)

import Utils.React as React exposing (React)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit
import Apps.Browser.Pages.DownloadCenter.Config exposing (..)
import Apps.Browser.Pages.DownloadCenter.Models exposing (..)
import Apps.Browser.Pages.DownloadCenter.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        Cracked target passwrd ->
            if (model.toolkit.target == target) then
                onUpdatePasswordField passwrd model
            else
                ( model, React.none )

        LoginFailed ->
            onLoginFailed model

        UpdatePasswordField str ->
            onUpdatePasswordField str model

        SetShowingPanel value ->
            onTogglePanel value model


onTogglePanel : Bool -> Model -> UpdateResponse msg
onTogglePanel value model =
    ( setShowingPanel value model, React.none )


onLoginFailed : Model -> UpdateResponse msg
onLoginFailed model =
    ( setLoginFailed True model, React.none )


onUpdatePasswordField : String -> Model -> UpdateResponse msg
onUpdatePasswordField newPassword model =
    model.toolkit
        |> HackingToolkit.setPassword newPassword
        |> flip setToolkit model
        |> setLoginFailed False
        |> flip (,) React.none
