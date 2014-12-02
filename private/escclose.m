function escclose(keyCode,varargin)
  if keyCode(KbName('escape'))
      closedown()
      error('early exit')
  end
end
