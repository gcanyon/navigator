script "rev_f_PropEditor"
local sDefaultValue,sLineNumber

on editValue lineNumber,defaultValue
   --put lineNumber into message
   put defaultValue into sDefaultValue
   put defaultValue into me
   if lineNumber is not empty then put lineNumber into sLineNumber
   setRect lineNumber
   show me
   select text of me
end editValue

on setRect lineNumber
   if lineNumber is not empty then put lineNumber into sLineNumber
   if sLineNumber is not a number then put 1 into sLineNumber
   put the formattedRect of line sLineNumber of fld "editProps" into FR
   put 127 into item 1 of FR
   put -17 + the right of fld "editProps" into item 3 of FR
   add 1 to item 2 of FR
   set the rect of me to FR
end setRect

on escapeKey
   hide me
end escapeKey

on enterInField
   setValue
end enterInField

on returnInField
   setValue
end returnInField

on tabKey
   setValue
end tabKey

on setValue
   hide me
   dispatch "setValue" to field "editProps" with the text of me
end setValue
