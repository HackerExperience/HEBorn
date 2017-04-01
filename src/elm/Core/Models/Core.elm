module Core.Models.Core exposing (..)

import Dict

import Core.Models.Shared exposing (..)
import Core.Models.Account exposing (..)
import Core.Models.Software exposing (..)
import Core.Models.Server exposing (..)
import Core.Models.Network exposing (..)


type alias CoreModel =
    { account : AccountModel
    , server : ServerModel
    , network : NetworkModel
    , software : SoftwareModel
    }


initialModel : CoreModel
initialModel =
    { account = initialAccountModel
    , server = initialServerModel
    , network = initialNetworkModel
    , software = initialSoftwareModel
    }
