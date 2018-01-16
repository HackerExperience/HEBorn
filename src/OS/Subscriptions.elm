module OS.Subscriptions exposing (subscriptions)

import OS.Models exposing (..)
import OS.Messages exposing (..)
import Game.Data as Game
import OS.Menu.Models as Menu
import OS.Menu.Subscriptions as Menu
import OS.SessionManager.Models as SessionManager
import OS.SessionManager.Subscriptions as SessionManager


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    let
        menuSub =
            menu model.menu

        sessionSub =
            session data model.session
    in
        Sub.batch
            [ menuSub
            , sessionSub
            ]



-- internals


menu : Menu.Model -> Sub Msg
menu model =
    model
        |> Menu.subscriptions
        |> Sub.map MenuMsg


session : Game.Data -> SessionManager.Model -> Sub Msg
session data model =
    model
        |> SessionManager.subscriptions data
        |> Sub.map SessionManagerMsg
