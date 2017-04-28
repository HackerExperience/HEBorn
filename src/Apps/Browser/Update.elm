module Apps.Browser.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import Core.Dispatcher exposing (callFilesystem)
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Messages as Filesystem
import Apps.Instances.Models as Instance
import Apps.Context as Context
import Apps.Browser.Models
    exposing
        ( Model
        , initialBrowserContext
        , getBrowserInstance
        )
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Context.Messages as MsgContext
import Apps.Browser.Context.Update
import Apps.Browser.Context.Actions exposing (actionHandler)


update : Msg -> Model -> GameModel -> ( Model, Cmd Msg, List CoreMsg )
update msg model game =
    case msg of
        -- Browser
        -- Instance
        OpenInstance id ->
            let
                instances_ =
                    Instance.open
                        model.instances
                        id
                        initialBrowserContext
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        CloseInstance id ->
            let
                instances_ =
                    Instance.close model.instances id
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        -- Context
        SwitchContext id ->
            let
                instance =
                    getBrowserInstance model.instances id

                instance_ =
                    Context.switch instance

                instances_ =
                    Instance.update model.instances id instance_
            in
                ( { model | instances = instances_ }, Cmd.none, [] )

        -- Menu
        ContextMsg (MsgContext.MenuClick action id) ->
            actionHandler action id model game

        ContextMsg subMsg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Apps.Browser.Context.Update.update subMsg model.menu game

                cmd_ =
                    Cmd.map ContextMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        -- Server-side notifications
        Event event ->
            ( model, Cmd.none, [] )

        Request _ ->
            ( model, Cmd.none, [] )

        Response request data ->
            ( model, Cmd.none, [] )
