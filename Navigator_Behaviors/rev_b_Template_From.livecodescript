script "rev_b_Template_From"
on prepItems
   repeat for each line S in uniqueStacksFromIDs(fld "id List Convert") & cr & uniqueStacksFromIDs(fld "id List Convert",true)
      try
         put the customProperties["navSoStackSettings"] of stack S into U
         if the keys of U is not empty 
         then put S & cr after menuStackList
      catch E
      end try
   end repeat    
   put char 1 to -2 of menuStackList into me
end prepItems

on mouseDown
   prepItems
end mouseDown


on menuPick S
   put the customProperties["navSoStackSettings"] of stack S into U
   put U["template"] into fld "SoS Name Template" 
   put U["space"] into fld "space replacement" 
   put U["behaviorFolder"] into fld "behavior folder" 
end menuPick
