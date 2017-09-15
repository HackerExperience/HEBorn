module Apps.Browser.Update exposing (update)

import Utils.Update as Update
import Game.Data as GameData
import Game.Meta.Types exposing (Context(..))
import Game.Web.Messages as Web
import Game.Web.DNS exposing (..)
import Apps.Config exposing (..)
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Models exposing (..)
import Apps.Browser.Pages.Models as Pages
import Apps.Browser.Menu.Messages as Menu
import Apps.Browser.Menu.Update as Menu
import Apps.Browser.Menu.Actions as Menu
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : GameData.Data -> Msg -> Model -> UpdateResponse
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
            updateAddress newAddr model

        GoPrevious ->
            goPrevious model

        GoNext ->
            goNext model

        PageMsg ->
            -- WHAT THE HELL IS THIS?
            ( model, Cmd.none, Dispatch.none )

        TabGo tabK ->
            goTab tabK model
                |> Update.fromModel

        GoAddress url ->
            goAddress url model

        NewTabInAddress url ->
            newTabInAddress url model

        Fetched tabK response ->
            fetched tabK response model



-- internals


goPage :
    String
    -> Config
    -> Int
    -> Tab
    -> ( Tab, Dispatch )
goPage url { sessionId, windowId, context, serverId } tabK tab =
    let
        requester =
            { sessionId = sessionId
            , windowId = windowId
            , context = context
            , tabK = tabK
            }

        dispatch =
            case serverId of
                Just serverId ->
                    Web.FetchUrl serverId url requester
                        |> Dispatch.web

                Nothing ->
                    Debug.crash "Browser always need a serverId"

        tab_ =
            gotoPage url Pages.LoadingModel tab
    in
        ( tab_, dispatch )


updateAddress : URL -> Model -> UpdateResponse
updateAddress newAddr model =
    let
        tab =
            getNowTab model

        tab_ =
            { tab | addressBar = newAddr }

        model_ =
            setNowTab tab_ model
    in
        Update.fromModel model_


goPrevious : Model -> UpdateResponse
goPrevious model =
    let
        tab_ =
            gotoPreviousPage <| getNowTab model

        model_ =
            setNowTab tab_ model
    in
        Update.fromModel model_


goNext : Model -> UpdateResponse
goNext model =
    let
        tab_ =
            gotoNextPage <| getNowTab model

        model_ =
            setNowTab tab_ model
    in
        Update.fromModel model_


goAddress : URL -> Model -> UpdateResponse
goAddress url model =
    let
        ( tab_, dispatch ) =
            goPage url model.me model.nowTab <| getNowTab model

        model_ =
            setNowTab tab_ model
    in
        ( model_, Cmd.none, dispatch )


newTabInAddress : URL -> Model -> UpdateResponse
newTabInAddress url model =
    let
        createTabModel =
            addTab model

        goTabModel =
            -- DIRTY
            goTab
                createTabModel.lastTab
                createTabModel

        ( tab_, dispatch ) =
            goPage url model.me goTabModel.nowTab <| getNowTab goTabModel

        model_ =
            setNowTab tab_ goTabModel
    in
        ( model_, Cmd.none, dispatch )


fetched : Int -> Response -> Model -> UpdateResponse
fetched tabK response model =
    let
        tab =
            getTab tabK model.tabs

        ( url, pageModel ) =
            case response of
                ConnectionError url ->
                    -- TODO: Change to some "failed" page
                    ( url, Pages.BlankModel )

                NotFounded url ->
                    ( url, Pages.NotFoundModel { url = url } )

                Okay site ->
                    ( site.url, Pages.initialModel site )
    in
        if
            ((&&)
                (Pages.isLoading <| getPage tab)
                ((getURL tab) == url)
            )
        then
            let
                tab_ =
                    gotoPage url pageModel tab

                tabs_ =
                    setTab tabK tab_ model.tabs

                model_ =
                    { model | tabs = tabs_ }
            in
                Update.fromModel model_
        else
            Update.fromModel model
