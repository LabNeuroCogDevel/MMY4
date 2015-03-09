function drawCross(w,color)
    [ center(1),center(2)] = RectCenter(Screen('Rect',w));
    crosslen = 20;
    crossw   = 5;
    pos      = [0 0 -1 1; -1 1 0 0].*crosslen;

    %fprintf('draw %d %d %d cross @ %.3f\n',color,GetSecs())
    Screen('DrawLines',w,pos,crossw,color,center);  
end
