module Apps.Browser.Pages.Webserver.Update exposing (update)

import Utils.React as React exposing (React)
import Apps.Browser.Widgets.HackingToolkit.Model as HackingToolkit
import Apps.Browser.Pages.Webserver.Config exposing (..)
import Apps.Browser.Pages.Webserver.Messages exposing (..)
import Apps.Browser.Pages.Webserver.Models exposing (..)


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
    model
        |> setShowingPanel value
        |> flip (,) React.none


onLoginFailed : Model -> UpdateResponse msg
onLoginFailed model =
    model
        |> setLoginFailed True
        |> flip (,) React.none


onUpdatePasswordField : String -> Model -> UpdateResponse msg
onUpdatePasswordField newPassword model =
    model.toolkit
        |> HackingToolkit.setPassword newPassword
        |> flip setToolkit model
        |> setLoginFailed False
        |> flip (,) React.none
