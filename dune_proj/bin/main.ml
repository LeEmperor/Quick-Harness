open Unix

let ( let* ) = Result.bind

(* let ok () = Ok () *)

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

let _baseCommand: string = 
  "
    vivado -mode batch -source ./createProj.tcl 
    \"rtl_harn\"
    \".\"
    \"xcu50-fsvh2104-2-e\"
    \"top\"
  "

let _baseTCLFile: string = 
("# createProj.tcl

if { $argc < 5 } {
    puts \"Usage: vivado -mode batch -source create_proj.tcl -tclargs <proj_name> <proj_dir> <part_or_board> <top> <silent>\"
    exit 1
}

set proj_name      [lindex $argv 0]
set proj_dir       [file normalize [lindex $argv 1]]
set part_or_board  [lindex $argv 2]
set top_name       [lindex $argv 3]
set silent         [lindex $argv 4]

if (!silent) {
puts \"=== Creating project ===\"
puts \"  Name : $proj_name\"
puts \"  Dir  : $proj_dir\"
puts \"  Part/Board: $part_or_board\"
puts \"  Top  : $top_name\"
}

file mkdir $proj_dir

create_project $proj_name $proj_dir -part $part_or_board -force

# Optional: set language and standard
set_property target_language Verilog [current_project]
# For SystemVerilog, Vivado auto-detects by extension, but you can enforce:
set_property verilog_define {SYNTHESIS} [current_fileset]

set_property top $top_name [current_fileset]

# Save project
save_project_as [file join $proj_dir $proj_name].xpr
# save_project
puts \"=== Vivado Project Created at: $proj_dir ===\"
exit
")

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


let _writeTCL () : (unit, string) result =
  let home =
    try Sys.getenv "HOME"
    with Not_found -> "/tmp"
  in
  let out_path =
    Filename.concat
      (Filename.concat (Filename.concat home ".harn") "current")
      "createProj.tcl"
  in

  let ( let* ) = Result.bind in

  let* () = _ensureDir () in
  try
    let oc = open_out_bin out_path in
    Fun.protect
      ~finally:(fun () -> close_out_noerr oc)
      (fun () ->
        output_string oc _baseTCLFile;
        flush oc);
    Ok ()
  with
  | Sys_error msg -> Error msg

let _buildProj () : (unit, string) result =
  let home =
    try Sys.getenv "HOME"
    with Not_found -> "/tmp"
  in
  let workdir = Filename.concat (Filename.concat home ".harn") "current" in

  let ( let* ) = Result.bind in
  let* () = _ensureDir () in

  (* Run through a shell so multiline / pipes / 'source' work.
     -l: login shell (optional)
     -c: run command string
  *)
  let argv = [| "/bin/sh"; "-lc"; _baseCommand |] in

  (* Optional: capture stdout/stderr by redirecting to a log file *)
  let log_path = Filename.concat workdir "build.log" in

  try
    (* open log file for both stdout and stderr *)
    let log_fd =
      Unix.openfile log_path [O_CREAT; O_WRONLY; O_TRUNC] 0o644
    in
    Fun.protect
      ~finally:(fun () -> Unix.close log_fd)
      (fun () ->
        (* Save current cwd, run in workdir, restore *)
        let old_cwd = Unix.getcwd () in
        Fun.protect
          ~finally:(fun () -> Unix.chdir old_cwd)
          (fun () ->
            Unix.chdir workdir;

            let pid = Unix.create_process argv.(0) argv stdin log_fd log_fd in
            let (_, status) = Unix.waitpid [] pid in

            match status with
            | WEXITED 0 -> Ok ()
            | WEXITED code ->
                Error (Printf.sprintf "build command failed (exit %d). See %s" code log_path)
            | WSIGNALED s ->
                Error (Printf.sprintf "build command killed by signal %d. See %s" s log_path)
            | WSTOPPED s ->
                Error (Printf.sprintf "build command stopped by signal %d. See %s" s log_path)
          )
      )
  with
  | Sys_error msg -> Error msg
  | Unix_error (e, fn, arg) ->
      Error (Printf.sprintf "Unix error in %s(%s): %s" fn arg (Unix.error_message e))

let _main =
  print_endline "started!";

  let* () = _ensureDir () in
  let* () = _writeTCL () in
  let* () = _buildProj () in
  Ok ()

