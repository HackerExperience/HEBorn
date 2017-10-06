module OS.SessionManager.WindowManager.Update exposing (..)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import Utils.Update as Update
import Apps.Update as Apps
import Apps.Messages as Apps
import Game.Data as Game
import Game.Meta.Types exposing (Context(..))
import Game.Servers.Models as Servers
import Game.Storyline.Missions.Actions exposing (Action(GoApp))
import OS.SessionManager.WindowManager.Models exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        OnDragBy ( x, y ) ->
            case model.focusing of
                Just id ->
                    model
                        |> move id x y
                        |> Update.fromModel

                Nothing ->
                    Update.fromModel model

        DragMsg dragMsg ->
            let
                ( model_, cmd ) =
                    Draggable.update dragConfig dragMsg model
            in
                ( model_, cmd, Dispatch.none )

        StartDragging id ->
            model
                |> startDragging id
                |> Update.fromModel

        StopDragging ->
            model
                |> stopDragging
                |> Update.fromModel

        UpdateFocusTo maybeID ->
            case maybeID of
                Just id ->
                    model
                        |> focus id
                        |> wrapGoApp data id

                Nothing ->
                    model
                        |> unfocus
                        |> Update.fromModel

        Close id ->
            model
                |> remove id
                |> unfocus
                |> Update.fromModel

        ToggleMaximize id ->
            model
                |> toggleMaximize id
                |> unfocus
                |> focus id
                |> Update.fromModel

        Minimize id ->
            model
                |> minimize id
                |> unfocus
                |> Update.fromModel

        SwitchContext id ->
            model
                |> toggleContext id
                |> wrapGoApp data id

        WindowMsg id msg ->
            let
                ( model_, cmd, dispatch ) =
                    updateApp data id msg model

                cmd_ =
                    Cmd.map (WindowMsg id) cmd
            in
                ( model_, cmd_, dispatch )

        AppMsg id context msg ->
            let
                ( model_, cmd, dispatch ) =
                    updateContext data id context msg model

                cmd_ =
                    Cmd.map (WindowMsg id) cmd
            in
                ( model_, cmd_, dispatch )



-- internals


updateApp :
    Game.Data
    -> ID
    -> Apps.Msg
    -> Model
    -> ( Model, Cmd Apps.Msg, Dispatch )
updateApp data id msg ({ windows } as model0) =
    case Dict.get id windows of
        Just window0 ->
            let
                window =
                    case window0.endpoint of
                        Nothing ->
                            let
                                ip =
                                    data
                                        |> Game.getServer
                                        |> Servers.getEndpoint
                            in
                                { window0 | endpoint = ip }

                        Just _ ->
                            window0

                model =
                    refresh id window model0

                appModel =
                    getAppModelFromWindow window

                ( appModel_, cmd, dispatch ) =
                    Apps.update (windowData data id window model) msg appModel

                model_ =
                    setAppModel id appModel_ model
            in
                ( model_, cmd, dispatch )

        Nothing ->
            Update.fromModel model0


updateContext :
    Game.Data
    -> ID
    -> Context
    -> Apps.Msg
    -> Model
    -> ( Model, Cmd Apps.Msg, Dispatch )
updateContext data id targetContext msg ({ windows } as model) =
    case Dict.get id windows of
        Just window ->
            case window.context of
                Just activeContext ->
                    if (targetContext == activeContext) then
                        updateApp data id msg model
                    else
                        model
                            |> toggleContext id
                            |> updateApp data id msg
                            |> Update.mapModel (toggleContext id)

                Nothing ->
                    updateApp data id msg model

        Nothing ->
            Update.fromModel model


wrapGoApp :
    Game.Data
    -> ID
    -> Model
    -> UpdateResponse
wrapGoApp data id ({ windows } as model) =
    case Dict.get id windows of
        Just { context, app } ->
            let
                dispatch =
                    case context of
                        Just context ->
                            context
                                |> GoApp app
                                |> Dispatch.missionAction data

                        Nothing ->
                            Dispatch.none
            in
                ( model, Cmd.none, dispatch )

        Nothing ->
            Update.fromModel model


dragConfig : Draggable.Config ID Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragStart StartDragging
        ]
