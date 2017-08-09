module Utils.Update
    exposing
        ( Config
        , fromModel
        , child
        , mapModel
        , mapCmd
        , addCmd
        , addDispatch
        , andThen
        )

import Core.Dispatch as Dispatch exposing (Dispatch)


type alias Config msg subMsg model subModel =
    { get : model -> subModel
    , set : subModel -> model -> model
    , toMsg : subMsg -> msg
    , update : subMsg -> subModel -> ( subModel, Cmd subMsg, Dispatch )
    }


fromModel : model -> ( model, Cmd msg, Dispatch )
fromModel model =
    ( model, Cmd.none, Dispatch.none )


child :
    Config msg subMsg model subModel
    -> (subMsg -> model -> ( model, Cmd msg, Dispatch ))
child { get, set, toMsg, update } msg model =
    let
        ( innerModel, cmd, dispatch ) =
            update msg (get model)

        model_ =
            set innerModel model

        cmd_ =
            Cmd.map toMsg cmd
    in
        ( model_, cmd_, dispatch )


mapModel : (a -> b) -> ( a, Cmd msg, Dispatch ) -> ( b, Cmd msg, Dispatch )
mapModel func ( model, cmd, dispatch ) =
    ( func model, cmd, dispatch )


mapCmd : (a -> b) -> ( model, Cmd a, Dispatch ) -> ( model, Cmd b, Dispatch )
mapCmd func ( model, cmd, dispatch ) =
    ( model, Cmd.map func cmd, dispatch )


addCmd : Cmd msg -> ( model, Cmd msg, Dispatch ) -> ( model, Cmd msg, Dispatch )
addCmd cmd ( model, cmds, dispatch ) =
    ( model, Cmd.batch [ cmd, cmds ], dispatch )


addDispatch :
    Dispatch
    -> ( model, Cmd msg, Dispatch )
    -> ( model, Cmd msg, Dispatch )
addDispatch dispatch ( model, cmd, dispatches ) =
    ( model, cmd, Dispatch.batch [ dispatch, dispatches ] )


andThen :
    (model -> ( model, Cmd msg, Dispatch ))
    -> ( model, Cmd msg, Dispatch )
    -> ( model, Cmd msg, Dispatch )
andThen func ( model, cmd, dispatch ) =
    let
        ( model_, tmpCmd, tmpDispatch ) =
            func model

        cmd_ =
            Cmd.batch [ cmd, tmpCmd ]

        dispatch_ =
            Dispatch.batch [ dispatch, tmpDispatch ]
    in
        ( model_, cmd_, dispatch_ )
