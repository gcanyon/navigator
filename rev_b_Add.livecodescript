script "rev_b_Add"
on menuPick pChosenItem
   put item (itemoffset(pChosenItem,"Control Name,Control Short Name,Control ID,Owner Name,Stack Name,String Literal")) \
         of ("the name of me,the short name of me,the id of me,the name of the owner of me,the name of (word -2 to -1 of the long name of me)," & quote & "literal" & quote) && "&& " \
         into theTemplateText
   if word -1 of the selectedChunk is 4 
   then put theTemplateText into the selection
   else put theTemplateText after fld "SoS Name Template"
   evaluateName
end menuPick
