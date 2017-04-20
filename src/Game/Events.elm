module Game.Events exposing (eventHandler)

import Events.Models exposing (Event)
import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg)
import Game.Meta.Events exposing (metaEventHandler)
import Game.Account.Events exposing (accountEventHandler)


-- import Game.Software.Events exposing (softwareEventHandler)

import Game.Servers.Events exposing (serversEventHandler)
import Game.Network.Events exposing (networkEventHandler)


eventHandler : GameModel -> Event -> ( GameModel, Cmd GameMsg, List CoreMsg )
eventHandler model event =
    let
        ( meta_, cmdMeta ) =
            metaEventHandler model.meta event

        ( account_, cmdAccount ) =
            accountEventHandler model.account event

        ( servers_, cmdServers ) =
            serversEventHandler model.servers event

        ( network_, cmdNetwork ) =
            networkEventHandler model.network event

        cmdList =
            [ cmdMeta ]
                ++ [ cmdAccount ]
                ++ [ cmdServers ]
                ++ [ cmdNetwork ]

        cmdList_ =
            List.filter (\x -> List.member x cmdList) cmdList

        model_ =
            { meta = meta_
            , account = account_
            , network = network_
            , servers = servers_
            }
    in
        ( model_, Cmd.batch cmdList_, [] )
