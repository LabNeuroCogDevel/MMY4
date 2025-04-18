function escclose(keyCode,varargin)
  if keyCode(KbName('escape')) || keyCode(KbName('q'))
      closedown()
      error('early exit')
  end  
end
