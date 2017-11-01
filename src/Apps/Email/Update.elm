module Apps.Email.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Game.Data as Game
import Game.Storyline.Emails.Contents exposing (Content)
import Apps.Email.Models exposing (..)
import Apps.Email.Messages as Email exposing (Msg(..))
import Apps.Email.Menu.Messages as Menu
import Apps.Email.Menu.Update as Menu
import Apps.Email.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> Email.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        SelectContact email ->
            onSelectContact email model

        Reply content ->
            onReply content model


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


onSelectContact : String -> Model -> UpdateResponse
onSelectContact email model =
    Update.mapModel
        (setActiveContact <| Just email)
        (Update.fromModel model)


onReply : Content -> Model -> UpdateResponse
onReply content model =
    let
        dispatch =
            content
                |> Storyline.ReplyEmail
                |> Dispatch.emails
    in
        ( model, Cmd.none, dispatch )
