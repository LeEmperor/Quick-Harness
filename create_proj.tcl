# scripts/create_proj.tcl

# Read arguments
if { $argc < 4 } {
    puts "Usage: vivado -mode batch -source create_proj.tcl -tclargs <proj_name> <proj_dir> <part_or_board> <top>"
    exit 1
}

set proj_name      [lindex $argv 0]
set proj_dir       [file normalize [lindex $argv 1]]
set part_or_board  [lindex $argv 2]
set top_name       [lindex $argv 3]

puts "=== Creating project ==="
puts "  Name : $proj_name"
puts "  Dir  : $proj_dir"
puts "  Part/Board: $part_or_board"
puts "  Top  : $top_name"

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
puts "=== Project created at: $proj_dir ==="
exit
