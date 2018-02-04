script "b_Behavior_Stack_Folder_nav"
on mouseUp
   answer folder "Save Script-Only Stack Files In:"
   if it is not empty then put it into fld "Behavior Folder"
end mouseUp
