script "rev_b_OK"

on mouseUp
   if the vis of fld "commandOptionList" of this stack then \
         dispatch "setOptionList" to group "commandControls" of this stack with \
         the selectedText of fld "commandOptionList"  of this stack
   if the vis of btn "commandOptionPopup1"  of this stack then \
         dispatch "setOptionOne" to group "commandControls" of this stack with \
         the selectedText of btn "commandOptionPopup1" of this stack
   if the vis of btn "commandOptionPopup2"  of this stack then \
         dispatch "setOptionTwo" to group "commandControls" of this stack with \
         the selectedText of btn "commandOptionPopup2"  of this stack
   hide group "commandOption" of this stack with visual effect reveal up very fast
   send "okOptions" to group "commandControls" of this stack
end mouseUp
