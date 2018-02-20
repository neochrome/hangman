let ( <| ) = ( @@ )

module String = struct
  include String

  let as_chars s =
    let rec loop acc = function
      | 0 -> s.[0] :: acc
      | i -> loop (s.[i] :: acc) (i - 1)
    in loop [] (length s - 1)

  let from_chars ch =
    String.init (List.length ch) (List.nth ch)
end

module Char = struct
  include Char

  let to_string = String.make 1
end

module List = struct
  include List

  let contains x = exists (( = ) x)
  let except ys = filter (fun x -> not (contains x ys))
  let except_first x =
    let rec loop hs = function
      | [] -> hs
      | h :: xs when h = x -> xs |> List.rev_append hs
      | h :: xs -> loop (h :: hs) xs
    in loop []
end
