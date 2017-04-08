module Game.Events exposing (eventHandler)

import Events.Models exposing (Event)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg)
import Game.Meta.Events exposing (metaEventHandler)
import Game.Account.Events exposing (accountEventHandler)
import Game.Software.Events exposing (softwareEventHandler)
import Game.Server.Events exposing (serverEventHandler)
import Game.Network.Events exposing (networkEventHandler)


eventHandler : GameModel -> Event -> ( GameModel, Cmd GameMsg )
eventHandler model event =
    let
        ( meta_, cmdMeta ) =
            metaEventHandler model.meta event

        ( account_, cmdAccount ) =
            accountEventHandler model.account event

        ( software_, cmdSoftware ) =
            softwareEventHandler model.software event

        ( server_, cmdServer ) =
            serverEventHandler model.server event

        ( network_, cmdNetwork ) =
            networkEventHandler model.network event

        cmdList =
            [ cmdMeta ]
                ++ [ cmdAccount ]
                ++ [ cmdSoftware ]
                ++ [ cmdServer ]
                ++ [ cmdNetwork ]

        cmdList_ =
            List.filter (\x -> List.member x cmdList) cmdList

        model_ =
            { meta = meta_
            , account = account_
            , software = software_
            , network = network_
            , server = server_
            }
    in
        ( model_, Cmd.batch cmdList_ )
