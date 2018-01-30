module Utils.React
    exposing
        ( React
        , none
        , msg
        , cmd
        , addMsg
        , addCmd
        , batch
        , map
        , update
        , toCmd
        , split
        )

import Task


type React msg
    = Message msg
    | Command (Cmd msg)
    | Both msg (Cmd msg)
    | None


none : React msg
none =
    None


msg : msg -> React msg
msg =
    Message


cmd : Cmd msg -> React msg
cmd =
    Command


addMsg : (List msg -> msg) -> msg -> React msg -> React msg
addMsg func msg2 react =
    case react of
        Message msg1 ->
            Message <| func [ msg1, msg2 ]

        Command cmd ->
            Both msg2 cmd

        Both msg1 cmd ->
            Both (func [ msg1, msg2 ]) cmd

        None ->
            Message msg2


addCmd : Cmd msg -> React msg -> React msg
addCmd cmd2 react =
    case react of
        Message msg ->
            Both msg cmd2

        Command cmd1 ->
            Command <| Cmd.batch [ cmd1, cmd2 ]

        Both msg cmd1 ->
            Both msg (Cmd.batch [ cmd1, cmd2 ])

        None ->
            Command cmd2


batch : (List msg -> msg) -> List (React msg) -> React msg
batch func =
    List.foldl (merge func) None


map : (a -> b) -> React a -> React b
map f react =
    case react of
        Message msg ->
            Message <| f msg

        Command cmd ->
            Command <| Cmd.map f cmd

        Both msg cmd ->
            Both (f msg) (Cmd.map f cmd)

        None ->
            None


update : model -> ( model, React msg )
update model =
    ( model, none )


toCmd : React msg -> Cmd msg
toCmd react =
    case react of
        Message msg ->
            toCmd_ msg

        Command cmd ->
            cmd

        Both msg cmd ->
            Cmd.batch [ toCmd_ msg, cmd ]

        None ->
            Cmd.none


split : React msg -> ( Maybe msg, Cmd msg )
split react =
    case react of
        Message msg ->
            ( Just msg, Cmd.none )

        Command cmd ->
            ( Nothing, cmd )

        Both msg cmd ->
            ( Just msg, cmd )

        None ->
            ( Nothing, Cmd.none )



-- helper


merge : (List msg -> msg) -> React msg -> React msg -> React msg
merge func react1 react2 =
    case react1 of
        Message msg ->
            addMsg func msg react2

        Command cmd ->
            addCmd cmd react2

        Both msg cmd ->
            react2
                |> addMsg func msg
                |> addCmd cmd

        None ->
            react2


toCmd_ : msg -> Cmd msg
toCmd_ msg =
    Task.perform (always msg) (Task.succeed ())
