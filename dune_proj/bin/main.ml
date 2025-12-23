Open Unix

let ( let* ) = Result.bind

let ok () = Ok ()

(*
  plan: 
    ensure a dir exists
    rm rf dir
    make new dir
    write tcl file
    run vivado script
 *)

(*
  vivado must:
    set proj dir
    set proj device
    set proj name
    set proj toplevel
    set proj language

    add relevant files


    do we host the harness in a local directory or do we host them in the area with all the source files?
 *)

let _ensureDir () : (unit, string) result =
  let home =
    try Sys.getenv "HOME"
    with Not_found -> "/tmp"
  in
  let base_dir = Filename.concat home ".harn" in
  let target = Filename.concat base_dir "current" in

  let rec rm_rf path =
    if Sys.is_directory path then begin
      Sys.readdir path
      |> Array.iter (fun name ->
           rm_rf (Filename.concat path name));
      Unix.rmdir path
    end else
      Sys.remove path
  in

  try
    (* Ensure ~/.harn exists *)
    if not (Sys.file_exists base_dir) then
      Unix.mkdir base_dir 0o755;

    (* Reset ~/.harn/current *)
    if Sys.file_exists target then
      rm_rf target;

    Unix.mkdir target 0o755;
    Ok ()
  with
  | Sys_error msg
  | Unix_error (_, msg, _) ->
      Error msg
 Ok ()

let _writeFile path contents : (unit, string) result =
  try
    let oc = open_out_bin path in
    output_string oc contents;
    close_out oc;
    Ok ()
  with
  | Sys_error msg -> Error msg

let _parseArgs _args : (unit, string) result =
  Ok ()

let main =
  print_endline "started!";

  let* () = _ensureDir in
  Ok ()

