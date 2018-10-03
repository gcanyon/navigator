script "rev_g_groupFoldBar"
on mouseUp
   put getID(barClickLine()) into CL
   if the number of lines of CL > 1 or word 1 of CL is not "group" then exit mouseUp
   setFolded CL
   doUpdateDisplay true
end mouseUp
