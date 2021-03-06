chapter \<open>Generated by Lem from \<open>../../src/gen_lib/sail2_prompt.lem\<close>.\<close>

theory "Sail2_prompt" 

imports
  Main
  "LEM.Lem_pervasives_extra"
  "Sail2_values"
  "Sail2_prompt_monad"
  "Sail2_prompt_monad_lemmas"

begin 

\<comment> \<open>\<open>open import Pervasives_extra\<close>\<close>
\<comment> \<open>\<open>open import Sail_impl_base\<close>\<close>
\<comment> \<open>\<open>open import Sail2_values\<close>\<close>
\<comment> \<open>\<open>open import Sail2_prompt_monad\<close>\<close>
\<comment> \<open>\<open>open import {isabelle} `Sail2_prompt_monad_lemmas`\<close>\<close>

\<comment> \<open>\<open>val >>= : forall 'rv 'a 'b 'e. monad 'rv 'a 'e -> ('a -> monad 'rv 'b 'e) -> monad 'rv 'b 'e\<close>\<close>

\<comment> \<open>\<open>val >> : forall 'rv 'b 'e. monad 'rv unit 'e -> monad 'rv 'b 'e -> monad 'rv 'b 'e\<close>\<close>

\<comment> \<open>\<open>val iter_aux : forall 'rv 'a 'e. integer -> (integer -> 'a -> monad 'rv unit 'e) -> list 'a -> monad 'rv unit 'e\<close>\<close>
fun  iter_aux  :: " int \<Rightarrow>(int \<Rightarrow> 'a \<Rightarrow>('rv,(unit),'e)monad)\<Rightarrow> 'a list \<Rightarrow>('rv,(unit),'e)monad "  where 
     " iter_aux i f (x # xs) = ( f i x \<then> iter_aux (i +( 1 :: int)) f xs )"
|" iter_aux i f ([]) = ( return ()  )"


\<comment> \<open>\<open>val iteri : forall 'rv 'a 'e. (integer -> 'a -> monad 'rv unit 'e) -> list 'a -> monad 'rv unit 'e\<close>\<close>
definition iteri  :: "(int \<Rightarrow> 'a \<Rightarrow>('rv,(unit),'e)monad)\<Rightarrow> 'a list \<Rightarrow>('rv,(unit),'e)monad "  where 
     " iteri f xs = ( iter_aux(( 0 :: int)) f xs )"


\<comment> \<open>\<open>val iter : forall 'rv 'a 'e. ('a -> monad 'rv unit 'e) -> list 'a -> monad 'rv unit 'e\<close>\<close>
definition iter  :: "('a \<Rightarrow>('rv,(unit),'e)monad)\<Rightarrow> 'a list \<Rightarrow>('rv,(unit),'e)monad "  where 
     " iter f xs = ( iteri ( \<lambda>x .  
  (case  x of _ => \<lambda> x .  f x )) xs )"


\<comment> \<open>\<open>val foreachM : forall 'a 'rv 'vars 'e.
  list 'a -> 'vars -> ('a -> 'vars -> monad 'rv 'vars 'e) -> monad 'rv 'vars 'e\<close>\<close>
fun  foreachM  :: " 'a list \<Rightarrow> 'vars \<Rightarrow>('a \<Rightarrow> 'vars \<Rightarrow>('rv,'vars,'e)monad)\<Rightarrow>('rv,'vars,'e)monad "  where 
     " foreachM ([]) vars body = ( return vars )"
|" foreachM (x # xs) vars body = (
  body x vars \<bind> (\<lambda> vars . 
  foreachM xs vars body))"


\<comment> \<open>\<open>val genlistM : forall 'a 'rv 'e. (nat -> monad 'rv 'a 'e) -> nat -> monad 'rv (list 'a) 'e\<close>\<close>
definition genlistM  :: "(nat \<Rightarrow>('rv,'a,'e)monad)\<Rightarrow> nat \<Rightarrow>('rv,('a list),'e)monad "  where 
     " genlistM f n = (
  (let indices = (genlist (\<lambda> n .  n) n) in
  foreachM indices [] (\<lambda> n xs .  (f n \<bind> (\<lambda> x .  return (xs @ [x]))))))"


