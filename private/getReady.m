function MRstart = getReady(w)

   DrawFormattedText(w, 'Get Ready! (Waiting for scanner to start)', ...
         'center','center');

   Screen('Flip', w);

   if ~ispc
    MRstart = GetSecs();
    return 
   end

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
