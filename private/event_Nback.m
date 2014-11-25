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



  t.nbackCrct = -1;
  t.nbackKey  = Inf;
  t.nbackRT   = Inf;
  t.seqCrct   = -1;
  t.seqKey    = Inf;
  t.seqRT     = Inf;

  seq = drawSeq(w,when,seq);
  t.onset= seq.onset;

  while GetSecs() - when <= maxwait && ...
        ~(isfinite(t.nbackRT) &&  isfinite(t.seqRT))
    [key, keytime, keyCode] = KbCheck;



    % is this an nback resp
    if any(keyCode(keys.nback)) && ~isfinite(t.nbackRT)
      fprintf('\t pushed nback key\n');
      t.nbackKey  = keytime;
      t.nbackRT   = keytime - t.onset;

      % pushed all the keys or the wrong key
      if all(keyCode(keys.nback)) || ...
         ~keyCode(keys.nback(nbckKeyIdx))
        t.nbackCrct = 0;
      else
        t.nbackCrct = 1;
      end

    elseif any(keyCode(keys.finger)) && ~isfinite(t.seqRT)
      fprintf('\t pushed seq string key: ');
      t.seqKey  = keytime;
      t.seqRT   = keytime - t.onset;

      % pushed all the keys or the wrong key
      if all(keyCode(keys.finger)) ||...
         ~keyCode(keys.finger(crctKeyIdx))
        t.seqCrct = 0;
        fprintf('WRONG\n');
      else
        t.seqCrct = 1;
        fprintf('correct\n');
      end

    else
      continue
    end

  end



  drawCross(w,colors.iticross)
  [v,t.clearonset] = Screen('Flip',w);
end
