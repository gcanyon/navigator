script "rev_b_Save"
on mouseUp
   ask "Save Command As:" with "Command Name"
   if the result is not empty then exit mouseUp
   if char -4 to -1 of it is not ".txt" then put ".txt" after it
   commandWrite it,fld "command"
   buildCustomCommandList
end mouseUp
