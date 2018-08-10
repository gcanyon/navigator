script "rev_g_Colors"
on mouseUp
   if word 1 of the name of the target is not "graphic" then exit mouseUp
   put the backgroundcolor of the target into C
   answer color with C
   if the result is empty then set the backgroundColor of the target to it
end mouseUp

