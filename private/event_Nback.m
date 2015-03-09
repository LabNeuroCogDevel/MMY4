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

  keyCode=zeros(256,1);



  t.seqCrct   = -1;
  t.seqKey    = Inf;
  t.seqRT     = Inf;
  t.pushed    = 0;
  t.crctKey   = crctKeyIdx;
  t.probe     = issamenback;

  if issamenback 
    seq={'X','X','X'};
  end

  t.seqDisp     = seq;

  %seqt = drawSeq(w,when,seq,1); %20141208WF, dont need to hold screen
  seqt = drawSeq(w,when,seq);
  t.onset= seqt.onset;


  while GetSecs() - when <= maxwait && ...
        ~isfinite(t.seqRT)
        %~(isfinite(t.nbackRT) &&  isfinite(t.seqRT))% 20141208
    [key, keytime, keyCode] = KbCheck;


    escclose(keyCode);

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


    else
      continue
    end

  end

  printRsp('n_Back',t,seq,issamenback)




  Screen('FillRect',w,colors.bg);  % clear the screen from sequence
  drawCross(w,colors.iticross)
  [v,t.clearonset] = Screen('Flip',w);
end
