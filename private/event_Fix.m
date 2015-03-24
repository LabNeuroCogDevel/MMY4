
function t = event_Fix(w,when,color,intensity,code,varargin)
  t.tc = getTrigger(0,code);
  drawCross(w,color);
  drawPhDioBox(w,intensity);
  [v,t.onset] = Screen('Flip',w,when);
  t.tcOnset = sendCode(t.tc);
end
