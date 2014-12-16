function t = event_Interfere(w,when,maxwait,seq)
  fprintf('\tinterference');
  keys=getSettings('keys');
  colors=getSettings('colors');
  % e.g.
  %keys.nback  = KbName({'n','b'});
  %keys.finger = KbName({'j','k','l'});
  %keys.string = {'1','2','3'};



  crctKeyIdx=findOddball(seq,keys.string);

  keyCode=zeros(256,1);

  t.seqCrct   = -1;
  t.seqKey    = Inf;
  t.seqRT     = Inf;

  seq = drawSeq(w,when,seq);
  t.onset= seq.onset;

  while GetSecs() - when <= maxwait && ~isfinite(t.seqRT)
    [key, keytime, keyCode] = KbCheck;
    escclose(keyCode);

    if any(keyCode(keys.finger)) && ~isfinite(t.seqRT)

      t.seqKey  = keytime;
      t.seqRT   = keytime - t.onset;

      % pushed all the keys or the wrong key
      if all(keyCode(keys.finger)) ||...
         ~keyCode(keys.finger(crctKeyIdx))
        t.seqCrct = 0;
        fprintf('\tWRONG');
      else
        t.seqCrct = 1;
        fprintf('\tcorrect');
      end

      fprintf('\tRT: %.3f\n', t.seqRT );

    end

  end


  drawCross(w,colors.iticross)
  [v,t.clearonset] = Screen('Flip',w);
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
