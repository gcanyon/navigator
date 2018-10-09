script "rev_b_whichStack"
//>GLOBALS
global gSBCardOrBackground, gSBShowAllStacks, gSBShowList, gSBWhichCard, gSBWhichStack
local recentStartLine, recentEndLine

on mouseDown
   prepItems
end mouseDown

on prepItems
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
         iff(the showSOStacks of me,"!c","") & "Show Script-Only Stacks" & cr & "-" & cr into tHead
   put 1 + the number of lines of tHead into recentStartLine
   put recentTargets() into RT
   if RT is not empty then put line 1 to 9 of RT & cr & "-" & cr after tHead
   put the number of lines of tHead - 1 into recentEndLine
   
   put tHead before tList
   put line 1 to tMenuLimit of tList into me
end prepItems


on menuPick pWhich
   put the menuHistory of me into MH
   switch
      case MH is 2 or (MH is 1 and the optionKey is "down")
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
      case MH >= recentStartLine and MH <= recentEndLine
         if not exists(pWhich) then break
         if the commandKey is "down" then 
            if the optionKey is "down" 
            then toplevel pWhich 
            else go pWhich
         else
            setRecentNavigatorTarget pWhich 
         end if
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
   if pMouseData["stack"] is empty then exit setTargetToMouse
   setNavigatorTarget ,("stack" && Q(pMouseData["stack"]))
   put lineListFromIDs(pMouseData["control"]) into tLine
   --if tLine is a number then hiliteLines tLine
   dispatch "setHilites" to fld "list" of this stack with tLine
   updatePalettesWithID ,,pMouseData["control"]
end setTargetToMouse
