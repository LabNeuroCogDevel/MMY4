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

  t.crctKey   = crctKeyIdx;
  t.probe     = issamenback;

  if issamenback 
    seq={'X','X','X'};
  end

  t.seqDisp     = seq;
  % what trigger code we send to the port @ the MEG
  t.tcSeq = getTrigger(1,crctKeyIdx,issamenback);
  
  %% display sequence and send code
  %seqt = drawSeq(w,when,seq,1); %20141208WF, dont need to hold screen
  seqt = drawSeq(w,when,seq);
  t.tcSeqOnset = sendCode(t.tcSeq);

  t.onset= seqt.onset;

  % wait (maxwait seconds) for a valid (keys.finger) response
  % report when the key was pushed, what the rt is (based on onset)
  % what was pushed and if it is correct
  [ t.seqKey,t.seqRT,t.pushed,t.seqCrct ] = ...
      waitForResp(t.onset, when, maxwait,keys.finger,crctKeyIdx);


  printRsp('n_Back',t,seq,issamenback)

  t.clearonset = clearAfterResp(w,colors);
end
