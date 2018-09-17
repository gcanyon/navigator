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
   --enable btn "whichCard" of this stack
   switch
      case pWhich is "Stack List"
         --disable btn "whichCard" of this stack
         put the optionKey is "down" or the showIDEStacks of me into allStacks
         put "Stack" into gSBCardOrBackground[the short name of this stack]
         put true into gSBShowList[the short name of this stack]
         put empty into gSBWhichStack[the short name of this stack]
         put empty into gSBWhichCard[the short name of this stack]
         updateDisplay true,,allStacks,(the showSoStacks of me)
         break
      case pWhich is "the mouseStack" and the optionKey is not "down"
         answer "Please hold down the Option/Alt key and click OK." & cr & "Then place the pointer over the stack you want and release the Option/Alt key." with "OK"
         if the optionKey is not "down" then break
      case pWhich is among the items of "the topStack,the mouseStack" and the optionKey is "down"
         set the cursor to hand
         set the lockCursor to true
         waitForKeys ,,"up",,"setTargetStackToMouseStack",(the long id of me)
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
      default
         setTargetStack pWhich
   end switch
end menuPick


on setTargetStackToMouseStack
  set the lockCursor to false
  setTargetStack the mouseStack
end setTargetStackToMouseStack


on setTargetStack pStack
   if pStack is gSBWhichStack[the short name of this stack] then exit setTargetStack
   --set the autoUpdateList of this stack to pStack is "the topstack"
   put "this card" into gSBWhichCard[the short name of this stack]
   put "card" into gSBCardOrBackground[the short name of this stack]
   put pStack into gSBWhichStack[the short name of this stack]
   put false into gSBShowList[the short name of this stack]
   updateDisplay true
end setTargetStack
