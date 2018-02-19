script "rev_b_whichStack"
//>GLOBALS
global gSBCardOrBackground, gSBShowAllStacks, gSBShowList, gSBWhichCard, gSBWhichStack


on mouseDown
   local tList, tMainList, tMenuLimit, tSubstacks
   
   put the pMenuLimit of this stack into tMenuLimit
   
   put the mainStacks into tMainList
   put the optionKey is "up" into filterList
   if filterList then put filterStacksList(tMainList) into tMainList
   --sort lines of tMainlist by the scriptonly of stack each
   put empty into tList
   repeat for each line L in tMainList
      if filterList and the scriptonly of stack L then next repeat
      put L & cr after tList
      put the substacks of stack L into tSubstacks
      if tSubstacks is not empty then put tSubstacks & cr after tList
   end repeat
   if not (the shiftKey is "down") then
      sort lines of tList
   end if
   put ("the topStack" & cr & "the mouseStack" & cr & "Stack List" & cr & "-" & cr) before tList
   if the number of lines of tList > tMenuLimit then put line 1 to tMenuLimit of tList into tList
   put tList into me
end mouseDown


on menuPick pWhich
  --enable btn "whichCard" of this stack
  switch
    case the commandKey is "down"
      if pWhich is among the items of "the topstack,Stack List,the mouseStack" then break
      if the optionKey is "down" then toplevel stack pWhich
      else go stack pWhich
      break
    case pWhich is "Stack List"
      --disable btn "whichCard" of this stack
      if the optionKey is "down" then
        put true into gSBShowAllStacks
      else
        put false into gSBShowAllStacks
      end if
      put "Stack" into gSBCardOrBackground[the short name of this stack]
      put true into gSBShowList[the short name of this stack]
      put empty into gSBWhichStack[the short name of this stack]
      put empty into gSBWhichCard[the short name of this stack]
      updateDisplay true
      break
    case pWhich is "the mouseStack" and the optionKey is not "down"
      answer "Please hold down the Option/Alt key and click OK." & cr & "Then place the pointer over the stack you want and release the Option/Alt key." with "OK"
      if the optionKey is not "down" then break
    case pWhich is among the items of "the topStack,the mouseStack" and the optionKey is "down"
      
      set the cursor to hand
      set the lockCursor to true
      waitForKeys ,,"up",,"setTargetStackToMouseStack",(the long id of me)
      break
      --         -- wait until the optionKey is not "down"
      
      --         set the lockCursor to false
      --         put the mouseStack into tStack
      --         beep
      --         if tStack is gSBWhichStack[the short name of this stack] then break
      --         put tStack into pWhich
      --         beep
      --      case pWhich is not gSBWhichStack[the short name of this stack]
      --         --if gSBShowList[the short name of this stack] then
      --         --put "Card List" into gSBWhichCard[the short name of this stack]
      --         --else
      --         put "this card" into gSBWhichCard[the short name of this stack]
      --         --end if
      --         put "card" into gSBCardOrBackground[the short name of this stack]
      --         put pWhich into gSBWhichStack[the short name of this stack]
      --         --put ticks() && the short name of this stack && gSBWhichStack[the short name of this stack]
      --         updateDisplay true
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
