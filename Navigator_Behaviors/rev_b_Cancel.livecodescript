script "rev_b_Cancel"
on mouseUp
  hide group "commandOption" of this stack with visual effect reveal up very fast
  send "cancelOptions" to group "commandControls" of this stack
end mouseUp
