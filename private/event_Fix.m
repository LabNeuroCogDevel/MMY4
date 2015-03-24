
function t = event_Fix(w,when,color,intensity,code,varargin)
  if isempty(code)
     when,
     color,
     intensity,
     error('no tigger code provided!')
  end
  t.tc = getTrigger(0,code);
  drawCross(w,color);
  drawPhDioBox(w,intensity);
  [v,t.onset] = Screen('Flip',w,when);
  t.tcOnset = sendCode(t.tc);
end
