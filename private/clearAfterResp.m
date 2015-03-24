% clear the screen from sequence
% display ITI, but with RT photodiode color
function  clearonset = clearAfterResp(w,colors)
  Screen('FillRect',w,colors.bg);
  drawCross(w,colors.iticross);
  drawPhDioBox(w,colors.pd.RT);
  [v,clearonset] = Screen('Flip',w);
end
