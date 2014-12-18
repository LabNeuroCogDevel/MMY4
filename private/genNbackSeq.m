%  genNbackSeq - generate nback sequences of lenght n
%     NO BACK-TO-BACK RECALLS (20141215)
%
% input
%  n       number of inputs to generate
%  nProbe  number of recalls/probes 
%  back    how far is an nback, the n of nback
%  
%
% output
%  sequene cell of strings
%  isprobe show "xxx", recall bool
%  seqi    1-3 for what key we need to push
%
%TODO: no probe nback from previous probe
%
function [seq, isprobe, seqi] = genNbackSeq(n,nProbe,back)
  

  % how many back to go doesn't matter if we have no nbacks
  if(n*nProbe*back==0) 
    back   = 0;
    nProbe = 0; 
  end

  seqs = { {'1','0','0'};
           {'0','2','0'};
           {'0','0','3'} };
  
  paren = @(x, varargin) x(varargin{:});
  nseq = length(seqs);
  % first "back" cannot be an nback
  nCanBeBack = n-back;
  seqi=ones(1,n);

   if(nProbe>floor(n/2))
     error('%d is too many nbacks for %d trials',nProbe,n);
   end

  %build matrix to sample from 
  probemat = [repmat(0, 1, (n-nProbe-back)*2 ),  ...
              repmat(1, 1,  nProbe*2) ];
  
  % double it's size 
  %probemat=repmat(probemat,1,2)
  
  % sampe nbacks until we dont have repeats
  isprobe=probemat;
  while any(diff(find(isprobe))==1) ... % no repeat nbacks
        || length(isprobe)~=n       ... % is the correct length
        || (back>0 && ~any(isprobe) )   % have some nbacks if we want them

    isprobe = [ repmat(0,1,back) paren(Shuffle( probemat  ), 1:nCanBeBack ) ];
  end
  %isprobe,

  % how often is each sequence seen
  % repeat sampling until each is seen almost evenly
  nseen=histc(seqi,1:nseq);
  while max(nseen) - min(nseen) > 2


     % what index of seqs should we use for each nback trial
     nisnback = nnz( ~isprobe);
     distseq  = repmat(1:nseq,1,ceil(nisnback/nseq));
     seqi(~isprobe)  = Shuffle(distseq(1:nisnback));

     nbidx = find(isprobe);

     % need to go back and get those that are double backs
     for zz=1:back
      seqi(nbidx)=seqi(nbidx-back);
      seqi(nbidx)=seqi(nbidx-back); 
     end

     nseen=histc(seqi,1:nseq);
  end

  seq=seqs(seqi);
end


%%% Test nback-ness
%!test
%!  [seq, isprobe, seqi] = genNbackSeq(8,2,1);
%!  pidx=find(isprobe);
%!  assert(seqi(pidx) == seqi(pidx-1))
%!test
%!  [seq, isprobe, seqi] = genNbackSeq(8,2,2);
%!  pidx=find(isprobe);
%!  assert(seqi(pidx) == seqi(pidx-2))
%
%% works with no nback
%!test
%!  [seq, isprobe, seqi] = genNbackSeq(8,0,0);
%!  assert(isempty(find(isprobe)));
