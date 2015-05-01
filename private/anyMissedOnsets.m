%% check timing of onsets against ideal time
% report anything bad
function anyMissedOnsets(res)
   od = cellfun(@(x) abs(x.onset - x.idealonset), res);
   % mean for congr == .0087
   bidx =  od > .1;
   if any(bidx)
     fprintf('\n\n** BAD ONSET(S) ** (%d)\n',  nnz(bidx) );
     cellfun(@(x) fprintf('%02d: %s %s\t%.03f\n',x.trl,x.tt,x.name, x.onset-x.idealonset), ...
             res(bidx));
   end

end
