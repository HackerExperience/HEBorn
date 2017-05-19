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
import Apps.Browser.Menu.Messages as MsgMenu
import Apps.Browser.Menu.Update
import Apps.Browser.Menu.Actions exposing (actionHandler)


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
        MenuMsg (MsgMenu.MenuClick action id) ->
            actionHandler action id model game

        MenuMsg subMsg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Apps.Browser.Menu.Update.update subMsg model.menu game

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        -- Server-side notifications
        Event event ->
            ( model, Cmd.none, [] )

        Request _ ->
            ( model, Cmd.none, [] )

        Response request data ->
            ( model, Cmd.none, [] )
