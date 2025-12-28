(* open Base *)
open Hardcaml

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
      (* _out2 : 'a; *)
    }
    [@@deriving hardcaml]
  end

  let _create _scope (i : 'a I.t) =
    let open Signal in
    let _out1_wire = i._in1 &: i._in2 in
    (* let _out2_wire = i._in1 |: i._in2 in *)
    {
      O._out1 = _out1_wire;
      (* O._out2 = _out2_wire; *)
    }

  let _create2 _scope (i: 'a I.t) =
    let open Signal in
    let _wire1 = Always.Variable.wire ~default:(Signal.zero 1) in
    Always.(compile [
      _wire1 <-- (i._in1 ^: i._in2);
    ]);
    (* Always.Variable.value _wire1 *)
    (* output "_wire1" _wire1.value *)
    {
      O._out1 = Always.Variable.value _wire1
    }
end

let () = 
  Stdio.print_endline "main";
  let open Signal in

  let t_in1 = input "in1" 1 in 
  let t_in2 = input "in2" 1 in
  let scope = Scope.create ~flatten_design:false in
  (* let circ_inst = Controller._create scope *)
  (*   { *)
  (*   _in1 = t_in1; *)
  (*   _in2 = t_in2; *)
  (*   } in *)

  let circ_inst = Controller._create2 scope
    {
    _in1 = t_in1;
    _in2 = t_in2;
    } in

  let t_out1 = output "q1" circ_inst._out1 in
  (* let t_out2 = output "q2" circ_inst._out2 in *)

  let printCirc = 
    Circuit.create_exn
    ~name:"dual_gate"
    (* [t_out1; t_out2] *)
    [t_out1;]
  in

  Rtl.print Verilog printCirc;
  ()
