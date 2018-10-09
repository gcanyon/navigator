script "rev_g_barGroup"
function barClickLine
   return round((the mouseV + the scroll of fld "list" - the top of fld "list") / the textHeight of fld "list" + .35)
end barClickLine
