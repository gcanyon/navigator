script "rev_b_Choose"
on mouseUp
   answer color
   if it is empty then exit mouseUp
   repeat with i = 1 to 3
      set the thumbposition of scrollbar (item i of "red,green,blue") to (255 - item i of it)
      set the lastScroll of scrollbar (item i of "red,green,blue") to (255 - item i of it)
   end repeat
   setColors
end mouseUp
  
