
function t=event_Fix(w,when,color,varargin)
  drawCross(w,color);
  [v,t.onset] = Screen('Flip',w,when);
end
