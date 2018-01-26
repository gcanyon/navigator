script "revNavigator_button_group_editProps_behavior_2427_Behavior"
on setSize
  set the rect of field "Prop Title" to 0,17,(the width of this stack + 2),31
  set the rect of fld "editProps" to -2,32,(the width of this stack + 2),(the height of this stack - 15)
  set the loc of btn "closeProps" to 30,(the height of this stack - 9)
  set the loc of button "propListPopup" to -230,30
end setSize

on setup pID
   put objectsAndPropertiesToEdit() into OPA -- idList, propList
   if OPA["idList"] is empty then exit setup
   set the cIDList of fld "editProps" to OPA["idList"]
   if not exists(pID) or pID is not among the lines of OPA["idList"] then put line 1 of OPA["idList"] into pID
   set the cSourceID of fld "editProps" to pID
   put the name of pID && "[" & the short id of pID & "]" into propTitle
   put the number of lines of OPA["idList"] into objectCount
   --put pID & cr & cr & OPA["idList"] & cr & cr & OPA["propList"] ;exit to top
   
   if objectCount > 1 then put " and" && objectCount - 1 && "others" after propTitle
   put propTitle into fld "Prop Title"
   put "<b>|<font color=100,100,100>" into BP
   put "</b>|</font>" into AP
   split BP using "|"
   split AP using "|"
   put 1 into pTag
   put 0 into C
   repeat for each line P in OPA["propList"]
      if P is "-" then 
         put C into bTagMax
         next repeat
      end if
      add 1 to C
      --put P
      if the P of pID is empty then
         put C & tab after eList
         put P & tab & line 1 of the effective P of pID & cr after tString
      else
         put P & tab & line 1 of the P of pID & cr after tString
      end if
   end repeat
   lock screen
   put char 1 to -2 of tString into fld "editProps" of me 
   set the itemdel to tab
   repeat with i = 1 to bTagMax
      set the textstyle of item 1 of line i of fld "editProps" of me to "bold"
   end repeat
   repeat for each item i in eList
      set the textcolor of item 2 of line i of fld "editProps" of me to 170,170,170
   end repeat
   
   unlock screen
   showMe
end setup

on showMe
   setSize
   
   disableList
   
   show me with visual effect scroll right very fast
end showMe

on hideMe
  hide me with visual effect reveal left very fast
  enableList
end hideMe
