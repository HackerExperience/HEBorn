module Apps.Browser.Pages.NoWebserver.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Browser.Pages.CommonActions exposing (..)
import Apps.Browser.Pages.NoWebserver.Models exposing (..)
import Apps.Browser.Pages.NoWebserver.Messages exposing (..)
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


onUpdatePasswordField : String -> Model -> UpdateResponse
onUpdatePasswordField newPassword model =
    model.toolkit
        |> HackingToolkit.setPassword newPassword
        |> flip setToolkit model
        |> Update.fromModel
