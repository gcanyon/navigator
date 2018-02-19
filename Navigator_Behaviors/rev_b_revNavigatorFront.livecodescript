script "rev_b_revNavigatorFront"
on preOpenCard
  revPreOpenCard
  pass preOpenCard
end preOpenCard

on preOpenStack
  revPreOpenStack
  pass preOpenStack
end preOpenStack

on resumeStack
  revResumeStack
  pass resumeStack
end resumeStack

on selectedObjectChanged
  revSelectedObjectChanged
  pass selectedObjectChanged
end selectedObjectChanged
