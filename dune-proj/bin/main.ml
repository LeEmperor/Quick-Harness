(* open Core *)

(*
  func: "run"
  args: 
    "cmd": string - bash command meant to run
  desc: run a command on bash, give the error if it pends
 *)
let _runRawCommand (
  cmd:string
  ) =
  let code = Sys.command cmd in
  match code with 
  | 0 -> Ok ()
  | n -> Error (Printf.sprintf "command failed with exit code %d" n)

(* main *)
let () = 
  let in_string: string = read_line () in
  (* match runRawCommand "vivado -mode batch -source setup.tcl" with *)
  (* Printf.printf "thing entered: %s" in_string; *)
  let _defaultBoard = "xcu50-fsvh2104-2-e" in
  let _vivadoDir = "tools/Xilinx/Vivado/2021.2/settings64.sh" in
  match _runRawCommand in_string with
  | Ok () -> print_endline "Vivado run completed"
  | Error e -> prerr_endline e


