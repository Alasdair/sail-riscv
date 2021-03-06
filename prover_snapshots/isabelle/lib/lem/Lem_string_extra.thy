chapter \<open>Generated by Lem from \<open>string_extra.lem\<close>.\<close>

theory "Lem_string_extra" 

imports
  Main
  "Lem_num"
  "Lem_list"
  "Lem_basic_classes"
  "Lem_string"
  "Lem_list_extra"

begin 

\<comment> \<open>\<open>****************************************************************************\<close>\<close>
\<comment> \<open>\<open> String functions                                                           \<close>\<close>
\<comment> \<open>\<open>****************************************************************************\<close>\<close>

\<comment> \<open>\<open>open import Basic_classes\<close>\<close>
\<comment> \<open>\<open>open import Num\<close>\<close>
\<comment> \<open>\<open>open import List\<close>\<close>
\<comment> \<open>\<open>open import String\<close>\<close>
\<comment> \<open>\<open>open import List_extra\<close>\<close>
\<comment> \<open>\<open>open import {hol} `stringLib`\<close>\<close>
\<comment> \<open>\<open>open import {hol} `ASCIInumbersTheory`\<close>\<close>


\<comment> \<open>\<open>****************************************************************************\<close>\<close>
\<comment> \<open>\<open> Character's to numbers                                                     \<close>\<close>
\<comment> \<open>\<open>****************************************************************************\<close>\<close>

\<comment> \<open>\<open>val ord : char -> nat\<close>\<close>

\<comment> \<open>\<open>val chr : nat -> char\<close>\<close>

\<comment> \<open>\<open>****************************************************************************\<close>\<close>
\<comment> \<open>\<open> Converting to strings                                                      \<close>\<close>
\<comment> \<open>\<open>****************************************************************************\<close>\<close>

\<comment> \<open>\<open>val stringFromNatHelper : nat -> list char -> list char\<close>\<close>
fun  stringFromNatHelper  :: " nat \<Rightarrow>(char)list \<Rightarrow>(char)list "  where 
     " stringFromNatHelper n acc1 = (
  if n =( 0 :: nat) then
    acc1
  else
    stringFromNatHelper (n div( 10 :: nat)) ((%n. char_of (n::nat)) ((n mod( 10 :: nat)) +( 48 :: nat)) # acc1))"


\<comment> \<open>\<open>val stringFromNat : nat -> string\<close>\<close>
definition stringFromNat  :: " nat \<Rightarrow> string "  where 
     " stringFromNat n = ( 
  if n =( 0 :: nat) then (''0'') else  (stringFromNatHelper n []))"


\<comment> \<open>\<open>val stringFromNaturalHelper : natural -> list char -> list char\<close>\<close>
fun  stringFromNaturalHelper  :: " nat \<Rightarrow>(char)list \<Rightarrow>(char)list "  where 
     " stringFromNaturalHelper n acc1 = (
  if n =( 0 :: nat) then
    acc1
  else
    stringFromNaturalHelper (n div( 10 :: nat)) ((%n. char_of (n::nat)) ( ((n mod( 10 :: nat)) +( 48 :: nat))) # acc1))"


\<comment> \<open>\<open>val stringFromNatural : natural -> string\<close>\<close>
definition stringFromNatural  :: " nat \<Rightarrow> string "  where 
     " stringFromNatural n = ( 
  if n =( 0 :: nat) then (''0'') else  (stringFromNaturalHelper n []))"


\<comment> \<open>\<open>val stringFromInt : int -> string\<close>\<close>
definition stringFromInt  :: " int \<Rightarrow> string "  where 
     " stringFromInt i = ( 
  if i <( 0 :: int) then 
    (''-'') @ stringFromNat (nat (abs i))
  else
    stringFromNat (nat (abs i)))"


\<comment> \<open>\<open>val stringFromInteger : integer -> string\<close>\<close>
definition stringFromInteger  :: " int \<Rightarrow> string "  where 
     " stringFromInteger i = ( 
  if i <( 0 :: int) then 
    (''-'') @ stringFromNatural (nat (abs i))
  else
    stringFromNatural (nat (abs i)))"



\<comment> \<open>\<open>****************************************************************************\<close>\<close>
\<comment> \<open>\<open> List-like operations                                                       \<close>\<close>
\<comment> \<open>\<open>****************************************************************************\<close>\<close>

\<comment> \<open>\<open>val nth : string -> nat -> char\<close>\<close>
definition nth  :: " string \<Rightarrow> nat \<Rightarrow> char "  where 
     " nth s n = ( List.nth ( s) n )"


\<comment> \<open>\<open>val stringConcat : list string -> string\<close>\<close>
definition stringConcat  :: "(string)list \<Rightarrow> string "  where 
     " stringConcat s = (
  List.foldr (@) s (''''))"


\<comment> \<open>\<open>****************************************************************************\<close>\<close>
\<comment> \<open>\<open> String comparison                                                          \<close>\<close>
\<comment> \<open>\<open>****************************************************************************\<close>\<close>

\<comment> \<open>\<open>val stringCompare : string -> string -> ordering\<close>\<close>

definition stringLess  :: " string \<Rightarrow> string \<Rightarrow> bool "  where 
     " stringLess x y = ( orderingIsLess (EQ))"

definition stringLessEq  :: " string \<Rightarrow> string \<Rightarrow> bool "  where 
     " stringLessEq x y = ( \<not> (orderingIsGreater (EQ)))"

definition stringGreater  :: " string \<Rightarrow> string \<Rightarrow> bool "  where 
     " stringGreater x y = ( stringLess y x )"

definition stringGreaterEq  :: " string \<Rightarrow> string \<Rightarrow> bool "  where 
     " stringGreaterEq x y = ( stringLessEq y x )"


definition instance_Basic_classes_Ord_string_dict  :: "(string)Ord_class "  where 
     " instance_Basic_classes_Ord_string_dict = ((|

  compare_method = (\<lambda> x y. EQ),

  isLess_method = stringLess,

  isLessEqual_method = stringLessEq,

  isGreater_method = stringGreater,

  isGreaterEqual_method = stringGreaterEq |) )"

 
end
