/* The emulator fetch-execute-interrupt dispatch loop. */

val check_cycle_count = { c: "cycle_count" } : unit -> unit

/* returns whether to increment the step count in the trace */
function step(step_no : int) -> bool = {
  /* for step extensions */
  ext_pre_step_hook();

  minstret_written = false;     /* see note for minstret */
  let (retired, stepped) : (Retired, bool) =
    match dispatchInterrupt(cur_privilege) {
      Some(intr, priv) => {
        if   get_config_print_instr()
        then print_bits("Handling interrupt: ", interruptType_to_bits(intr));
        handle_interrupt(intr, priv);
        (RETIRE_FAIL, false)
      },
      None() => {
        /* the extension hook interposes on the fetch result */
        let f : FetchResult = ext_fetch_hook(fetch());
        match f {
          /* extension error */
          F_Ext_Error(e)   => {
            ext_handle_fetch_check_error(e);
            (RETIRE_FAIL, false)
          },
          /* standard error */
          F_Error(e, addr) => {
            handle_mem_exception(addr, e);
            (RETIRE_FAIL, false)
          },
          /* non-error cases: */
          F_RVC(h) => {
            if h == 0x0000 then {
              exit()
            };
            __instr_announce(h);
            let ast = decodeCompressed(h);
            if   get_config_print_instr()
            then {
              print_instr("[" ^ string_of_int(step_no) ^ "] [" ^ to_str(cur_privilege) ^ "]: " ^ BitStr(PC) ^ " (" ^ BitStr(h) ^ ") " ^ to_str(ast));
            };
            /* check for RVC once here instead of every RVC execute clause. */
            if haveRVC() then {
              nextPC = PC + 2;
              (execute(ext_post_decode_hook(ast)), true)
             } else {
              handle_illegal();
              (RETIRE_FAIL, true)
             }
          },
          F_Base(w) => {
            __instr_announce(w);
            let ast = decode(w);
            if   get_config_print_instr()
            then {
              print_instr("[" ^ string_of_int(step_no) ^ "] [" ^ to_str(cur_privilege) ^ "]: " ^ BitStr(PC) ^ " (" ^ BitStr(w) ^ ") " ^ to_str(ast));
            };
            nextPC = PC + 4;
            (execute(ext_post_decode_hook(ast)), true)
          }
        }
      }
    };

  tick_pc();

  /* update minstret */
  match retired {
    RETIRE_SUCCESS => retire_instruction(),
    RETIRE_FAIL    => ()
  };

  /* for step extensions */
  ext_post_step_hook();

  check_cycle_count();

  stepped
}

function loop () : unit -> unit = {
  let insns_per_tick = plat_insns_per_tick();
  i : int = 0;
  step_no : int = 0;
  while (~ (htif_done)) do {
    let stepped = step(step_no);
    if stepped then step_no = step_no + 1;

    /* check htif exit */
    if htif_done then {
      let exit_val = unsigned(htif_exit_code);
      if exit_val == 0 then print("SUCCESS")
      else print_int("FAILURE: ", exit_val);
    } else {
      /* update time */
      i = i + 1;
      if i == insns_per_tick then {
        tick_clock();
        /* for now, we drive the platform i/o at every clock tick. */
        tick_platform();
        i = 0;
      }
    }
  }
}

/* initialize model state */
function init_model () -> unit = {
  init_platform (); /* devices */
  init_sys ();      /* processor */
  init_vmem ();     /* virtual memory */

  /* initialize extensions last */
  ext_init ();
  ext_init_regs ();
}
