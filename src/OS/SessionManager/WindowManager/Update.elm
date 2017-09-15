module OS.SessionManager.WindowManager.Update exposing (..)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import Apps.Update as Apps
import Apps.Messages as Apps
import Game.Data as Game
import Game.Meta.Types exposing (Context(..))
import Game.Servers.Models as Servers
import OS.SessionManager.WindowManager.Models exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))


update : Game.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg model =
    case msg of
        OnDragBy ( x, y ) ->
            case model.focusing of
                Just id ->
                    model
                        |> move id x y
                        |> wrapEmpty

                Nothing ->
                    wrapEmpty model

        DragMsg dragMsg ->
            let
                ( model_, cmd ) =
                    Draggable.update dragConfig dragMsg model
            in
                ( model_, cmd, Dispatch.none )

        StartDragging id ->
            model
                |> startDragging id
                |> wrapEmpty

        StopDragging ->
            model
                |> stopDragging
                |> wrapEmpty

        UpdateFocusTo maybeID ->
            case maybeID of
                Just id ->
                    model
                        |> focus id
                        |> wrapEmpty

                Nothing ->
                    model
                        |> unfocus
                        |> wrapEmpty

        Close id ->
            model
                |> remove id
                |> unfocus
                |> wrapEmpty

        ToggleMaximize id ->
            model
                |> toggleMaximize id
                |> unfocus
                |> focus id
                |> wrapEmpty

        Minimize id ->
            model
                |> minimize id
                |> unfocus
                |> wrapEmpty

        SwitchContext id ->
            model
                |> toggleContext id
                |> wrapEmpty

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
            ( model0, Cmd.none, Dispatch.none )


updateContext :
    Game.Data
    -> ID
    -> Context
    -> Apps.Msg
    -> Model
    -> ( Model, Cmd Apps.Msg, Dispatch )
updateContext data id targetContext msg ({ windows } as model0) =
    case Dict.get id windows of
        Nothing ->
            ( model0, Cmd.none, Dispatch.none )

        Just window0 ->
            case window0.context of
                Just activeContext ->
                    if (targetContext == activeContext) then
                        updateApp data id msg model0
                    else
                        -- TODO: Code this case (when nsg has to go to unactive context)
                        ( model0, Cmd.none, Dispatch.none )

                Nothing ->
                    if (targetContext /= Gateway) then
                        ( model0, Cmd.none, Dispatch.none )
                    else
                        updateApp data id msg model0


wrapEmpty : Model -> ( Model, Cmd Msg, Dispatch )
wrapEmpty model =
    ( model, Cmd.none, Dispatch.none )


dragConfig : Draggable.Config ID Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragStart StartDragging
        ]
