module OS.WindowManager.Sidebar.Models exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import OS.WindowManager.Sidebar.Shared exposing (..)
import Widgets.QuestHelper.Models as Quest


type alias Model =
    { isVisible : Bool
    , widgets : Widgets
    , prioritized : Prioritized
    }


type alias Widgets =
    Dict WidgetID Widget


type alias Prioritized =
    Set WidgetID


type alias Widget =
    { isExpanded : Bool
    , order : Int
    , model : WidgetModel
    }


type WidgetModel
    = QuestHelperModel Quest.Model



-- about model


initialModel : Model
initialModel =
    { isVisible = False
    , widgets = Dict.empty
    , prioritized = Set.empty
    }


dummyModel : Model
dummyModel =
    { isVisible = True
    , widgets =
        Quest.initialModel
            |> QuestHelperModel
            |> Widget True 0
            |> flip (Dict.insert "test") Dict.empty
    , prioritized =
        Set.empty
            |> Set.insert "test"
    }


getVisibility : Model -> Bool
getVisibility =
    .isVisible


setVisibility : Bool -> Model -> Model
setVisibility isVisible model =
    { model | isVisible = isVisible }



-- about widgets


hasWidgets : Model -> Bool
hasWidgets { widgets } =
    not (Dict.isEmpty widgets)


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


get : WidgetID -> Model -> Maybe Widget
get id { widgets } =
    Dict.get id widgets


set : WidgetID -> Widget -> Model -> Model
set id widget model =
    let
        widgets_ =
            Dict.insert id widget model.widgets
    in
        { model | widgets = widgets_ }


remove : WidgetID -> Model -> Model
remove id model =
    let
        widgets_ =
            Dict.remove id model.widgets
    in
        { model | widgets = widgets_ }


prioritize : WidgetID -> Model -> Model
prioritize id model =
    let
        prioritized_ =
            Set.insert id model.prioritized
    in
        { model | prioritized = prioritized_ }


deprioritize : WidgetID -> Model -> Model
deprioritize id model =
    let
        prioritized_ =
            Set.remove id model.prioritized
    in
        { model | prioritized = prioritized_ }



-- about widget


getOrder : Widget -> Int
getOrder =
    .order


setOrder : Int -> Widget -> Widget
setOrder order widget =
    { widget | order = order }


isExpanded : Widget -> Bool
isExpanded =
    .isExpanded


setExpanded : Bool -> Widget -> Widget
setExpanded isExpanded widget =
    { widget | isExpanded = isExpanded }


increaseOrder : Widget -> Widget
increaseOrder ({ order } as widget) =
    -- MOVE DOWN
    { widget | order = order + 1 }


decreaseOrder : Widget -> Widget
decreaseOrder ({ order } as widget) =
    -- MOVE UP
    { widget | order = order - 1 }



-- about widget model


getTitle : WidgetModel -> String
getTitle model =
    case model of
        QuestHelperModel _ ->
            "Quest: TODO"
