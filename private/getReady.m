function MRstart = getReady(w,varargin)
 
   % varargin will be isMR
   % if we aren't MR, we dont have to get ready
   if isempty(varargin) || strncmp(varargin{1},'Unknown',7)
    MRstart = GetSecs();
    return 
   end

   if strncmp(varargin{1},'MR',2)
    disptext='Get Ready! (Waiting for scanner to start)';
    keyidx = KbName('=+');
   elseif strncmp(varargin{1},'MEG',2)
    disptext='Get Ready! (Waiting for channel checks)';
    keyidx = 1:256;
   % elseif strncmp(varargin{1},'Behave',6)
   else
    disptext='Ready?!';
    keyidx = 1:256;
   end


   DrawFormattedText(w,disptext,'center','center');
   Screen('Flip', w);

   ready=0;

   % fprintf('waiting for scanner "=" keyboard event\n');
   % wait for scanner to send "=" as a keyboard event
   while(~ready)
       [keyPressed, MRstart, keyCode] = KbCheck;
       if keyPressed && any(keyCode(keyidx)  )
           ready=1;
       end
   end

end
