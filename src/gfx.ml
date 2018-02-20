open Tea
open Tea.Svg.Attributes

let draw w h bad_guesses =
  let bad n part = if bad_guesses > n then part else Svg.noNode in
  Svg.svg [
    viewBox "0 0 300 300";
    width (string_of_int w);
    height (string_of_int h);
    strokeWidth "6";
    strokeLinecap "round";
    fill "none";
  ] [
    Svg.g [stroke "black"] [
      Svg.line [x1 "150"; y1 "250"; x2 "150"; y2 "20"] [];
      Svg.line [x1 "130"; y1 "20"; x2 "250"; y2 "20"] [];
      Svg.line [x1 "150"; y1 "60"; x2 "180"; y2 "20"] [];
      Svg.line [x1 "240"; y1 "20"; x2 "240"; y2 "60"; strokeWidth "4"] [];
      ];
    Svg.path [d "M 0 300 q 150 -100 300 0"; stroke "green"] [];
    Svg.g [stroke "black"; strokeWidth "5"] [
      bad 0 (Svg.circle [id "head"; cx "240"; cy "80"; r "20"] []);
      bad 1 (Svg.line [x1 "240"; y1 "100"; x2 "240"; y2 "155"] []);
      bad 2 (Svg.line [x1 "240"; y1 "115"; x2 "205"; y2 "125"] []);
      bad 3 (Svg.line [x1 "240"; y1 "115"; x2 "275"; y2 "125"] []);
      bad 4 (Svg.line [x1 "240"; y1 "155"; x2 "210"; y2 "190"] []);
      bad 5 (Svg.line [x1 "240"; y1 "155"; x2 "270"; y2 "190"] []);
    ]
  ]
