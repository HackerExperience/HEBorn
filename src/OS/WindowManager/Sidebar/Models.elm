module OS.WindowManager.Sidebar.Models exposing (..)

import Dict exposing (Dict)
import Random.Pcg as Random
import Set exposing (Set)
import Uuid
import OS.WindowManager.Sidebar.Shared exposing (..)
import Widgets.QuestHelper.Models as Quest
import Widgets.TaskList.Models as Tasks


type alias Model =
    { isVisible : Bool
    , widgets : Widgets
    , prioritized : Prioritized
    , seed : Random.Seed
    }


type alias Widgets =
    Dict WidgetId Widget


type alias Prioritized =
    Set WidgetId


type Widget
    = Local LocalWidget
    | External ExternalWidget


type alias LocalWidget =
    { isExpanded : Bool
    , order : Int
    , model : WidgetModel
    }


type alias ExternalWidget =
    { isExpanded : Bool
    , order : Int
    }


type WidgetModel
    = QuestHelperModel Quest.Model
    | TaskListModel Tasks.Model



-- about model


initialModel : Model
initialModel =
    { isVisible = False
    , widgets = Dict.empty
    , prioritized = Set.empty
    , seed = Random.initialSeed 10827990
    }


getVisibility : Model -> Bool
getVisibility =
    .isVisible


setVisibility : Bool -> Model -> Model
setVisibility isVisible model =
    { model | isVisible = isVisible }



-- about widgets


getNewWidgetId : Model -> ( WidgetId, Model )
getNewWidgetId =
    getUuid


hasLocalWidgets : Model -> Bool
hasLocalWidgets { widgets } =
    widgets
        |> Dict.filter (\_ -> isLocal)
        |> Dict.isEmpty
        |> not


getPrioritized : Model -> Prioritized
getPrioritized =
    .prioritized


setPrioritized : Prioritized -> Model -> Model
setPrioritized prioritized model =
    { model | prioritized = prioritized }


getWidgets : Model -> Widgets
getWidgets =
    .widgets


setWidgets : Widgets -> Model -> Model
setWidgets widgets model =
    { model | widgets = widgets }


get : WidgetId -> Model -> Maybe Widget
get id { widgets } =
    Dict.get id widgets


getOrPretend : WidgetId -> Model -> Widget
getOrPretend id { widgets } =
    widgets
        |> Dict.get id
        |> Maybe.withDefault untouchedExternal


insert : WidgetId -> Widget -> Model -> Model
insert id widget model =
    let
        widgets_ =
            Dict.insert id widget model.widgets
    in
        { model | widgets = widgets_ }


remove : WidgetId -> Model -> Model
remove id model =
    let
        widgets_ =
            Dict.remove id model.widgets
    in
        { model | widgets = widgets_ }


prioritize : WidgetId -> Model -> Model
prioritize id model =
    let
        prioritized_ =
            Set.insert id model.prioritized
    in
        { model | prioritized = prioritized_ }


deprioritize : WidgetId -> Model -> Model
deprioritize id model =
    let
        prioritized_ =
            Set.remove id model.prioritized
    in
        { model | prioritized = prioritized_ }


merge :
    Dict WidgetId WidgetModel
    -> Widgets
    -> Dict WidgetId LocalWidget
merge external local =
    let
        onlyExternal id model acu =
            Dict.insert id
                (LocalWidget True 0 model)
                acu

        onlyLocal id data acu =
            case data of
                Local data ->
                    Dict.insert id data acu

                External _ ->
                    acu

        both id model data acu =
            case data of
                Local local ->
                    Dict.insert id
                        { local | model = model }
                        acu

                External { isExpanded, order } ->
                    Dict.insert id
                        (LocalWidget isExpanded order model)
                        acu
    in
        Dict.merge
            onlyExternal
            both
            onlyLocal
            external
            local
            Dict.empty



-- about widget


untouchedExternal : Widget
untouchedExternal =
    External { isExpanded = False, order = 0 }


isLocal : Widget -> Bool
isLocal x =
    case x of
        Local _ ->
            True

        External _ ->
            False


map :
    (LocalWidget -> LocalWidget)
    -> (ExternalWidget -> ExternalWidget)
    -> Widget
    -> Widget
map local external widget =
    case widget of
        Local widget ->
            widget |> local |> Local

        External widget ->
            widget |> external |> External


isExpanded : { a | isExpanded : Bool } -> Bool
isExpanded =
    .isExpanded


setExpanded : Bool -> { a | isExpanded : Bool } -> { a | isExpanded : Bool }
setExpanded isExpanded widget =
    { widget | isExpanded = isExpanded }


toggleExpanded : { a | isExpanded : Bool } -> { a | isExpanded : Bool }
toggleExpanded widget =
    { widget | isExpanded = not widget.isExpanded }


getOrder : { a | order : Int } -> Int
getOrder =
    .order


setOrder : Int -> { a | order : Int } -> { a | order : Int }
setOrder order widget =
    { widget | order = order }


increaseOrder : { a | order : Int } -> { a | order : Int }
increaseOrder ({ order } as widget) =
    -- MOVE DOWN
    { widget | order = order + 1 }


decreaseOrder : { a | order : Int } -> { a | order : Int }
decreaseOrder ({ order } as widget) =
    -- MOVE UP
    { widget | order = order - 1 }



-- about widget model


getTitle : WidgetModel -> String
getTitle model =
    case model of
        QuestHelperModel model ->
            Quest.getTitle model

        TaskListModel model ->
            Tasks.getTitle model


setModel : WidgetModel -> LocalWidget -> LocalWidget
setModel model_ widget =
    { widget | model = model_ }


isExternalOnly : WidgetModel -> Bool
isExternalOnly model =
    case model of
        QuestHelperModel _ ->
            True

        TaskListModel _ ->
            False



-- internals


getUuid : Model -> ( String, Model )
getUuid model =
    let
        ( uuid, seed ) =
            Random.step Uuid.uuidGenerator model.seed
    in
        ( Uuid.toString uuid, { model | seed = seed } )
