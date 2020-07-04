port module Main exposing (Api, Author, Content, Model, Msg(..), Page(..), Quote, Uid, Url, api, askForUniqueId, authorDecoder, contentDecoder, defaultQuote, getRandomQuote, init, initialModel, main, quoteDecoder, subscriptions, uniqueId, update, view, viewAuthor, viewContent)

import Browser
import Html exposing (Html, blockquote, button, div, footer, h1, span, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



---- MODEL ----


type alias Author =
    String


type alias Content =
    String


type alias Quote =
    { content : Content
    , author : Author
    }


type Page
    = Failure
    | Loading Quote
    | Success Quote


type alias Url =
    String


type alias Uid =
    String


type alias Api =
    { url : Url
    , uid : Uid
    }


type alias Model =
    { api : Api
    , page : Page
    }


defaultQuote : Quote
defaultQuote =
    Quote
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante."
        "Someone famous"


api : Api
api =
    Api
        "https://api.quotable.io/random"
        ""


initialModel : Model
initialModel =
    Model api (Loading defaultQuote)


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, askForUniqueId () )



---- UPDATE ----


type Msg
    = GotQuote (Result Http.Error Quote)
    | LoadNextQuote
    | GotUniqueId String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUniqueId uid ->
            let
                newApi =
                    Api model.api.url uid

                updatedModel =
                    { model | api = newApi }
            in
            ( updatedModel, getRandomQuote updatedModel )

        LoadNextQuote ->
            ( model, askForUniqueId () )

        GotQuote result ->
            case result of
                Ok quote ->
                    let
                        page =
                            Success quote
                    in
                    ( { model | page = page }, Cmd.none )

                Err _ ->
                    ( { model | page = Failure }, Cmd.none )



-- PORTS


port uniqueId : (String -> msg) -> Sub msg


port askForUniqueId : () -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    uniqueId GotUniqueId



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row mx-lg-3 mt-md-5 mt-sm-3 mt-1" ]
            [ div [ class "col-sm-7 text-sm-left text-center" ]
                [ h1 [ class "text-success" ]
                    [ span [ class "font-khula" ]
                        [ text "Random " ]
                    , span [ class "font-heebo" ]
                        [ text "Quotes" ]
                    ]
                ]
            , div [ class "col-sm-5 text-sm-right text-center" ]
                [ button [ onClick LoadNextQuote, class "btn btn-outline-success font-heebo font-weight-bold" ]
                    [ span [ class "d-none d-md-inline" ]
                        [ text "Get another " ]
                    , span [ class "d-md-none" ]
                        [ text "Refresh " ]
                    , span [ class "d-none d-md-inline" ]
                        [ text "awesome " ]
                    , text "quote"
                    ]
                ]
            ]
        , div [ class "row mt-md-5 mt-2" ]
            [ div [ class "col-md-2 text-center text-md-right" ]
                [ span [ class "text-success d-none d-lg-inline", id "big-quotation-mark" ]
                    [ text "“" ]
                ]
            , div [ class "col-md" ]
                [ blockquote [ class "blockquote" ]
                    [ div [ class "mb-5 text-center text-md-left", id "quote-content" ]
                        [ viewContent model ]
                    , footer [ class "blockquote-footer text-right" ]
                        [ span []
                            [ viewAuthor model ]
                        ]
                    ]
                ]
            , div [ class "col-md-2 text-center text-md-left" ]
                [ div [ id "tweet-container" ]
                    []
                ]
            ]
        ]


viewContent : Model -> Html Msg
viewContent model =
    case model.page of
        Failure ->
            text "(Failed fetching data!)"

        Loading quote ->
            text quote.content

        Success quote ->
            text quote.content


viewAuthor : Model -> Html Msg
viewAuthor model =
    case model.page of
        Failure ->
            text "Someone famous"

        Loading quote ->
            text <| " " ++ quote.author

        Success quote ->
            text <| " " ++ quote.author



-- HTTP


getRandomQuote : Model -> Cmd Msg
getRandomQuote model =
    -- I know I need to store these keys privately for example in a .env
    -- But for this quick demo, I think it's fine.
    Http.request
        { method = "GET"
        , headers = []
        , url = model.api.url ++ "?" ++ model.api.uid
        , body = Http.emptyBody
        , expect = Http.expectJson GotQuote quoteDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


quoteDecoder : D.Decoder Quote
quoteDecoder =
    D.map2 Quote
        contentDecoder
        authorDecoder


authorDecoder : D.Decoder Author
authorDecoder =
    D.field "author" D.string


contentDecoder : D.Decoder Content
contentDecoder =
    D.field "content" D.string
