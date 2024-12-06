
function automatic bit sys_enable_svinval(sail_unit u);
   return 1'h0;
endfunction

function automatic bit sys_enable_writable_misa(sail_unit u);
   return 1'h0;
endfunction

function automatic bit sys_enable_writable_fiom(sail_unit u);
   return 1'h0;
endfunction

function automatic bit sys_enable_rvc(sail_unit u);
   return 1'h0;
endfunction

function automatic bit sys_enable_bext(sail_unit u);
   return 1'h0;
endfunction

function automatic bit sys_enable_vext(sail_unit u);
   return 1'h0;
endfunction

function automatic bit sys_enable_zfinx(sail_unit u);
   return 1'h0;
endfunction

function automatic bit sys_enable_fdext(sail_unit u);
   return 1'h0;
endfunction

function automatic bit sys_enable_next(sail_unit u);
   return 1'h0;
endfunction

function automatic logic [63:0] sys_pmp_count(sail_unit u);
   return 64'h0;
endfunction

function automatic logic [31:0] plat_ram_base(sail_unit u);
   return 32'h80000000;
endfunction

function automatic logic [31:0] plat_ram_size(sail_unit u);
   return 32'h4000000;
endfunction

function automatic logic [31:0] plat_rom_base(sail_unit u);
   return 32'h1000;
endfunction

function automatic logic [31:0] plat_rom_size(sail_unit u);
   return 32'h100;
endfunction

function automatic logic [31:0] plat_clint_base(sail_unit u);
   return 32'h0;
endfunction

function automatic logic [31:0] plat_clint_size(sail_unit u);
   return 32'h0;
endfunction

function automatic bit plat_enable_misaligned_access(sail_unit u);
   return 1'h0;
endfunction

function automatic bit plat_enable_dirty_update(sail_unit u);
   return 1'h0;
endfunction

function automatic bit plat_mtval_has_illegal_inst_bits(sail_unit u);
   return 1'h0;
endfunction

function automatic logic [31:0] plat_htif_tohost(sail_unit u);
   return 32'h80001000;
endfunction

function automatic bit speculate_conditional(sail_unit u);
   return 1'h0;
endfunction

function automatic bit match_reservation(logic [31:0] addr);
   return 1'h0;
endfunction

function automatic [15:0] plat_get_16_random_bits(sail_unit u);
   return 16'h0;
endfunction
