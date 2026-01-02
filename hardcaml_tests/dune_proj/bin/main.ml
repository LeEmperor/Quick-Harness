open Base
open Hardcaml
open Signal


(* let write_rtl_to_file *)
(*     ~(name : string) *)
(*     ~(filename : string) *)
(*     (circuit : Circuit.t) *)
(*   = *)
(*   let rtl = *)
(*     Rtl.Verilog.to_string *)
(*       (Rtl.Verilog.Config.default ()) *)
(*       circuit *)
(*   in *)
(*   (* print to stdout *) *)
(*   print_endline rtl; *)
(**)
(*   (* write to file *) *)
(*   let oc = Out_channel.open_text filename in *)
(*   Out_channel.output_string oc rtl; *)
(*   Out_channel.close oc *)


module Controller = struct
  module I = struct
    type 'a t = {
      (* _in1 : 'a; *)
      (* _in2 : 'a; *)
      _clk  : 'a;
      _rst  : 'a;
      _go   : 'a;
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

  module States = struct
    type t = IDLE | COMPUTE | DONE
      [@@deriving sexp, compare, enumerate]
  end

  (* let _create _scope (i : 'a I.t) = *)
  (*   let open Signal in *)
  (*   let _out1_wire = i._in1 &: i._in2 in *)
  (*   (* let _out2_wire = i._in1 |: i._in2 in *) *)
  (*   { *)
  (*     O._out1 = _out1_wire; *)
  (*     (* O._out2 = _out2_wire; *) *)
  (*   } *)
  (**)
  (* let _create2 _scope (i: 'a I.t) = *)
  (*   let _wire1 = Always.Variable.wire ~default:(Signal.zero 1) in *)
  (*   Always.(compile [ *)
  (*     _wire1 <-- (i._in1 ^: i._in2); *)
  (*   ]); *)
  (*   (* Always.Variable.value _wire1 *) *)
  (*   (* output "_wire1" _wire1.value *) *)
  (*   { *)
  (*     O._out1 = Always.Variable.value _wire1 *)
  (*   } *)

  let _create3 (_scope: Scope.t) (i: 'a I.t) : ('a O.t) =
    let reg_spec = Reg_spec.create 
      ~clock:i._clk 
      ~clear:i._rst 
    () in

    let _fsm =
      Always.State_machine.create 
      (module States) 
      ~enable:vdd
      reg_spec
    in

    let done_ = Always.Variable.wire ~default:gnd in
    Always.(compile [
      _fsm.switch [
        IDLE, [
          when_ i._go [
            _fsm.set_next COMPUTE;
          ]
        ];

        COMPUTE, [
          _fsm.set_next DONE;
        ];

        DONE, [
          done_ <-- (Signal.one 1);
          _fsm.set_next IDLE;
        ]
      ]
    ]);

    {
      (* O._out1 = Signal.zero 1 *)
      O._out1 = Always.Variable.value done_
    }
end

let () = 
  (* Stdio.print_endline "main"; *)

  (* let circ_inst = Controller._create scope *)
  (*   { *)
  (*   _in1 = t_in1; *)
  (*   _in2 = t_in2; *)
  (*   } in *)

  (* let circ_inst = Controller._create2 scope *)
  (*   { *)
  (*   _in1 = t_in1; *)
  (*   _in2 = t_in2; *)
  (*   } in *)
  (**)
  (* let t_out1 = output "q1" circ_inst._out1 in *)
  (* (* let t_out2 = output "q2" circ_inst._out2 in *) *)
  (**)
  (* let printCirc =  *)
  (*   Circuit.create_exn *)
  (*   ~name:"dual_gate" *)
  (*   (* [t_out1; t_out2] *) *)
  (*   [t_out1;] *)
  (* in *)
  (**)
  (* Rtl.print Verilog printCirc; *)

  (* let t_in1 = input "in1" 1 in  *)
  (* let t_in2 = input "in2" 1 in *)

  let scope = Scope.create ~flatten_design:false () in
  let t_clk = input "clk" 1 in
  let t_rst = input "rst" 1 in
  let t_go  = input "go"  1 in
  let circ_inst = Controller._create3 
    scope
    {
      _clk = t_clk;
      _rst = t_rst;
      _go = t_go
    } in
  let t_done = output "done" circ_inst._out1 in
  let printCirc = 
    Circuit.create_exn
    ~name:"fsm_test"
    [t_done;]
  in
  (* Rtl.print Verilog printCirc; *)
  Rtl.print Verilog printCirc;

  ()
