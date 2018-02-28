script "rev_b_pophandlers"
global gSBControlSets

local tMenuText
local tID
local tHandlerList
local putMenuItems
local objectIDArray
local behaviorMenuOffset
local objectMenuOffset

on mouseDown
   prepareItems (the hilitedLines of fld "list")
end mouseDown

on prepareItems tLine
   delete variable tHandlerList
   delete variable objectIDArray
   
   if tLine is empty then 
      put "(No Selection" into me
      exit prepareItems
   else if the number of items of tLine > 1 then 
      put "Edit Script" & cr & "Convert to Behaviors..." & cr & "Restore from Behaviors..." into me
      exit prepareItems
   end if
   put the shiftkey is not "down" into sortHandlers
   put getID(tLine) into tID
   put "function,0 before,1 on,2 after,3 getprop,4 setprop,5" into sortOrder
   split sortOrder by space and comma
   put empty into behaviorMenuItems
   put empty into sendMenuItems
   put tID into xID
   repeat with i = 1 to 100000
      put xID into objectIDArray[i]
      put scriptHandlers(the script of xID) into tHandlerList[i]
      put the keys of tHandlerList[i]["name"] into tHandlerList[i]["list"]
      if sortHandlers then
         sort lines of tHandlerList[i]["list"] by sortOrder[word 1 of each]
         sort lines of tHandlerList[i]["list"] by word 2 of each
      end if
      if i > 1 then
         replace cr with cr & tab in tHandlerList[i]["list"]
         put the short name of xID into tName
         if length(tName) > 30 then put "..." into char 28 to -1 of tName
         put tName & cr & tab & tHandlerList[i]["list"] & cr after editMenuItems
         put cr & the name of xID & cr & tab & tHandlerList[i]["list"] after putMenuItems 
      else
         put the name of xID & cr & tHandlerList[i]["list"] into putMenuItems
         replace cr with cr & tab in putMenuItems
      end if
      put tab & tHandlerList[i]["list"] into sendList
      replace cr with cr & tab in sendList
      --       repeat for each line L in tHandlerList[i]["list"]
      --          if word 1 of L is among the items of "on,function,getprop,setprop,command" then put tab & L & cr after sendList
      --       end repeat
      if i > 1 then 
         put tab & tName & cr & tab & sendList & cr after sendMenuItems
      else
         put sendList into objectSendMenuItems
      end if
      put the behavior of xID into xID
      if xID is empty then exit repeat
   end repeat
   
   put tHandlerList[1]["list"] after editMenuItems
   delete char -1 of sendMenuItems
   put splice(cr,sendMenuItems,objectSendMenuItems) into sendMenuItems
   if char -2 to -1 of sendMenuItems is cr & tab then delete char -2 to -1 of sendMenuItems   
   
   put format("Copy Script\nPaste Script\nPut Handler List\nEdit Script\nConvert to Behaviors...\nRestore from Behaviors...\nSend:\n%s\n(-\n%s",sendMenuItems,editMenuItems) into menuContent
   put menuContent into me
   --put menuContent
end prepareItems

on menuPick pWhich
   --    put pWhich && the menuhistory of me
   --    exit menuPick
   if pWhich is "Copy Script" then
      set clipboardData["text"] to the script of tID
   else if pWhich is "Paste Script" then
      get empty
      if the script of tID is not empty \
            then answer warning "Replace the script of" & cr & tID & cr & "the clipboard?" with "Replace" or "Cancel"
      if it is not "Cancel" then 
         try
            set the script of tID to clipboardData["text"]
         catch someErr
            answer warning someErr with "OK"
         end try 
      end if
   else if pWhich is "Put Handler List" then
      put putMenuItems
   else if pWhich is "Edit Script" then
      editObjectScripts
   else if pWhich is "Convert to Behaviors..." then
      showScriptConversion getList(false) 
      --convertToScriptOnlyStackBehaviors  idList
   else if pWhich is "Restore from Behaviors..." then
      showRestoreBehaviors getList(false)
   else if the menuhistory of me is 7 then
      set the itemdelimiter to "|"
      put item -1 of pWhich into tHandler
      set the itemdelimiter to comma
      repeat with objectIndex = 1 to item 2 of the extents of tHandlerList
         if tHandlerList[objectIndex]["template"][tHandler] is not empty then exit repeat
      end repeat
      put tHandlerList[objectIndex]["template"][tHandler] into tCommand
      put word 2 of tCommand into tCommandName
      if word 1 of tCommand is "private" then
         put true into privateCall
         delete word 1 of tCommand
      end if
      put word 2 of tCommand into tCommandName
      if privateCall then
         if word 1 of tCommand is not "function"
         then put word 2 to -1 of tCommand into tPrivateCommand
         else put "return " && word 2 of tCommand & "(" & word 3 to -1 of tCommand & ")" into tPrivateCommand
         put "x" & ticks() into word 2 of tCommand
         put tCommand & cr & tPrivateCommand & cr & "end" && word 2 of tCommand into tPublicHandler
         set the script of objectIDArray[objectIndex] to the script of objectIDArray[objectIndex] & cr & tPublicHandler
      end if
      put the name of tID into tIDname
      switch word 1 of tCommand
         case "getprop"
            ask format("The %s of %s is:",tCommandName,tIDname) with the tCommandName of tID
            break
         case "setprop"
            ask format("Set the %s of %s to:",tCommandName,tIDname) with empty
            if the result is not empty then break
            set the tCommandName of tID to it
            break
         case "on"
         case "command"
         case "function"
            if word 1 of tCommand is among the words of "on command" then put empty into fKey else put "function " into fKey
            put the number of items of (word 3 to -1 of tCommand) into tArgCount
            if tArgCount > 9 then 
               answer warning "Navigator can only pass 9 arguments." with "Cancel" or "Proceed"
               if it is "Cancel" then break else put 9 into tArgCount
            end if
            repeat with i = 1 to tArgCount
               ask format("For %s%s of %s, set %s to:",fKey,tCommandName,tIDname,item i of (word 3 to -1 of tCommand)) with empty
               if the result is not empty then break
               put it into tA[i]
            end repeat
            if fKey is empty then 
               dispatch word 2 of tCommand to tID with tA[1],tA[2],tA[3],tA[4],tA[5],tA[6],tA[7],tA[8],tA[9]
            else 
               dispatch function word 2 of tCommand to tID with tA[1],tA[2],tA[3],tA[4],tA[5],tA[6],tA[7],tA[8],tA[9]
               put the result into tResult
               ask format("Function %s() of %s returned:",tCommandName,tIDname) with tResult
            end if
            break
      end switch
      if privateCall is true then 
         set the script of objectIDArray[objectIndex] to line 1 to -4 of the script of objectIDArray[objectIndex]
      end if
   else if the menuhistory of me > 8 then
      set the itemdelimiter to "|"
      put item -1 of pWhich into tHandlerName
      set the itemdelimiter to comma
      put the menuhistory of me - 7 into objectIndex
      if objectIndex > item 2 of the extents of objectIDArray then put 1 into objectIndex
      edit the script of objectIDArray[objectIndex]
      send "selectScriptLine" && tHandlerList[objectIndex]["name"][tHandlerName] to me in 5 ticks
   end if
end menuPick


on selectScriptLine X
   repeat for each line tStack in the openStacks
      if word 1 of tStack is "revNewScriptEditor" then exit repeat
   end repeat

   try
      select line X of field "Script" of group "Editor" of card "Main" of stack tStack
      go stack tStack
   catch someErr
   end try
end selectScriptLine
