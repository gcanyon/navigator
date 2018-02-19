script "rev_b_Add_Behavior_Chains"
on mouseUp
   put addBehaviorChains(fld ("id list" && the short name of the owner of me)) into fld ("id list" && the short name of the owner of me)
end mouseUp
