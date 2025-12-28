open Hardcaml
open Signal

module Controller = struct
  module I = struct
    type 'a t = {
      _in1 : 'a;
      _in2 : 'a;
    }
    [@@deriving hardcaml]
  end

  module O = struct
    type 'a t = {
      _out1 : 'a;
    }
    [@@deriving hardcaml]
  end

  let _create _scope (i : 'a I.t) =
    let _out1_wire = i._in1 &: i._in2 in
    {
      O._out1 = _out1_wire;
    }

end

let () = 
  print_endline "main";

  let t_in1 = input "in1" 1 in 
  let t_in2 = input "in2" 1 in
  let scope = Scope.create ~flatten_design:false in
  let circ_inst = Circuit.create_exn
    ~name:"top"
    scope
    in
  (* Rtl.print Verilog circuit; *)
  ()
