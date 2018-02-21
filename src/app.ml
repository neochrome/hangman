open Tea
open Tea.App
open Tea.Html
open Lib
module D = Json.Decoder

let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.as_chars
let max_bad_guesses = 6

type difficulty =
  | Easy
  | Hard

type game_result = Won | Lost

type state =
  | Start
  | Guessing
  | GameOver of game_result

type msg =
  | Guess of char
  | FetchWordError of string
  | FetchWordDone of string
  | FetchWord of difficulty

module CharSet = Set.Make(Char)
let mem_of s c = CharSet.mem c s

type model = {
  state : state;
  word_letters : char list;
  guesses : CharSet.t;
  error : string option;
}

let init () =
  {
    state = Start;
    word_letters = [];
    guesses = CharSet.empty;
    error = None;
  }, Cmd.none


let won { word_letters; guesses; } =
  word_letters |> List.for_all (mem_of guesses)

let bad_guesses { word_letters; guesses; } =
  guesses
  |> CharSet.diff <| CharSet.of_list word_letters
  |> CharSet.cardinal

let lost model = model |> bad_guesses = max_bad_guesses


let start_guessing word model =
  let word_letters =
    String.uppercase word
    |> String.as_chars
  in
  { model with
    state = Guessing;
    word_letters;
    guesses = CharSet.empty;
  }

let url_from difficulty =
  let base = "//api.wordnik.com/v4/words.json/randomWord" in
  let api_key = "api_key=9ff1e949883740308250307233602ff096c416b5bccb12451" in
  let options =
    api_key ::
    match difficulty with
    | Easy -> [
        "hasDictionaryDef=true";
        "minDictionaryCount=10";
        "minLength=4";
        "maxLength=7";
      ]
    | Hard -> [
        "hasDictionaryDef=false";
        "minDictionaryCount=1";
        "minLength=3";
        "maxLength=-1";
      ]
  in
  base ^ "?" ^ (String.concat "&" options)

let decode = D.field "word" D.string

let fetch_word difficulty =
  url_from difficulty
  |> Http.getString
  |> Http.send (function
    | Result.Error err ->
      FetchWordError (Http.string_of_error err)
    | Result.Ok result ->
      begin match result |> D.decodeString decode with
      | Result.Ok word -> FetchWordDone word
      | Result.Error err -> FetchWordError err
      end
  )


let guess g model =
  let guesses = CharSet.add g model.guesses in
  { model with guesses; }

let check_end_of_game model =
  if lost model then
    { model with state = GameOver Lost }
  else if won model then
    { model with state = GameOver Won }
  else
    model

let update model = function
  | Guess g ->
    (if model.state = Guessing
    then model |> guess g |> check_end_of_game
    else model), Cmd.none
  | FetchWord difficulty -> model, fetch_word difficulty
  | FetchWordDone word -> { model with error = None } |> start_guessing word, Cmd.none
  | FetchWordError error -> { model with error = Some error }, Cmd.none


let view_difficulty_choice () =
  div [class' "choose-difficulty"] [
    button [class' "easy"; onClick (FetchWord Easy)] [text "go easy"];
    button [class' "hard"; onClick (FetchWord Hard)] [text "bring it on!"];
  ]

let view_error { error } =
  match error with
  | None -> noNode
  | Some err -> div [class' "error"] [text err]

let view_start model =
  div [class' "start"] [
    text "Try not to be hanged!";
    view_difficulty_choice ();
    Gfx.draw 300 300 0;
    view_error model;
  ]

let view_letter_button { guesses; } l =
  button [
    class' "letter";
    onClick (Guess l);
    Attributes.disabled (l |> mem_of guesses);
  ] [Char.to_string l |> text]


let view_word { word_letters; guesses; } =
  div [class' "word"] (
    word_letters
    |> List.map (fun l -> [(if l |> mem_of guesses then Char.to_string l else "") |> text])
    |> List.map (span [class' "letter"])
  )

let view_guessing model =
  div [] [
    view_word model;
    div [] (letters |> List.map (view_letter_button model));
    model |> bad_guesses |> Gfx.draw 300 300;
    view_error model;
  ]

let view_game_over model result =
  div [] [
    view_guessing model;
    match result with
    | Won -> div [class' "game-over won"] [
        text "winner!";
        view_difficulty_choice ();
      ]
    | Lost -> div [class' "game-over lost"] [
        text "loser!";
        span [class' "word"] [
          model.word_letters
          |> String.from_chars
          |> ( ^ ) "the word was: "
          |> text

        ];
        view_difficulty_choice ();
      ]
  ]

let view model =
  div [] [
    match model.state with
    | Start -> view_start model
    | Guessing -> view_guessing model
    | GameOver result -> view_game_over model result
  ]


let subscriptions _ =
  Sub.none

let main =
  standardProgram {
    init;
    subscriptions;
    update;
    view;
  }
