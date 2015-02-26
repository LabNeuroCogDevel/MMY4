%
% take structure outputed by behave.m
% and print some metrics
%
function s = behaveStats(beh)

   fprintf('*** All Trials ***\n')
   s.RTs=sayRT(beh,1);

   if any(beh.is_switch)
      fprintf('\n\n*** SwitchTrials ***\n')
      s.switchRTs=sayRT(beh,beh.is_switch);

      for tt=unique(beh.tt)
         fprintf('\n** Type %d **\n', tt)
         s.tt{tt} = sayRT(beh,beh.tt==tt);
      end
   end

   if any(beh.is_probe)
      fprintf('\n\n*** Probe Trials ***\n')
      s.probeRTs=sayRT(beh,beh.is_probe==1);
   end

end

% how to report RT and count
function RTs = sayRT(beh,whichtrials)
    RTs = ...
    [-1, getRT(beh.seqRT,beh.seqCrct==-1 & whichtrials); ...
      0, getRT(beh.seqRT,beh.seqCrct== 0 & whichtrials); ...
      1, getRT(beh.seqRT,beh.seqCrct== 1 & whichtrials) ...
    ];
   fprintf('Score % 2d: RT %.3f\t(n=%d)\n',RTs');
end

function RTn = getRT(RTs,whichtrials)
   mu = mean(RTs(whichtrials));
   if isempty(mu)
    mu=Inf;
   end
   RTn = [mu,nnz(whichtrials)];
end
