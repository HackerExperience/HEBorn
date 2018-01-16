module Apps.Popup.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.OS as OS
import Utils.Update as Update
import Game.Data as Game
import Apps.Popup.Models exposing (Model)
import Apps.Popup.Messages as Popup exposing (Msg(..))
import Apps.Popup.Menu.Messages as Menu
import Apps.Popup.Menu.Update as Menu
import Apps.Popup.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        Activation ->
            onActivation data model

        ContinueOnCampaign ->
            onContinueOnCampaign data model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd, coreMsg ) =
            Menu.update data msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd
    in
        ( { model | menu = menu_ }, cmd_, coreMsg )


onActivation : Game.Data -> Model -> UpdateResponse
onActivation data model =
    let
        dispatch =
            Dispatch.os <| OS.CloseApp model.me
    in
        ( model, Cmd.none, dispatch )


onContinueOnCampaign : Game.Data -> Model -> UpdateResponse
onContinueOnCampaign data model =
    let
        dispatch =
            Dispatch.batch
                [ Dispatch.storyline <| Storyline.Toggle
                , Dispatch.os <| OS.CloseApp model.me
                ]
    in
        ( model, Cmd.none, dispatch )