\<comment> \<open>\<open>val and_boolM : forall 'rv 'e. monad 'rv bool 'e -> monad 'rv bool 'e -> monad 'rv bool 'e\<close>\<close>
definition and_boolM  :: "('rv,(bool),'e)monad \<Rightarrow>('rv,(bool),'e)monad \<Rightarrow>('rv,(bool),'e)monad "  where 
     " and_boolM l r = ( l \<bind> (\<lambda> l .  if l then r else return False))"


\<comment> \<open>\<open>val or_boolM : forall 'rv 'e. monad 'rv bool 'e -> monad 'rv bool 'e -> monad 'rv bool 'e\<close>\<close>
definition or_boolM  :: "('rv,(bool),'e)monad \<Rightarrow>('rv,(bool),'e)monad \<Rightarrow>('rv,(bool),'e)monad "  where 
     " or_boolM l r = ( l \<bind> (\<lambda> l .  if l then return True else r))"


\<comment> \<open>\<open>val bool_of_bitU_fail : forall 'rv 'e. bitU -> monad 'rv bool 'e\<close>\<close>
definition bool_of_bitU_fail  :: " bitU \<Rightarrow>('rv,(bool),'e)monad "  where 
     " bool_of_bitU_fail = ( \<lambda>x .  
  (case  x of
        B0 => return False
    | B1 => return True
    | BU => Fail (''bool_of_bitU'')
  ) )"


\<comment> \<open>\<open>val bool_of_bitU_nondet : forall 'rv 'e. bitU -> monad 'rv bool 'e\<close>\<close>
definition bool_of_bitU_nondet  :: " bitU \<Rightarrow>('rv,(bool),'e)monad "  where 
     " bool_of_bitU_nondet = ( \<lambda>x .  
  (case  x of
        B0 => return False
    | B1 => return True
    | BU => choose_bool (''bool_of_bitU'')
  ) )"


\<comment> \<open>\<open>val bools_of_bits_nondet : forall 'rv 'e. list bitU -> monad 'rv (list bool) 'e\<close>\<close>
definition bools_of_bits_nondet  :: "(bitU)list \<Rightarrow>('rv,((bool)list),'e)monad "  where 
     " bools_of_bits_nondet bits = (
  foreachM bits []
    (\<lambda> b bools . 
      bool_of_bitU_nondet b \<bind> (\<lambda> b . 
      return (bools @ [b]))))"


\<comment> \<open>\<open>val of_bits_nondet : forall 'rv 'a 'e. Bitvector 'a => list bitU -> monad 'rv 'a 'e\<close>\<close>
definition of_bits_nondet  :: " 'a Bitvector_class \<Rightarrow>(bitU)list \<Rightarrow>('rv,'a,'e)monad "  where 
     " of_bits_nondet dict_Sail2_values_Bitvector_a bits = (
  bools_of_bits_nondet bits \<bind> (\<lambda> bs . 
  return ((of_bools_method   dict_Sail2_values_Bitvector_a) bs)))"


\<comment> \<open>\<open>val of_bits_fail : forall 'rv 'a 'e. Bitvector 'a => list bitU -> monad 'rv 'a 'e\<close>\<close>
definition of_bits_fail  :: " 'a Bitvector_class \<Rightarrow>(bitU)list \<Rightarrow>('rv,'a,'e)monad "  where 
     " of_bits_fail dict_Sail2_values_Bitvector_a bits = ( maybe_fail (''of_bits'') (
  (of_bits_method   dict_Sail2_values_Bitvector_a) bits))"


