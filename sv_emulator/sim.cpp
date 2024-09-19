#include <iostream>

#include "Vsail_toplevel.h"
#include "Vsail_toplevel__Dpi.h"
#include "verilated.h"

#include "sail.h"
#include "rts.h"

#define SAIL_ARG_DELIM "--"

void (*sail_rts_set_coverage_file)(const char *) = NULL;

extern "C" void model_pre_exit() { return; };

svBitVecVal sail_read_byte(const svLogicVecVal* sv_addr)
{
  uint64_t addr = UINT64_C(0);
  addr |= sv_addr[1].aval;
  addr <<= 32;
  addr |= sv_addr[0].aval;

  return (uint32_t) read_mem(addr);
}

svBit sail_read_tag(const svLogicVecVal* sv_addr)
{
  uint64_t addr = UINT64_C(0);
  addr |= sv_addr[1].aval;
  addr <<= 32;
  addr |= sv_addr[0].aval;

  return 0;
}

#define DEFAULT_RSTVEC 0x00001000

bool is_32bit_model(void) {
  return true;
}

void init_sail_reset_vector(uint64_t entry)
{
#define RST_VEC_SIZE 8
  uint32_t reset_vec[RST_VEC_SIZE]
      = {0x297,                              // auipc  t0,0x0
         0x28593 + (RST_VEC_SIZE * 4 << 20), // addi   a1, t0, &dtb
         0xf1402573,                         // csrr   a0, mhartid
         is_32bit_model() ? 0x0182a283u :    // lw     t0,24(t0)
             0x0182b283u,                    // ld     t0,24(t0)
         0x28067,                            // jr     t0
         0,
         (uint32_t)(entry & 0xffffffff),
         (uint32_t)(entry >> 32)};

  uint64_t addr = DEFAULT_RSTVEC;
  for (int i = 0; i < sizeof(reset_vec); i++)
    write_mem(addr++, (uint64_t)((char *)reset_vec)[i]);
}

int main(int argc, char** argv) {
    // Split the arguments we pass to Sail and the arguments we pass
    // to Verilator using SAIL_ARG_DELIM as a delimiter
    int verilator_argc = argc;
    int sail_argc = -1;
    char** sail_argv = nullptr;

    for (int i = 1; i < argc; i++) {
        if (std::strcmp(argv[i], SAIL_ARG_DELIM) == 0) {
            argv[i] = argv[0];
            verilator_argc = i;
            sail_argc = argc - i;
            sail_argv = &argv[i];
        }
    }

    setup_rts();
    if (sail_argc != -1) {
        process_arguments(sail_argc, sail_argv);
    }

    sail_int entry;
    CREATE(sail_int)(&entry);
    elf_entry(&entry, UNIT);
    init_sail_reset_vector(mpz_get_ui(entry));
    KILL(sail_int)(&entry);

    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->commandArgs(verilator_argc, argv);


    const std::unique_ptr<Vsail_toplevel> top{new Vsail_toplevel{contextp.get(), "TOP"}};

    top->reset = 1;
    top->reset_PC = 0x1000;
    top->reset_cur_privilege = 2;
    top->arg0 = 0;

    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();

    top->reset = 0;

    while (!contextp->gotFinish()) {
        std::cout << "Step" << std::endl;
        top->clk = !top->clk;
        top->eval();
        if (top->clk) top->arg0++;
    }

    return 0;
}
