function goodJob(w,varargin)
  DrawFormattedText(w, 'Good Job!', ...
         'center','center');

   if(length(varargin)>0)
     when=varargin{1};
   else
     when=GetSecs();
   end
   Screen('Flip', w,when);
   KbWait;
end