\<comment> \<open>\<open>val mword_nondet : forall 'rv 'a 'e. Size 'a => unit -> monad 'rv (mword 'a) 'e\<close>\<close>
definition mword_nondet  :: " unit \<Rightarrow>('rv,(('a::len)Word.word),'e)monad "  where 
     " mword_nondet _ = (
  bools_of_bits_nondet (repeat [BU] (int (len_of (TYPE(_) :: 'a itself)))) \<bind> (\<lambda> bs . 
  return (Word.of_bl bs)))"


\<comment> \<open>\<open>val whileM : forall 'rv 'vars 'e. 'vars -> ('vars -> monad 'rv bool 'e) ->
                ('vars -> monad 'rv 'vars 'e) -> monad 'rv 'vars 'e\<close>\<close>
function (sequential,domintros)  whileM  :: " 'vars \<Rightarrow>('vars \<Rightarrow>('rv,(bool),'e)monad)\<Rightarrow>('vars \<Rightarrow>('rv,'vars,'e)monad)\<Rightarrow>('rv,'vars,'e)monad "  where 
     " whileM vars cond body = (
  cond vars \<bind> (\<lambda> cond_val . 
  if cond_val then
    body vars \<bind> (\<lambda> vars .  whileM vars cond body)
  else return vars))" 
by pat_completeness auto


\<comment> \<open>\<open>val untilM : forall 'rv 'vars 'e. 'vars -> ('vars -> monad 'rv bool 'e) ->
                ('vars -> monad 'rv 'vars 'e) -> monad 'rv 'vars 'e\<close>\<close>
function (sequential,domintros)  untilM  :: " 'vars \<Rightarrow>('vars \<Rightarrow>('rv,(bool),'e)monad)\<Rightarrow>('vars \<Rightarrow>('rv,'vars,'e)monad)\<Rightarrow>('rv,'vars,'e)monad "  where 
     " untilM vars cond body = (
  body vars \<bind> (\<lambda> vars . 
  cond vars \<bind> (\<lambda> cond_val . 
  if cond_val then return vars else untilM vars cond body)))" 
by pat_completeness auto


\<comment> \<open>\<open>val choose_bools : forall 'rv 'e. string -> nat -> monad 'rv (list bool) 'e\<close>\<close>
definition choose_bools  :: " string \<Rightarrow> nat \<Rightarrow>('rv,((bool)list),'e)monad "  where 
     " choose_bools descr n = ( genlistM ( \<lambda>x .  
  (case  x of _ => choose_bool descr )) n )"


\<comment> \<open>\<open>val choose : forall 'rv 'a 'e. string -> list 'a -> monad 'rv 'a 'e\<close>\<close>
definition chooseM  :: " string \<Rightarrow> 'a list \<Rightarrow>('rv,'a,'e)monad "  where 
     " chooseM descr xs = (
  \<comment> \<open>\<open> Use sufficiently many nondeterministically chosen bits and convert into an
     index into the list \<close>\<close>
  choose_bools descr (List.length xs) \<bind> (\<lambda> bs . 
  (let idx = (( (nat_of_bools bs)) mod List.length xs) in
  (case  index xs idx of
      Some x => return x
    | None => Fail ((''choose '') @ descr)
  ))))"


\<comment> \<open>\<open>val internal_pick : forall 'rv 'a 'e. list 'a -> monad 'rv 'a 'e\<close>\<close>
definition internal_pick  :: " 'a list \<Rightarrow>('rv,'a,'e)monad "  where 
     " internal_pick xs = ( chooseM (''internal_pick'') xs )"


\<comment> \<open>\<open>let write_two_regs r1 r2 vec =
  let is_inc =
    let is_inc_r1 = is_inc_of_reg r1 in
    let is_inc_r2 = is_inc_of_reg r2 in
    let () = ensure (is_inc_r1 = is_inc_r2)
                    "write_two_regs called with vectors of different direction" in
    is_inc_r1 in

  let (size_r1 : integer) = size_of_reg r1 in
  let (start_vec : integer) = get_start vec in
  let size_vec = length vec in
  let r1_v =
    if is_inc
    then slice vec start_vec (size_r1 - start_vec - 1)
    else slice vec start_vec (start_vec - size_r1 - 1) in
  let r2_v =
    if is_inc
    then slice vec (size_r1 - start_vec) (size_vec - start_vec)
    else slice vec (start_vec - size_r1) (start_vec - size_vec) in
  write_reg r1 r1_v >> write_reg r2 r2_v\<close>\<close>
end
