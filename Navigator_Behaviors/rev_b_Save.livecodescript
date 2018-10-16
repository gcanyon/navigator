script "rev_b_Save"
on mouseUp
   ask "Save Command As:" with "Command Name"
   if the result is not empty then exit mouseUp
   put it into C
   put C into Cname
   if char -4 to -1 of C is not ".txt" then put ".txt" after Cname
   commandWrite Cname,fld "command"
   buildCustomCommandList
   doCallBack C
end mouseUp
