module Apps.FloatingHeads.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.OS as OS
import Game.Data as Game
import Game.Storyline.Emails.Models as Emails exposing (ID)
import Game.Storyline.Emails.Contents exposing (Content)
import Apps.FloatingHeads.Models exposing (Model, Mode(..))
import Apps.FloatingHeads.Messages as FloatingHeads exposing (Msg(..))
import Utils.Html.Events exposing (onClickMe, onKeyDown)
import Apps.Reference exposing (Reference)
import Apps.FloatingHeads.Menu.Messages as Menu
import Apps.FloatingHeads.Menu.Update as Menu
import Apps.FloatingHeads.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd FloatingHeads.Msg, Dispatch )


update :
    Game.Data
    -> FloatingHeads.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        Reply content ->
            onReply data content model

        HandleSelectContact contact ->
            handleSelectContact data contact model

        ToggleMode ->
            onToggleMode data model

        Close ->
            onClose data model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    Update.child
        { get = .menu
        , set = (\menu model -> { model | menu = menu })
        , toMsg = MenuMsg
        , update = (Menu.update data)
        }
        msg
        model


onReply : Game.Data -> Content -> Model -> UpdateResponse
onReply data content model =
    let
        dispatch =
            content
                |> Storyline.ReplyEmail
                |> Dispatch.emails
    in
        ( model, Cmd.none, dispatch )


handleSelectContact : Game.Data -> ID -> Model -> UpdateResponse
handleSelectContact data contact model =
    let
        model_ =
            { model | activeContact = contact }
    in
        Update.fromModel model_


onToggleMode : Game.Data -> Model -> UpdateResponse
onToggleMode data model =
    let
        model_ =
            case model.mode of
                Compact ->
                    { model | mode = Expanded }

                Expanded ->
                    { model | mode = Compact }
    in
        Update.fromModel model_


onClose : Game.Data -> Model -> UpdateResponse
onClose data model =
    let
        dispatch =
            Dispatch.os <| OS.CloseApp model.me
    in
        ( model, Cmd.none, dispatch )
