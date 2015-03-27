%
% redudant bit of intf and nback abstracted

% wait (maxwait seconds) for a valid (keys.finger) response
% report when the key was pushed, what the rt is (based on onset)
% what was pushed and if it is correct
% [ t.seqKey,t.seqRT,t.pushed,t.seqCrct ] = ...
%     waitForResp(onset, when, maxwait,keys.finger,crctKeyIdx)
%
function [ seqKey,seqRT,pushed,seqCrct ] = waitForResp(onset, when,maxwait,finger,crctkey)

  seqCrct   = -1;
  seqKey    = Inf;
  seqRT     = Inf;
  pushed    = 0;
  keyCode=zeros(256,1);

  while GetSecs() - when <= maxwait && ~isfinite(seqRT)
    [key, keytime, keyCode] = KbCheck;


    escclose(keyCode);

    if any(keyCode(finger)) && ~isfinite(seqRT)
      seqKey  = keytime;
      seqRT   = keytime - onset;
      pushed  = find(keyCode(finger));

      % pushed all the keys or the wrong key
      if all(keyCode(finger)) ||...
         ~keyCode(finger(crctkey))
        seqCrct = 0;
      else
        seqCrct = 1;
      end

      % send trigger code for meg
      % we do not need or want to send a zero code
      % after a fixed  deleay   (so 'dontsendzero')
      % - it'd be bad because we could be responding within ms of ending
      %   and the fixed wait would push us outside the intended timing
      % - we can get away with it because the next code will be 255
      %   w/o reseting to 0, the first sample might be above the value we want
      %       but there isn't anything above 255 :) 
      tcRT      = getTrigger(2,(~seqCrct)+1);
      tcRTOnset = sendCode( tcRT, 'dontsendzero' );

    else
      continue
    end

  end

end
