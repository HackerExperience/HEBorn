module Gen.Remote exposing (..)

import Dict
import Gen.Utils exposing (..)
import Gen.Software
import Game.Software.Models exposing (..)


getFiles : Int -> Filesystem
getFiles seedInt =
    let
        file =
            Gen.Software.file seedInt

        result =
            Dict.empty

        path =
            getFilePath file

        result_ =
            Dict.insert path ([ file ]) result

        f =
            Debug.log ">>" (toString result_)
    in
        result_
