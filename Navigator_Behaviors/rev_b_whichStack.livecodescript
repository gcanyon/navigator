script "rev_b_whichStack"
//>GLOBALS
global gSBCardOrBackground, gSBShowAllStacks, gSBShowList, gSBWhichCard, gSBWhichStack


on mouseDown
   local tList, tMainList, tMenuLimit, tSubstacks
   
   put the pMenuLimit of this stack into tMenuLimit
   
   put the mainStacks into tMainList
   put the optionKey is "up" and the controlKey is "up" and not the showIDEStacks of me into hideIDE
   if hideIDE then put filterStacksList(tMainList) into tMainList
   put the optionKey is "up" and the controlKey is "up" and not the showSOStacks of me into hideSOS
   --sort lines of tMainlist by the scriptonly of stack each
   put empty into tList
   repeat for each line L in tMainList
      if hideSOS and the scriptonly of stack L then next repeat
      put L & cr after tList
      put the substacks of stack L into tSubstacks
      if tSubstacks is not empty then put tSubstacks & cr after tList
   end repeat
   if not (the shiftKey is "down") then
      sort lines of tList
   end if
   put "the topStack" & cr & "the mouseStack" & cr & "Stack List" & cr & "-" & cr & \
         iff(the showIDEStacks of me,"!c","") & "Show IDE Stacks" & cr & \
         iff(the showSOStacks of me,"!c","") & "Show Script-Only Stacks" & cr & "-" & cr before tList
   if the number of lines of tList > tMenuLimit then put line 1 to tMenuLimit of tList into tList
   put tList into me
end mouseDown


on menuPick pWhich
   switch
      case pWhich is "the mouseStack" or (pWhich is "the topStack" and the optionKey is "down")
         getMouse the long id of me,"setTargetToMouse"
         break
      case pWhich is "Show IDE Stacks"
         set the showIDEStacks of me to not the showIDEStacks of me
         updateDisplay true,,(the showIDEStacks of me),(the showSOStacks of me)
         break
      case pWhich is "Show Script-Only Stacks"
         set the showSOStacks of me to not the showSOStacks of me
         updateDisplay true,,(the showIDEStacks of me),(the showSOStacks of me)
         break
      case the commandKey is "down"
         if not there is a stack pWhich then break
         if the optionKey is "down" then toplevel stack pWhich
         else go stack pWhich
         break
      case not pWhich is among the items of "the topstack,stack list"
         put "stack" && Q(pWhich) into pWhich
      default
         setNavigatorTarget ,pWhich
         break
   end switch
end menuPick

on setTargetToMouse pMouseData
   if pMouseData["stack"] is not empty then setNavigatorTarget ,("stack" && Q(pMouseData["stack"]))
   put lineListFromIDs(pMouseData["control"]) into tLine
   if tLine is a number then hiliteLines tLine
end setTargetToMouse
