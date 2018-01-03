module Game.Account.Finances.Dummy exposing (dummy)

import Dict as Dict
import Game.Account.Finances.Models exposing (..)


dummy : Model
dummy =
    Model
        dummyAccounts
        dummyBitcoins


dummyAccounts : BankAccounts
dummyAccounts =
    Dict.empty
        |> Dict.insert ( "server1", 123456 )
            { name = "Santander"
            , password = "babafeisu"
            , balance = 100000000
            }
        |> Dict.insert ( "server2", 542589 )
            { name = "Intermedium"
            , password = "retangulo"
            , balance = 200000000
            }
        |> Dict.insert ( "server3", 475852 )
            { name = "Bradesco"
            , password = "quadrado"
            , balance = 300000000
            }
        |> Dict.insert ( "server4", 663521 )
            { name = "Banco do Brasil"
            , password = "circulo"
            , balance = 400000000
            }
        |> Dict.insert ( "server5", 946132 )
            { name = "Itau"
            , password = "standpower"
            , balance = 500000000
            }
        |> Dict.insert ( "server6", 784562 )
            { name = "Neon"
            , password = "starplatinum"
            , balance = 600000000
            }
        |> Dict.insert ( "server7", 885522 )
            { name = "Caixa Econôimca Federal"
            , password = "theworld"
            , balance = 700000000
            }
        |> Dict.insert ( "server8", 497850 )
            { name = "Nossa Caixa Estadual"
            , password = "jojonokimyounabouken"
            , balance = 800000000
            }


dummyBitcoins : BitcoinWallets
dummyBitcoins =
    Dict.empty
