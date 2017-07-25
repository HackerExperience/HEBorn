module Apps.Browser.Pages.Models
    exposing
        ( Model(..)
        , initialModel
        , getSite
        , getTitle
        )

import Game.Web.Types as Web
import Apps.Browser.Pages.NotFound.Models as PageNotFound
import Apps.Browser.Pages.Default.Models as PageDefault
import Apps.Browser.Pages.Profile.Models as PageProfile
import Apps.Browser.Pages.Directory.Models as PageDirectory
import Apps.Browser.Pages.MissionCenter.Models as PageMissionCenter
import Apps.Browser.Pages.DownloadCenter.Models as PageDownloadCenter
import Apps.Browser.Pages.ISP.Models as PageISP
import Apps.Browser.Pages.FBI.Models as PageFBI
import Apps.Browser.Pages.News.Models as PageNews


type Model
    = BlankModel
    | NotFoundModel PageNotFound.Model
    | UnknownModel
    | HomeModel
    | CustomModel
    | DefaultModel PageDefault.Model
    | ProfileModel
    | DirectoryModel
    | DownloadCenterModel
    | ISPModel
    | BankModel
    | StoreModel
    | BTCModel
    | FBIModel
    | NewsModel
    | BithubModel
    | MissionCenterModel


type alias Meta =
    { url : String, title : String }


initialModel : Web.Site -> Model
initialModel ({ type_, meta } as site) =
    case ( type_, meta ) of
        ( Web.Blank, _ ) ->
            BlankModel

        ( Web.Home, _ ) ->
            HomeModel

        ( Web.Unknown, _ ) ->
            UnknownModel

        ( Web.NotFound, _ ) ->
            site
                |> PageNotFound.initialModel
                |> NotFoundModel

        ( Web.Default, Just (Web.DefaultMeta meta) ) ->
            site
                |> PageDefault.initialModel
                |> DefaultModel

        ( Web.Profile, _ ) ->
            ProfileModel

        ( Web.Directory, _ ) ->
            DirectoryModel

        ( Web.MissionCenter, _ ) ->
            MissionCenterModel

        ( Web.DownloadCenter, _ ) ->
            DownloadCenterModel

        ( Web.ISP, _ ) ->
            ISPModel

        ( Web.FBI, _ ) ->
            FBIModel

        ( Web.News, _ ) ->
            NewsModel

        _ ->
            UnknownModel


getTitle : Model -> String
getTitle model =
    case model of
        NotFoundModel model ->
            PageNotFound.getTitle model

        UnknownModel ->
            "Loading..."

        HomeModel ->
            "Home"

        ProfileModel ->
            PageProfile.getTitle

        DirectoryModel ->
            PageDirectory.getTitle

        MissionCenterModel ->
            PageMissionCenter.getTitle

        DownloadCenterModel ->
            PageDownloadCenter.getTitle

        ISPModel ->
            PageISP.getTitle

        FBIModel ->
            PageFBI.getTitle

        NewsModel ->
            PageNews.getTitle

        _ ->
            "New Tab"


getSite : Model -> ( Web.Type, Maybe Web.Meta )
getSite model =
    case model of
        NotFoundModel model ->
            PageNotFound.getSite model

        BlankModel ->
            ( Web.Blank, Nothing )

        HomeModel ->
            ( Web.Home, Nothing )

        ProfileModel ->
            PageProfile.getSite

        DirectoryModel ->
            PageDirectory.getSite

        MissionCenterModel ->
            PageMissionCenter.getSite

        DownloadCenterModel ->
            PageDownloadCenter.getSite

        ISPModel ->
            PageISP.getSite

        FBIModel ->
            PageFBI.getSite

        NewsModel ->
            PageNews.getSite

        _ ->
            ( Web.Unknown, Nothing )
