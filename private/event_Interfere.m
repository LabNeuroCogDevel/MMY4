%
% show a sequence of 3 numbers
% and wait for 
% 1) identify oddball key press
%



function t = event_Interfere(w,when,maxwait,seq)
  keys=getSettings('keys');
  colors=getSettings('colors');
  % e.g.
  %keys.nback  = KbName({'n','b'});
  %keys.finger = KbName({'j','k','l'});
  %keys.string = {'1','2','3'};



  crctKeyIdx=findOddball(seq,keys.string);


  t.crctKey   = crctKeyIdx;

  t.tcSeq = getTrigger(1,crctKeyIdx,issamenback);

  seqt = drawSeq(w,when,seq);
  t.tcSeqOnset = sendCode(t.code);

  t.onset= seqt.onset;

  % wait (maxwait seconds) for a valid (keys.finger) response
  % report when the key was pushed, what the rt is (based on onset)
  % what was pushed and if it is correct
  [ t.seqKey,t.seqRT,t.pushed,t.seqCrct ] = ...
      waitForResp(t.onset, when, maxwait,keys.finger,crctKeyIdx);

  printRsp('Interf',t,seq,0)

  t.clearonset = clearAfterResp(w,colors);

end

% OCTAVE TEST
% this can only test when there is no response
% need to overwrite KbCheck function to test more
%!test
%! w=setupScreen(120,[800 600]);
%! when=GetSecs()+.2;
%! waittime=1.5;
%! t=event_Interfere(w,when,waittime,{'1','3','1'});
%! assert(t.seqCrct,-1)
%! assert(t.seqKey,Inf)
%! assert(t.seqRT,Inf)
%! assert(abs(t.onset-when) < .02)
%! t.clearonset-when-waittime
%! assert(abs(t.clearonset-when-waittime) < .02)
%! closedown()
%
