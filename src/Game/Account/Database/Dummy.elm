module Game.Account.Database.Dummy exposing (dummy)

import Dict as Dict
import Game.Account.Database.Models exposing (..)


dummy : Model
dummy =
    Model
        dummyServers
        dummyAccounts
        dummyBitcoins


dummyServers : HackedServers
dummyServers =
    Dict.empty
        |> Dict.insert ( "::", "153.249.31.179" )
            { password = "WhenYouWereHereBefore"
            , label = Just "Creep 1"
            , notes = Just "Weirdo"
            , virusInstalled =
                [ ( "dummyVirus", "GrandpaChair.mlw", 2.1 )
                , ( "dummyThrojan", "GrandmaTshirt.mlw", 2.0 )
                ]
            , activeVirus = Just ( "dummyThrojan", 1498589047000 )
            , type_ = Player
            , remoteConn = Nothing
            }
        |> Dict.insert ( "::", "143.239.31.169" )
            { password = "WhenYouWereHereBefore"
            , label = Just "Creep 2"
            , notes = Just "Weirdo"
            , virusInstalled =
                [ ( "dummyVirus", "GrandpaChair.mlw", 2.1 )
                , ( "dummyThrojan", "GrandmaTshirt.mlw", 2.0 )
                ]
            , activeVirus = Just ( "dummyThrojan", 1498589047000 )
            , type_ = Player
            , remoteConn = Nothing
            }
        |> Dict.insert ( "::", "153.249.31.179" )
            { password = "WhenYouWereHereBefore"
            , label = Just "Creep 1"
            , notes = Just "Weirdo"
            , virusInstalled =
                [ ( "dummyVirus", "GrandpaChair.mlw", 2.1 )
                , ( "dummyThrojan", "GrandmaTshirt.mlw", 2.0 )
                ]
            , activeVirus = Just ( "dummyThrojan", 1498589047000 )
            , type_ = Player
            , remoteConn = Nothing
            }
        |> Dict.insert ( "::", "143.239.31.169" )
            { password = "WhenYouWereHereBefore"
            , label = Just "Creep 2"
            , notes = Just "Weirdo"
            , virusInstalled =
                [ ( "dummyVirus", "GrandpaChair.mlw", 2.1 )
                , ( "dummyThrojan", "GrandmaTshirt.mlw", 2.0 )
                ]
            , activeVirus = Just ( "dummyThrojan", 1498589047000 )
            , type_ = Player
            , remoteConn = Nothing
            }


dummyAccounts : HackedBankAccounts
dummyAccounts =
    Dict.empty
        |> Dict.insert ( "server1", 123456 )
            { name = "Santander"
            , bank = "server1"
            , account = 123456
            , password = "babafeisu"
            , balance = 100000000
            }
        |> Dict.insert ( "server2", 542589 )
            { name = "Intermedium"
            , bank = "server2"
            , account = 542589
            , password = "retangulo"
            , balance = 200000000
            }
        |> Dict.insert ( "server3", 475852 )
            { name = "Bradesco"
            , bank = "server2"
            , account = 475852
            , password = "quadrado"
            , balance = 300000000
            }
        |> Dict.insert ( "server4", 663521 )
            { name = "Banco do Brasil"
            , bank = "server3"
            , account = 663521
            , password = "circulo"
            , balance = 400000000
            }
        |> Dict.insert ( "server5", 946132 )
            { name = "Itau"
            , bank = "server4"
            , account = 946132
            , password = "standpower"
            , balance = 500000000
            }
        |> Dict.insert ( "server6", 784562 )
            { name = "Neon"
            , bank = "server5"
            , account = 784562
            , password = "starplatinum"
            , balance = 600000000
            }
        |> Dict.insert ( "server7", 885522 )
            { name = "Caixa Econôimca Federal"
            , bank = "server6"
            , account = 885522
            , password = "theworld"
            , balance = 700000000
            }
        |> Dict.insert ( "server8", 497850 )
            { name = "Nossa Caixa Estadual"
            , bank = "server7"
            , account = 497850
            , password = "jojonokimyounabouken"
            , balance = 800000000
            }


dummyBitcoins : HackedBitcoinWallets
dummyBitcoins =
    Dict.empty
