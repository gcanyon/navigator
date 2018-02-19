script "rev_g_about"
on mouseUp
   if the clickText is "gcanyon.wordpress.com/navigator-documentation" \
         then launch url "http://gcanyon.wordpress.com/navigator-documentation/" \
         else hideMe
end mouseUp

on setSize
  set the rect of fld "abouthead" to -2,15,((the width of this stack)+1),((the height of this stack)-14)
end setSize

on showMe instant
   setSize
   disableList
   if instant then show me else show me with visual effect scroll down fast
end showMe

on hideMe
  hide me with visual effect reveal up fast
  enableList
end hideMe
