script "rev_b_Add_Enclosed_Controls"
on mouseUp
   put allUniqueIDsOf(fld ("id list" && the short name of the owner of me)) into fld ("id list" && the short name of the owner of me)
end mouseUp
