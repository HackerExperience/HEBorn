module Widgets.TaskList.Models exposing (..)

import Utils.List as List


type alias Model =
    { entries : List ( Bool, String )
    , title : String
    }


initialModel : Model
initialModel =
    Model [ ( False, "" ) ] "Untitled"


getTitle : Model -> String
getTitle { title } =
    (++) "Tasks: " <|
        if String.isEmpty title then
            "Unnamed"
        else
            title


insert : String -> Model -> Model
insert value_ model =
    { model | entries = model.entries ++ [ ( False, value_ ) ] }


set : Int -> String -> Model -> Model
set i value_ model =
    let
        each k (( c, v ) as orig) =
            if (k == i) then
                ( c, value_ )
            else
                orig

        entries_ =
            List.indexedMap each model.entries
    in
        { model | entries = entries_ }


toggleCheck : Int -> Model -> Model
toggleCheck i model =
    let
        each k (( c, v ) as orig) =
            if (k == i) then
                ( not c, v )
            else
                orig

        entries_ =
            List.indexedMap each model.entries
    in
        { model | entries = entries_ }


remove : Int -> Model -> Model
remove i model =
    model.entries
        |> List.splitOut i
        |> Tuple.mapFirst (List.dropRight 1)
        |> uncurry (++)
        |> flip setEntries model


setEntries : List ( Bool, String ) -> Model -> Model
setEntries entries_ model =
    { model | entries = entries_ }
