module OS.WindowManager.Sidebar.Models exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import OS.WindowManager.Sidebar.Shared exposing (..)
import Widgets.QuestHelper.Models as Quest


type alias Model =
    { isVisible : Bool
    , widgets : Dict WidgetID Widget
    , priorities : Set WidgetID
    }


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
    , priorities = Set.empty
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
        priorities_ =
            Set.insert id model.priorities
    in
        { model | priorities = priorities_ }


deprioritize : WidgetID -> Model -> Model
deprioritize id model =
    let
        priorities_ =
            Set.remove id model.priorities
    in
        { model | priorities = priorities_ }



-- about widget


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
