port module Main exposing (Api, Author, Content, Model, Msg(..), Page(..), Quote, Source, Uid, Url, api, askForUniqueId, authorDecoder, contentDecoder, defaultQuote, getRandomQuote, init, initialModel, main, quoteDecoder, quotesDecoder, sourceDecoder, subscriptions, uniqueId, update, view, viewAuthor, viewQuote, viewSource)

import Browser
import Html exposing (Html, blockquote, button, cite, div, footer, h1, span, text)
import Html.Attributes exposing (class, id, title)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D



---- PROGRAM ----


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


type alias Source =
    Maybe String


type alias Quote =
    { content : Content
    , author : Author
    , source : Source
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


defaultQuote =
    Quote
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante."
        "Someone famous"
        Nothing


api =
    Api
        "https://quotesondesign.com/wp-json/posts?filter[orderby]=rand&filter[posts_per_page]=1"
        ""


initialModel =
    Model api (Loading defaultQuote)


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, getRandomQuote initialModel )



---- UPDATE ----


type Msg
    = GotQuotes (Result Http.Error (List Quote))
    | LoadNextQuote
    | GotUniqueId String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotUniqueId uid ->
            let
                _ =
                    Debug.log "uid in Elm" uid
            in
            ( initialModel, Cmd.none )

        LoadNextQuote ->
            ( initialModel, getRandomQuote model )

        GotQuotes result ->
            case result of
                Ok quotes ->
                    let
                        firstQuote =
                            List.head quotes |> Maybe.withDefault defaultQuote

                        page =
                            Success firstQuote
                    in
                    ( { model | page = page }, Cmd.none )

                Err _ ->
                    ( { model | page = Failure }, Cmd.none )



-- PORTS


port uniqueId : (String -> msg) -> Sub msg


port askForUniqueId : () -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
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
                        [ viewQuote model ]
                    , footer [ class "blockquote-footer text-right" ]
                        [ span []
                            [ viewAuthor model ]
                        , cite [ title "Source Title" ]
                            [ viewSource model ]
                        ]
                    ]
                ]
            , div [ class "col-md-2 text-center text-md-left" ]
                [ div [ id "tweet-container" ]
                    []
                ]
            ]
        ]


viewQuote : Model -> Html Msg
viewQuote model =
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


viewSource : Model -> Html Msg
viewSource model =
    case model.page of
        Failure ->
            text ""

        Loading quote ->
            case quote.source of
                Just source ->
                    text <| " (" ++ source ++ ")"

                Nothing ->
                    text ""

        Success quote ->
            case quote.source of
                Just source ->
                    text <| " (" ++ source ++ ")"

                Nothing ->
                    text ""



-- HTTP


getRandomQuote : Model -> Cmd Msg
getRandomQuote model =
    Http.get
        { url = model.api.url
        , expect = Http.expectJson GotQuotes quotesDecoder
        }


quotesDecoder : D.Decoder (List Quote)
quotesDecoder =
    D.list quoteDecoder


quoteDecoder : D.Decoder Quote
quoteDecoder =
    D.map3 Quote
        contentDecoder
        authorDecoder
        sourceDecoder


authorDecoder : D.Decoder Author
authorDecoder =
    D.field "title" D.string


contentDecoder : D.Decoder Content
contentDecoder =
    D.field "content" D.string


sourceDecoder : D.Decoder Source
sourceDecoder =
    D.maybe (D.field "custom_meta" (D.field "Source" D.string))
