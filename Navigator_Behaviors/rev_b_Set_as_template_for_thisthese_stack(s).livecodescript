script "rev_b_Set_as_template_for_thisthese_stack(s)"
on mouseUp
   put fld "SoS name template" into T["template"]
   put fld "behavior folder" into T["behaviorFolder"]
   put fld "space replacement" into T["space"]
   put uniqueStacksFromIDs(fld "id List Convert") into parentStackList
   repeat for each line stackName in parentStackList
      set the customProperties["navSoStackSettings"] of stack stackName to T
   end repeat
end mouseUp
