module Utils.Events exposing (..)

import Json.Decode exposing (Value)


type alias Router a =
    Context -> Name -> Value -> Maybe a


type alias Handler a =
    Value -> Maybe a


type alias Context =
    Maybe String


type alias Name =
    String


parse : Name -> ( Maybe Name, Name )
parse str =
    case List.head (String.indexes "." str) of
        Just index ->
            let
                context =
                    String.slice 0 index str

                remains =
                    String.slice (index + 1) (String.length str) str
            in
                ( Just context, remains )

        Nothing ->
            ( Nothing, str )
