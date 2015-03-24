%
% flash photodiode and triggers  for MEG
%
% copied from getReady
function flashMEG(w,varargin)
 
   % number of intensity (4 different intensities)
   pdioInt=.3;
   nmax=4;
   n=0; % start at 0
   
   % until we say we're ready
   ready=0;

   keyidx=1:256;

   lastFlip=fliptext(w);
   WaitSecs(.3);

   % fprintf('waiting for scanner "=" keyboard event\n');
   % wait for scanner to send "=" as a keyboard event
   while(~ready)
       timediff = GetSecs() - lastFlip;
       if( timediff > pdioInt )
           % cycle through 0 to 250 by 50
           sendCode( ceil( mod(n*50,250) ) );
           %cycle through nmax intensities
           drawPhDioBox(w,mod(n,nmax)/nmax);
           lastFlip=fliptext(w);
           n=n+1;
       end

       [keyPressed, starttime, keyCode] = KbCheck;
       if keyPressed && any(keyCode(keyidx)  )
           ready=1;
       end
   end

  % read to start
  sendCode(0);
end
function lastFlip = fliptext(w)
   DrawFormattedText(w,'Checking recording devices','center','center');
   [vjunk,lastFlip]=Screen('Flip', w);
end

%test
% w=setupScreen(127,[880 600])
% flashMEG(w)
