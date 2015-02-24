function MRstart = getReady(w,varargin)
 
   % varargin will be isMR
   % if we aren't MR, we dont have to get ready
   if length(varargin)>0 && ~varargin{1}
    MRstart = GetSecs();
    return 
   end

   DrawFormattedText(w, 'Get Ready! (Waiting for scanner to start)', ...
         'center','center');

   Screen('Flip', w);

   scannerTR=0;

   fprintf('waiting for scanner "=" keyboard event\n');
   % wait for scanner to send "=" as a keyboard event
   while(~scannerTR)
       [keyPressed, MRstart, keyCode] = KbCheck;
       if keyPressed && keyCode(KbName('=+')  )
           scannerTR=1;
       end
   end

end
