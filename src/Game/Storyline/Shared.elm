module Game.Storyline.Shared exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)


type alias ContactId =
    String


type alias PastEmails =
    Dict Time PastEmail


type PastEmail
    = FromContact Reply
    | FromPlayer Reply


type Reply
    = AboutThat
    | BackThanks
    | CleanYourLogs
    | DlaydMuch1
    | DlaydMuch2
    | DlaydMuch3
    | DlaydMuch4
    | DownloadCracker1 SomeIP
    | Downloaded
    | HellYeah
    | NastyVirus1
    | NastyVirus2
    | NastyVirus3
    | Noice
    | NothingNow
    | PointlessConvo1
    | PointlessConvo2
    | PointlessConvo3
    | PointlessConvo4
    | PointlessConvo5
    | Punks1
    | Punks2
    | Punks3 SomeIP
    | VirusSpotted1
    | VirusSpotted2
    | WatchIADoing
    | Welcome
    | YeahRight


type alias SomeIP =
    String


type Objective
    = DownloadCracker
    | VirusInquiry
    | CleanUp
    | Grandmadness


type Step
    = Tutorial_SetupPC
    | Tutorial_DownloadCracker
    | Tutorial_NastyVirus


type Quest
    = Tutorial
    | EndGame


type alias About =
    { nick : String
    , picture : String
    }


type alias Checkpoint =
    ( Int, Int, Int )


emailToReply : PastEmail -> Reply
emailToReply email =
    case email of
        FromContact reply ->
            reply

        FromPlayer reply ->
            reply


checkpointIsGTE : Checkpoint -> Checkpoint -> Bool
checkpointIsGTE l r =
    (l >= r)


checkpoint : Maybe Quest -> Maybe Step -> Maybe Reply -> Checkpoint
checkpoint q s r =
    let
        x =
            case q of
                Nothing ->
                    0

                Just Tutorial ->
                    1

                Just EndGame ->
                    2

        y =
            case s of
                Nothing ->
                    0

                Just Tutorial_SetupPC ->
                    1

                Just Tutorial_DownloadCracker ->
                    2

                Just Tutorial_NastyVirus ->
                    3

        z =
            case r of
                Nothing ->
                    0

                Just Welcome ->
                    1

                Just BackThanks ->
                    2

                Just WatchIADoing ->
                    3

                Just HellYeah ->
                    4

                Just (DownloadCracker1 _) ->
                    5

                Just AboutThat ->
                    6

                Just YeahRight ->
                    7

                Just Downloaded ->
                    8

                Just NothingNow ->
                    9

                Just NastyVirus1 ->
                    10

                Just NastyVirus2 ->
                    11

                Just Punks1 ->
                    12

                Just Punks2 ->
                    13

                Just (Punks3 _) ->
                    14

                Just DlaydMuch1 ->
                    15

                Just DlaydMuch2 ->
                    16

                Just DlaydMuch3 ->
                    17

                Just DlaydMuch4 ->
                    18

                Just Noice ->
                    19

                Just NastyVirus3 ->
                    20

                Just VirusSpotted1 ->
                    21

                Just VirusSpotted2 ->
                    22

                Just PointlessConvo1 ->
                    23

                Just PointlessConvo2 ->
                    24

                Just PointlessConvo3 ->
                    25

                Just PointlessConvo4 ->
                    26

                Just PointlessConvo5 ->
                    27

                Just CleanYourLogs ->
                    28
    in
        ( x, y, z )
