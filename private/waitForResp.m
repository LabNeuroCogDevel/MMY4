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

  persistent buttonbox;
  if isempty(buttonbox)
    h=getSettings('host');
    buttonbox = h.buttonbox
  end

  % PTB says reset needed if calibrated correct, but we're here anyway...
  if buttonbox
    CedrusResponseBox('ClearQueues', buttonbox);
    resetTime = CedrusResponseBox('ResetRTTimer', buttonbox);
  end

  while GetSecs() - when <= maxwait && ~isfinite(seqRT)
    % for EEG, we're wating on the button box not the keyboard
    % but still want to check the keyboard for esc
    [key, keytime, keyCode] = KbCheck;
    escclose(keyCode);

    if buttonbox
      %evt = CedrusResponseBox('WaitButtonPress', buttonbox);
      evt = CedrusResponseBox('GetButtons', buttonbox);
      if ~isempty(evt)
        disp(evt)
         % event.action == 1
        seqRT = evt.ptbfetchtime;
        pushed = evt.button;
        seqKey = evt.button,
        sqCrtct = finger(crctkey) == evt.button,
      else
        continue
      end
    elseif any(keyCode(finger)) && ~isfinite(seqRT)
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
    else
      continue
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

  end

end
