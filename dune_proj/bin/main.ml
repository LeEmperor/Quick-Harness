(* open Unix *)

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


let _writeTCL () : (unit, string) result =
  let oc = open_out "createProj.tcl" in
  output_string oc _baseTCLFile;
  close_out oc;
  Ok ()

let _main =
  print_endline "started!";

  (* let* () = _ensureDir () in *)
  let* () = _writeTCL () in
  (* let* () = _buildProj () in *)
  Ok ()

