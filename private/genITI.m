%% generate ITI
%  fixation time should be about equal to task time
%  NB. will wait full resp time after button push, so fix time will be greater
function ITIs = genITI(n,mu,tmin)
  % ITIs are constant if mu is min
  if mu==tmin
   ITIs = repmat(mu,1,n);
   return
  end

  %% otherwise we want an exp dist iti
  % how to adjust exp dist
  adjust=tmin; 
  ITIs=zeros(1,n);
  while(abs(sum(ITIs)-(n+1)*mu) > .5 )
   ITIs=exprnd( mu - adjust ,1,n+1) + adjust; % min value is adjust
  end
end

%!test 'is mean'
%!  iti=genITI(30,1.3,1);
%!  assert(abs(mean(iti)-1.3)<=.5)
%!test 'can do constant'
%!  assert(all(genITI(30,1.4,1.4)==1.4))
%!test 'is correct length'
%!  assert(length(genITI(30,1.4,1.4)==30))
%!  assert(length(genITI(30,1,2)==30))
