module Apps.Browser.Update exposing (update)

import Game.Data as GameData
import Apps.Browser.Models exposing (..)
import Apps.Browser.Pages.Models as Pages
import Game.Web.Models as Web
import Game.Web.Types as Web
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Menu.Messages as Menu
import Apps.Browser.Menu.Update as Menu
import Apps.Browser.Menu.Actions as Menu
import Core.Dispatch as Dispatch exposing (Dispatch)


update : GameData.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg model =
    case msg of
        -- Menu
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update data msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        -- App
        UpdateAddress newAddr ->
            let
                app =
                    getApp model

                app_ =
                    { app | addressBar = newAddr }

                model_ =
                    setApp app_ model
            in
                ( model_, Cmd.none, Dispatch.none )

        GoPrevious ->
            let
                app_ =
                    gotoPreviousPage <| getApp model

                model_ =
                    setApp app_ model
            in
                ( model_, Cmd.none, Dispatch.none )

        GoNext ->
            let
                app_ =
                    gotoNextPage <| getApp model

                model_ =
                    setApp app_ model
            in
                ( model_, Cmd.none, Dispatch.none )

        PageMsg ->
            ( model, Cmd.none, Dispatch.none )

        TabGo n ->
            let
                model_ =
                    goTab n model
            in
                ( model_, Cmd.none, Dispatch.none )

        GoAddress url ->
            let
                ( app_, dispatch ) =
                    goPage url data <| getApp model

                model_ =
                    setApp app_ model
            in
                ( model_, Cmd.none, dispatch )

        NewTabInAddress url ->
            let
                createTabModel =
                    addTab model

                goTabModel =
                    -- DIRTY
                    goTab
                        createTabModel.lastTab
                        createTabModel

                ( app_, dispatch ) =
                    goPage url data <| getApp goTabModel

                model_ =
                    setApp app_ goTabModel
            in
                ( model_, Cmd.none, dispatch )


goPage : String -> GameData.Data -> Browser -> ( Browser, Dispatch )
goPage url data app =
    let
        site =
            Web.get url data.game.web

        dispatch =
            case site.type_ of
                Web.Unknown ->
                    -- uncomment this line after adding DNS support
                    -- to the back end:
                    -- Dispatch.web (Web.Load app.addressBar)
                    Dispatch.none

                _ ->
                    Dispatch.none

        app_ =
            gotoPage url (Pages.initialModel site) app
    in
        ( app_, dispatch )
