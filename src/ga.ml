module FFI = struct
  type event_params = <
    event_category : string;
    event_label : string;
  > Js.t

  type view_params = <
    page_title : string;
    page_path : string;
  > Js.t

  type exception_params = <
    description: string;
  > Js.t

  external gtag :
    string
    -> string
    -> ([ `Event of event_params
        | `View of view_params
        | `Exception of exception_params
       ] [@bs.unwrap])
    -> unit
    = "" [@@bs.val]
end

let track_event event_category action event_label =
  FFI.gtag "event" action (`Event [%bs.obj { event_category; event_label; }])

let track_view name =
  FFI.gtag "event" "page_view" (`View [%bs.obj { page_title = name; page_path = name; }])

let track_exception description =
  FFI.gtag "event" "exception" (`Exception [%bs.obj { description; }])

