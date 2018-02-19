script "rev_b_Save"
on mouseUp
  put the value of word -1 the long id of this stack into tPath
  set the itemDelimiter to "/"
  put "Navigator Commands" into item -1 of tPath
  if not (there is a folder tPath) then
    create folder tPath
  end if
  ask "Save Command As:" with "Command Name"
  if the result is not empty then exit mouseUp
  put it into tCommand
  put "/" & tCommand after tPath
  put fld "command" into url ("file:" & tPath)
  buildCustomCommandList
end mouseUp
