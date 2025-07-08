/*=======================================================================================*/
/*  This Sail RISC-V architecture model, comprising all files and                        */
/*  directories except where otherwise noted is subject the BSD                          */
/*  two-clause license in the LICENSE file.                                              */
/*                                                                                       */
/*  SPDX-License-Identifier: BSD-2-Clause                                                */
/*=======================================================================================*/

/* These functions define the primitives for physical memory access.
 * They depend on the XLEN of the architecture.
 *
 * They also depend on the type of metadata that is read and written
 * to physical memory.  For models that do not require this metadata,
 * a unit type can be used.
 */

$define CONCURRENCY_INTERFACE_V2

$include <concurrency_interface.sail>

enum write_kind = {
  Write_plain,
  Write_RISCV_release,
  Write_RISCV_strong_release,
  Write_RISCV_conditional,
  Write_RISCV_conditional_release,
  Write_RISCV_conditional_strong_release,
}

enum read_kind = {
  Read_plain,
  Read_ifetch,
  Read_RISCV_acquire,
  Read_RISCV_strong_acquire,
  Read_RISCV_reserved,
  Read_RISCV_reserved_acquire,
  Read_RISCV_reserved_strong_acquire,
}

enum barrier_kind = {
  Barrier_RISCV_rw_rw,
  Barrier_RISCV_r_rw,
  Barrier_RISCV_r_r,
  Barrier_RISCV_rw_w,
  Barrier_RISCV_w_w,
  Barrier_RISCV_w_rw,
  Barrier_RISCV_rw_r,
  Barrier_RISCV_r_w,
  Barrier_RISCV_w_r,
  Barrier_RISCV_tso,
  Barrier_RISCV_i,
}

enum Access_variety = {
  AV_plain,
  AV_exclusive,
  AV_atomic_rmw
}

enum Access_strength = {
  AS_normal,
  AS_rel_or_acq, // Release or acquire
  AS_acq_rcpc, // Release-consistency with processor consistency
  AS_riscv_strong
}

struct Explicit_access_kind = {
  variety : Access_variety,
  strength : Access_strength
}

union Access_kind = {
  AK_explicit: Explicit_access_kind,
  AK_ifetch : unit, // Instruction fetch
  AK_ttw : unit, // Translation table walk
}

function ak_is_explicit(ak: Access_kind) -> bool = match ak {
  AK_explicit(_) => true,
  _ => false,
}

function ak_is_ifetch(ak: Access_kind) -> bool = match ak {
  AK_ifetch() => true,
  _ => false,
}

function ak_is_ttw(ak: Access_kind) -> bool = match ak {
  AK_ifetch() => true,
  _ => false,
}

function ak_is_relaxed(ak: Access_kind) -> bool = match ak {
  AK_explicit(struct { strength = AS_rel_or_acq, _ }) => true,
  _ => false,
}

function ak_is_rel_acq_rcpc(ak: Access_kind) -> bool = match ak {
  AK_explicit(struct { strength = AS_acq_rcpc, _ }) => true,
  _ => false,
}

function ak_is_rel_acq_rcsc(ak: Access_kind) -> bool = false

function ak_is_standalone(ak: Access_kind) -> bool = match ak {
  AK_explicit(struct { variety = AV_plain, _ }) => true,
  _ => false,
}

function ak_is_exclusive(ak: Access_kind) -> bool = match ak {
  AK_explicit(struct { variety = AV_exclusive, _ }) => true,
  _ => false,
}

function ak_is_atomic_rmw(ak: Access_kind) -> bool = match ak {
  AK_explicit(struct { variety = AV_atomic_rmw, _ }) => true,
  _ => false,
}

/* The Sail concurrency interface lets us have a physical address type
   with additional information, provided we can supply a function that
   converts it into a bitvector. When in RV32 mode, physaddrbits is
   bits(34), which needs to be zero-extended to bits(64) for
   sail_mem_write/read interface. This conversion is necessary because
   the memory interface only supports 32-bit or 64-bit physical
   addresses regardless of the actual physical address width. */
val physaddrbits_zero_extend : physaddrbits -> bits(64)

function physaddrbits_zero_extend xs = zero_extend(xs)

instantiation sail_mem_write with
  'addr_size = physaddrbits_len,
  /* Not currently used for RISC-V */
  'addr_space = unit,
  'mem_acc = Access_kind,
  /* Similarly to addr_space, we don't have a defined type for external
     aborts, so just use unit here too */
  'abort = unit,
  'CHERI = false,
  'cap_size_log = 0,
  mem_acc_is_explicit = ak_is_explicit,
  mem_acc_is_ifetch = ak_is_ifetch,
  mem_acc_is_ttw = ak_is_ttw,
  mem_acc_is_relaxed = ak_is_relaxed,
  mem_acc_is_rel_acq_rcpc = ak_is_rel_acq_rcpc,
  mem_acc_is_rel_acq_rcsc = ak_is_rel_acq_rcsc,
  mem_acc_is_standalone = ak_is_standalone,
  mem_acc_is_exclusive = ak_is_exclusive,
  mem_acc_is_atomic_rmw = ak_is_atomic_rmw

