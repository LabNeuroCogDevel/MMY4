%
% show a get ready screen
%
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
    flashMEG(w); % check photo diode and triggers
    disptext='Get Ready! (Waiting for good channel)';
    keyidx = 1:256;
   % elseif strncmp(varargin{1},'Behave',6)
   else
    disptext='Ready?!';
    keyidx = 1:256;
   end

   DrawFormattedText(w,disptext,'center','center');
   [vjunk,lastFlip]=Screen('Flip', w);
   WaitSecs(.5);

   % until we say we're ready
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
