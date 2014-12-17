%
% show a sequence of 3 numbers
% and wait for 
% 1) identify oddball key press
% 2) nback key press
%
% sequence independent

function t=event_Nback(w,when,maxwait,seq,issamenback)
  colors = getSettings('colors');
  keys   = getSettings('keys');
  % e.g.
  %keys.nback  = KbName({'n','b'});
  %keys.finger = KbName({'j','k','l'});
  %keys.string = {'1','2','3'};



  crctKeyIdx=findFingerInSeq(seq,keys.string);
  nbckKeyIdx = issamenback+1;  % idx 1 is not nback, 2 is nback

  keyCode=zeros(256,1);



  t.seqCrct   = -1;
  t.seqKey    = Inf;
  t.seqRT     = Inf;
  t.pushed    = 0;
  t.crctKey   = crctKeyIdx;

  if issamenback 
    seq={'X','X','X'};
  end
  %seqt = drawSeq(w,when,seq,1); %20141208WF, dont need to hold screen
  seqt = drawSeq(w,when,seq);
  t.onset= seqt.onset;

  % 20141208 WF
  %  we are not doing sep. key press for nback
  %  so dont wait for it
  %t.nbackRT=0;
  %t.nbackCrct = -1;
  %t.nbackKey  = Inf;
  %t.nbackRT   = Inf;

  while GetSecs() - when <= maxwait && ...
        ~isfinite(t.seqRT)
        %~(isfinite(t.nbackRT) &&  isfinite(t.seqRT))% 20141208
    [key, keytime, keyCode] = KbCheck;


    escclose(keyCode);

    % 20141208 -- we dont have 2 button presses
    % is this an nback resp
    %if any(keyCode(keys.nback)) && ~isfinite(t.nbackRT)
    %  t.nbackKey  = keytime;
    %  t.nbackRT   = keytime - t.onset;

    %  % pushed all the keys or the wrong key
    %  if all(keyCode(keys.nback)) || ...
    %     ~keyCode(keys.nback(nbckKeyIdx))
    %    t.nbackCrct = 0;
    %    fprintf('\tWRONG');
    %  else
    %    t.nbackCrct = 1;
    %    fprintf('\tcorrect');
    %  end
    %elseif any(keyCode(keys.finger)) && ~isfinite(t.seqRT)
    
    if any(keyCode(keys.finger)) && ~isfinite(t.seqRT)
      t.seqKey  = keytime;
      t.seqRT   = keytime - t.onset;
      t.pushed  = find(keyCode(keys.finger));

      % pushed all the keys or the wrong key
      if all(keyCode(keys.finger)) ||...
         ~keyCode(keys.finger(crctKeyIdx))
        t.seqCrct = 0;
      else
        t.seqCrct = 1;
      end

      % 20141208 WF -- only 1 key resposne
      %   no need for reminder, removed hold screen from drawSeq too
      %reminder=[ 'back (' keys.fingernames{5} ')'...
      %           'or not (' keys.fingernames{4} ')'];
      %[cx,cy] = RectCenter(Screen('Rect',w));
      %Screen('DrawText',w,reminder,cx-100,cy+30,0);
      %[v,t.reminderonset] = Screen('Flip',w,keytime,1);


    else
      continue
    end

  end

  printRsp('Congru',t,seq,issamenback)




  Screen('FillRect',w,colors.bg);  % clear the screen from sequence
  drawCross(w,colors.iticross)
  [v,t.clearonset] = Screen('Flip',w);
end
