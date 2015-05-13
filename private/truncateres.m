% truncate event list to only preformed events
%  used to handle early exit for behave and anyMissedOnsets
%  which means can take task saved mat or just res as input
%
function r=truncateres(r)
 % full saved object
 if isfield(r,'res')
  res=r.res;
 else % or just the res 
  res=r;
 end

 expct=length(res);
 comptrl=~cellfun(@isempty,res);
 ncomp=nnz(comptrl);

 if(ncomp ~= expct )
  warning('run was not completed, have %d events instead of %d; truncating',ncomp,expct);

  res=res(1:ncomp);
  % update object
  if isfield(r,'res')
    r.res=res;
    r.e=r.e(1:ncomp);
  else
  % or just update res
    r=res;
  end

 end
end
