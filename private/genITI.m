%% generate ITI
%  fixation time should be about equal to task time
%  NB. will wait full resp time after button push, so fix time will be greater
function ITIs = genITI(n,mu,tmin)
  % ITIs are constant if mu is min
  if mu==tmin
   ITIs = repmat(mu,1,n);
   return
  end
  fprintf('#gen itis using n mu tmin\n')
  [n, mu, tmin],
  if ~exist('exprnd')
      % see genFixedITI.m
      if n == 40 && abs(mu - 1.76666)<1e-4 && tmin == 1
          preiti = load('iti_mix_nonbk.mat');
      elseif n == 120 && abs(mu - 1.76666)<1e-4 && tmin == 1
          preiti = load('iti_mix_nonbk.mat');
          preiti.iti = [preiti.iti; preiti.iti; preiti.iti];
      elseif n == 35 && abs(mu - 1.76666)<1e-4 && tmin == 1
          preiti = load('iti_pure.mat');
      else
          n, mu, tmin,
          error('do not have exprnd function or pre-generated itis (private/iti_mix_nonbk.mat) for settings');
      end
      ITIs = preiti.iti(:,randi(length(preiti.iti)))';
      return
  end

  %% otherwise we want an exp dist iti
  % how to adjust exp dist
  adjust=tmin;
  ITIs=zeros(1,n);
  ITI_expect_dur = (n+1)*mu; 
  MAX_DIFF=.5; % total range is 1 second. will adjust later
  while(abs(sum(ITIs)-ITI_expect_dur) > MAX_DIFF )
   ITIs=exprnd(mu - adjust,1,n+1) + adjust; % min value is adjust
  %while(abs(sum(ITIs)-(n+1)*mu) > .5 )
  % ITIs=exprnd( mu - adjust ,1,n+1) + adjust; % min value is adjust
  end

  % 20231207 - make sure we match mean by redistributing extra
  % HACK. not guarantied to converge
  while(abs(sum(ITIs) - ITI_expect_dur)>10e-3)
     spare = ITIs - tmin;
     ITI_extra = sum(ITIs) - ITI_expect_dur;
     adjust_by = ITI_extra/nnz(spare>0);
     ITIs = ITIs - min(adjust_by,spare);
  end
end

%!test 'is mean (within 10e-5)'
%!  iti=genITI(30,1.3,1);
%!  assert(abs(mean(iti)-1.3)<=10e-5)
%!test 'can do constant'
%!  assert(all(genITI(30,1.4,1.4)==1.4))
%!test 'is correct length'
%!  assert(length(genITI(30,1.4,1.4)==30))
%!  assert(length(genITI(30,1,2)==30))