val write_ram : forall 'n, 0 < 'n <= max_mem_access. (write_kind, physaddr, int('n), bits(8 * 'n), mem_meta) -> bool

function write_ram(wk, Physaddr(addr), width, data, meta) = {
  let request : Mem_write_request('n, 0, physaddrbits_len, unit, Access_kind) = struct {
    access_kind = match wk {
      Write_plain => AK_explicit(struct { variety = AV_plain, strength = AS_normal }),
      Write_RISCV_release => AK_explicit(struct { variety = AV_plain, strength = AS_rel_or_acq }),
      Write_RISCV_strong_release => AK_explicit(struct { variety = AV_plain, strength = AS_riscv_strong }),
      Write_RISCV_conditional => AK_explicit(struct { variety = AV_exclusive, strength = AS_normal }),
      Write_RISCV_conditional_release => AK_explicit(struct { variety = AV_exclusive, strength = AS_rel_or_acq }),
      Write_RISCV_conditional_strong_release => AK_explicit(struct { variety = AV_exclusive, strength = AS_riscv_strong }),
    },
    address = addr,
    address_space = (),
    size = width,
    num_tag = 0,
    value = to_bytes_le(data),
    tags = [],
  };
  /* Write out metadata only if the value write succeeds.
   * It is assumed for now that this write always succeeds;
   * there is currently no return value.
   * FIXME: We should convert the external API for all backends
   * (not just for Lem) to consume the value along with the
   * metadata to ensure atomicity.
   */
  match sail_mem_write(request) {
    Ok(_) => {
      __WriteRAM_Meta(addr, width, meta);
      true
    },
    Err() => false,
  }
}

val write_ram_ea : forall 'n, 0 < 'n <= max_mem_access. (write_kind, physaddr, int('n)) -> unit
function write_ram_ea(wk, Physaddr(addr), width) = ()

instantiation sail_mem_read with
  'CHERI = false,
  mem_acc_is_explicit = ak_is_explicit,
  mem_acc_is_ifetch = ak_is_ifetch,
  mem_acc_is_ttw = ak_is_ttw,
  mem_acc_is_relaxed = ak_is_relaxed,
  mem_acc_is_rel_acq_rcpc = ak_is_rel_acq_rcpc,
  mem_acc_is_rel_acq_rcsc = ak_is_rel_acq_rcsc,
  mem_acc_is_standalone = ak_is_standalone,
  mem_acc_is_exclusive = ak_is_exclusive,
  mem_acc_is_atomic_rmw = ak_is_atomic_rmw

val read_ram : forall 'n, 0 < 'n <= max_mem_access.  (read_kind, physaddr, int('n), bool) -> (bits(8 * 'n), mem_meta)
function read_ram(rk, Physaddr(addr), width, read_meta) = {
  let meta = if read_meta then __ReadRAM_Meta(addr, width) else default_meta;
  let request : Mem_read_request('n, 0, physaddrbits_len, unit, Access_kind) = struct {
    access_kind = match rk {
      Read_plain => AK_explicit(struct { variety = AV_plain, strength = AS_normal }),
      Read_ifetch => AK_ifetch(),
      Read_RISCV_acquire => AK_explicit(struct { variety = AV_plain, strength = AS_rel_or_acq }),
      Read_RISCV_strong_acquire => AK_explicit(struct { variety = AV_plain, strength = AS_riscv_strong }),
      Read_RISCV_reserved => AK_explicit(struct { variety = AV_exclusive, strength = AS_normal }),
      Read_RISCV_reserved_acquire => AK_explicit(struct { variety = AV_exclusive, strength = AS_rel_or_acq }),
      Read_RISCV_reserved_strong_acquire => AK_explicit(struct { variety = AV_exclusive, strength = AS_riscv_strong }),
    },
    address = addr,
    address_space = (),
    size = width,
    num_tag = 0,
  };
  match sail_mem_read(request) {
    Ok((value, _)) => (from_bytes_le(value), meta),
    Err(_) => exit(),
  }
}

instantiation sail_barrier with 'barrier = barrier_kind

val __TraceMemoryWrite : forall 'n 'm. (int('n), bits('m), bits(8 * 'n)) -> unit
val __TraceMemoryRead  : forall 'n 'm. (int('n), bits('m), bits(8 * 'n)) -> unit
