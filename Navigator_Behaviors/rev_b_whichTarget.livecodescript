script "rev_b_whichTarget"
local recentStartLine, recentEndLine
local targetArray


on mouseDown
   prepItems
end mouseDown

--on popMe
--   prepItems
--   popup me
--end popMe

function uniqueNamedCardsOf stackID
   put the cardnames of stackID into R["list"]
   put R["list"] into CNtest
   split CNtest using cr as set
   put the keys of CNtest into CNtest
   put the number of lines of R["list"] into LC
   put the cardids of stackID into CID
   split CID using cr
   if LC is not the number of lines of CNtest then
      split R["list"] using cr
      combine R["list"] using cr and space
      sort lines of R["list"] numeric by word 1 of each
   end if
   put 0 into i
   repeat for each line CN in R["list"]
      add 1 to i
      put CID[i] into R["ID"][CN]
   end repeat
   return R
end uniqueNamedCardsOf

function uniqueNamedBackgroundsOf stackID
   put the backgroundnames of stackID into R["list"]
   put R["list"] into BNtest
   split BNtest using cr as set
   put the keys of BNtest into BNtest
   put the number of lines of R["list"] into LC
   put the backgroundids of stackID into BID
   split BID using cr
   if LC is not the number of lines of BNtest then
      split R["list"] using cr
      combine R["list"] using cr and space
      sort lines of R["list"] numeric by word 1 of each
   end if
   put 0 into i
   repeat for each line BN in R["list"]
      add 1 to i
      put BID[i] into R["ID"][BN]
   end repeat
   return R
end uniqueNamedBackgroundsOf

function stackMenuItems SN
   put SN & cr & \
         tab & "Top Level" & cr & tab & "Go" & cr & tab & "-" & cr & \
         tab & "Card List" & cr & tab &  "Background List" & cr & tab & "-" into R
   
   put uniqueNamedCardsOf(the long id of stack SN) into targetArray[SN]["CD"]
   put tab & tab & targetArray[SN]["CD"]["list"] into cdList
   replace cr with cr & tab & tab in cdList
   
   put uniqueNamedBackgroundsOf(the long id of stack SN) into targetArray[SN]["BG"]
   put tab & tab & targetArray[SN]["BG"]["list"] into bgList
   replace cr with cr & tab & tab in bgList
   
   if cdList is not tab & tab then put cr & tab & "Cards" & cr & cdList after R
   if bgList is not tab & tab then put cr & tab & "Backgrounds" & cr & bgList after R
   
   --replace cr with cr & tab in R
   return R
end stackMenuItems



on prepItems
   local tList, tMainList, tMenuLimit, tSubstacks
   put empty into targetArray
   put the pMenuLimit of this stack into tMenuLimit
   put "this card" & cr & "the mouseStack" & cr & "Stack List" & cr & "-" & cr & \
         iff(the showIDEStacks of stack "revNavigator","!c","") & "Show IDE Stacks" & cr & \
         iff(the showSOStacks of stack "revNavigator","!c","") & "Show Script-Only Stacks" & cr & "-" & cr into tList
   
   put 1 + the number of lines of tList into recentStartLine
   put recentTargets() into RT -- uncomment this
   if RT is not empty then put line 1 to 9 of RT & cr & "-" & cr after tHead -- uncomment this
   put the number of lines of tList - 1 into recentEndLine
   
   put the mainStacks into tTempList
   put the optionKey is "up" and the controlKey is "up" and not the showIDEStacks of stack "revNavigator" into hideIDE
   --put true into hideIDE -- remove this
   if hideIDE then put filterStacksList(tTempList) into tTempList
   put the optionKey is "up" and the controlKey is "up" and not the showSOStacks of stack "revNavigator" into hideSOS
   --put true into hideSOS -- remove this
   put empty into tMainList
   repeat for each line L in tTempList
      put L & cr after tMainList
      put the substacks of stack L into tSubstacks
      if tSubstacks is not empty then put tSubstacks & cr after tMainList
   end repeat
   if the shiftKey is "up" then sort lines of tMainList
   sort lines of tMainlist by the scriptonly of stack each
   --debug tMainList
   repeat for each line L in tMainList
      if the scriptonly of stack L then
         if not hideSOS then; put L & cr after tList; end if
      else
         put stackMenuItems(L) & cr after tList
      end if
   end repeat
   --debug tList
   --put line 1 to tMenuLimit of tList into me
   put char 1 to -2 of tList into me
end prepItems

on menuPick pWhich
   put the menuHistory of me into MH
   
   if MH < 7 then
      if MH is 2
      then getMouse the long id of me,"setTargetToMouse"
      else if MH is 1 or MH is 3
      then setNavigatorTarget "",(item MH of "the topstack,,stack list"),(the shiftkey is "down")
      else 
         put item MH - 4 of "showIDEStacks,showSOStacks" into tPropName
         set the tPropName of stack "revNavigator" to not the tPropName of stack "revNavigator"
         updateDisplay true,,(the showIDEStacks of stack "revNavigator"),(the showSOStacks of stack "revNavigator")
      end if
   else if MH <= recentEndLine then 
      setRecentNavigatorTarget pWhich,(the shiftkey is "down") 
   else
      repeat for each item T in "|Cards|,|Backgrounds|"
         add 1 to typeI
         put offset(T,pWhich) into menuDelOff
         if menuDelOff > 0 then exit repeat
      end repeat
      if menuDelOff = 0 then 
         if exists(stack pWhich) and the scriptonly of stack pWhich then
            editObjectScriptsID pWhich
         else
            set the itemdel to "|"
            put item -1 of pWhich into subM
            put item 1 to -2 of pWhich into SN
            set the itemdel to comma
            if subM = "Top Level" 
            then toplevel stack SN
            else if subM = "Go" 
            then go stack SN
            else setNavigatorTarget ,(subM && "of" && Q(SN)),(the shiftkey is "down")
         end if
      else
         put item typeI of "CD,BG" into shortType
         put item typeI of "card,background" into theType
         put char 1 to menuDelOff - 1 of pWhich into SN
         put char menuDelOff + (item typeI of "7,13") to -1 of pWhich into objN            
         put theType && "id" && targetArray[SN][shortType]["ID"][objN] && "of stack" && Q(SN) into pTarget
         --answer pTarget & cr & the long name of pTarget
         if not exists(pTarget) then
            debug pTarget
            exit menuPick
         end if
         if word 1 of pTarget is "card" and the commandKey is "down" 
         then go pTarget
         else setNavigatorTarget ,pTarget,(the shiftkey is "down") 
      end if
   end if
end menuPick

on setTargetToMouse pMouseData
   if pMouseData["stack"] is empty then exit setTargetToMouse
   setNavigatorTarget ,("stack" && Q(pMouseData["stack"])),(the shiftkey is "down")
   put lineListFromIDs(pMouseData["control"]) into tLine
   --if tLine is a number then hiliteLines tLine
   dispatch "setHilites" to fld "list" of this stack with tLine
   updatePalettesWithID ,,pMouseData["control"]
end setTargetToMouse

