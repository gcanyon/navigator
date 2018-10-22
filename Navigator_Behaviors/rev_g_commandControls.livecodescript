script "rev_g_commandControls"
local tCommandFlag,tOptionOne,tOptionTwo,tOptionList

on doCommand
   put empty into tCommandFlag
   hide btn "CommandOptionPopup1"
   hide btn "CommandOptionPopup2"
   hide fld "CommandOptionList"
   
   put the pWorkingLines of group "commandGroup" into tIDList
   put the number of lines of tIDList into tCount
   split tIDList using cr
   lock screen
   lock messages
   repeat with tIndex = 1 to tCount
      
      put tIDList[tIndex] into tID
      if tIndex is 1
      then put tIDList[tCount] into tLastID
      else put tIDList[(tIndex-1)] into tLastID
      
      if tIndex is tCount 
      then put tIDList[1] into tNextID
      else put tIDList[(tIndex+1)] into tNextID
      
      put word 5 to -1 of tID into tOwnerID
      put word -6 to -1 of tID into tCardID
      put word -2 to -1 of tID into tStackID
      set the defaultStack to the value of word -1 of tID
      try
         
         set the text of tID to "B" & tIndex
         
      end try
   end repeat
end doCommand

on setOptionLabel pText
  put pText into field "CommandOptionLabel"
end setOptionLabel

on setOptionOneItems pItems
  put pItems into btn "CommandOptionPopup1"
  show btn "CommandOptionPopup1"
end setOptionOneItems

on setOptionOne pChoice
  put pChoice into tOptionOne
end setOptionOne

on setOptionTwoItems pItems
  put pItems into btn "CommandOptionPopup2"
  show btn "CommandOptionPopup2"
end setOptionTwoItems

on setOptionTwo pChoice
  put pChoice into tOptionTwo
end setOptionTwo

on setOptionListItems pItems
  put pItems into fld "CommandOptionList"
  show fld "CommandOptionList"
end setOptionListItems

on setOptionList pChoices
  put pChoices into tOptionList
end setOptionList

on showOptions
   put the name of stack "revNavigator 92399096674" into navSN
   show group "commandOption" of navSN with visual effect scroll down very fast
   wait until tCommandFlag is not empty with messages
   if tCommandFlag is "Cancel" then exit to top
end showOptions

on cancelOptions
  put "Cancel" into tCommandFlag
end cancelOptions

on okOptions
  put "OK" into tCommandFlag
end okOptions
