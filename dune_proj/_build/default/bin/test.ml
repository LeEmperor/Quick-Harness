open Unix
(* open Core *)

let ( let* ) = Result.bind

let _runCommand 
  ~(prog: string) 
  ~(args: string list) 
  : (unit, string) result =

    match fork () with
    | 0 -> let argv = Array.of_list (prog :: args) in
    execvp prog argv
    | pid -> 
        let _, status = waitpid [] pid in
        match status with
        | WEXITED 0 -> Ok ()
        | _ -> Error "return status error from child process" 

let _main =
  (* let* () = _runCommand ~prog:"echo" ~args:["bruh"] in *)
  let* () = _runCommand ~prog:"pwd" ~args:[""] in
  Ok ()

(* let _test () : (unit, string) result = *)
(*   print_endline "test func run"; *)
(*   Ok () *)

(* let _main = *)
(*   let* () = _test () in *)
(*   Ok () *)
