module Game.Servers.Dummy exposing (dummy)

import Dict
import Game.Servers.Models exposing (..)
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Logs.Models as Logs
import Game.Servers.Processes.Models as Processes
import Game.Servers.Shared exposing (..)
import Game.Servers.Tunnels.Models as Tunnels
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Hardware.Models as Hardware
import Game.Notifications.Models as Notifications


dummy : Model
dummy =
    Model dummyGateways dummyEndpoints


dummyGateways : Gateways
dummyGateways =
    Dict.empty
        |> Dict.insert
            "10::4ebf:59da:5481:b044:3b56"
            { activeNIP = ( "::", "321.165.28.238" )
            , nips = []
            , endpoints = []
            }
        |> Dict.insert
            "10::4ebf:59da:5481:b044:4b56"
            { activeNIP = ( "::", "421.165.28.238" )
            , nips = []
            , endpoints = []
            }
        |> Dict.insert
            "10::4ebf:59da:5481:b044:5b56"
            { activeNIP = ( "::", "521.165.28.238" )
            , nips = []
            , endpoints = []
            }
        |> Dict.insert
            "10::4ebf:59da:5481:b044:6b56"
            { activeNIP = ( "::", "621.165.28.238" )
            , nips = []
            , endpoints = []
            }


dummyEndpoints : Servers
dummyEndpoints =
    Dict.empty
        |> Dict.insert
            "10::4ebf:59da:5481:b044:3b56"
            { name = "Gateway1"
            , type_ = Desktop
            , nips = []
            , coordinates = Nothing
            , mainStorage = "gateway1"
            , storages =
                (Dict.insert
                    ""
                    { name = "gateway1"
                    , filesystem = Filesystem.initialModel
                    }
                    Dict.empty
                )
            , logs = Logs.initialModel
            , processes = Processes.initialModel
            , tunnels = Tunnels.initialModel
            , ownership =
                GatewayOwnership
                    { activeNIP = ( "::", "321.165.28.238" )
                    , endpoints = []
                    , endpoint = Nothing
                    }
            , notifications = Notifications.initialModel
            , hardware = Hardware.initialModel
            }
        |> Dict.insert
            "10::4ebf:59da:5481:b044:4b56"
            { name = "Gateway2"
            , type_ = DesktopCampaign
            , nips = []
            , coordinates = Nothing
            , mainStorage = "gateway2"
            , storages =
                (Dict.insert
                    ""
                    { name = "gateway2"
                    , filesystem = Filesystem.initialModel
                    }
                    Dict.empty
                )
            , logs = Logs.initialModel
            , processes = Processes.initialModel
            , tunnels = Tunnels.initialModel
            , ownership =
                GatewayOwnership
                    { activeNIP = ( "::", "421.165.28.238" )
                    , endpoints = []
                    , endpoint = Nothing
                    }
            , notifications = Notifications.initialModel
            , hardware = Hardware.initialModel
            }
        |> Dict.insert
            "10::4ebf:59da:5481:b044:5b56"
            { name = "Gateway3"
            , type_ = Desktop
            , nips = []
            , coordinates = Nothing
            , mainStorage = "gateway3"
            , storages =
                (Dict.insert
                    ""
                    { name = "gateway3"
                    , filesystem = Filesystem.initialModel
                    }
                    Dict.empty
                )
            , logs = Logs.initialModel
            , processes = Processes.initialModel
            , tunnels = Tunnels.initialModel
            , ownership =
                GatewayOwnership
                    { activeNIP = ( "::", "521.165.28.238" )
                    , endpoints = []
                    , endpoint = Nothing
                    }
            , notifications = Notifications.initialModel
            , hardware = Hardware.initialModel
            }
        |> Dict.insert
            "10::4ebf:59da:5481:b044:6b56"
            { name = "Gateway4"
            , type_ = DesktopCampaign
            , nips = []
            , coordinates = Nothing
            , mainStorage = "gateway4"
            , storages =
                (Dict.insert
                    ""
                    { name = "gateway4"
                    , filesystem = Filesystem.initialModel
                    }
                    Dict.empty
                )
            , logs = Logs.initialModel
            , processes = Processes.initialModel
            , tunnels = Tunnels.initialModel
            , ownership =
                GatewayOwnership
                    { activeNIP = ( "::", "621.165.28.238" )
                    , endpoints = []
                    , endpoint = Nothing
                    }
            , notifications = Notifications.initialModel
            , hardware = Hardware.initialModel
            }
