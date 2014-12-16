%  genNbackSeq - generate nback sequences of lenght n
%     NO BACK-TO-BACK RECALLS (20141215)
%
% input
%  n: number of inputs to generate
%  back: how far is an nback, the n of nback
%
% output
%  sequene: cell of strings
%  isnback: show "xxx", recall bool
%  seqi: 1-3 for what key we need to push
%
function [seq, isnback, seqi] = genNbackSeq(n,nNback,back)
  seqs = { {'1','0','0'};
           {'0','2','0'};
           {'0','0','3'} };
  
  paren = @(x, varargin) x(varargin{:});
  nseq = length(seqs);
  % first "back" cannot be an nback
  nCanBeBack = n-back;
  seqi=ones(1,n);

   if(nNback>floor(n/2))
     error('%d is too many nbacks for %d trials',...
        nNback,n);
   end

  %build matrix to sample from 
  nbackmat = [repmat(0, 1, (n-nNback-back)*2 ),  ...
              repmat(1, 1,  nNback*2) ];
  
  % double it's size 
  %nbackmat=repmat(nbackmat,1,2)
  
  % sampe nbacks until we dont have repeats
  isnback=nbackmat;
  while any(diff(find(isnback))==1) || length(isnback)~=n  || ~any(isnback)
    isnback = [ repmat(0,1,back) paren(Shuffle( nbackmat  ), 1:nCanBeBack ) ];
  end
  %isnback,

  % how often is each sequence seen
  % repeat sampling until each is seen almost evenly
  nseen=histc(seqi,1:nseq);
  while max(nseen) - min(nseen) > 2


     % what index of seqs should we use for each nback trial
     nisnback = nnz( ~isnback);
     distseq  = repmat(1:nseq,1,ceil(nisnback/nseq));
     seqi(~isnback)  = Shuffle(distseq(1:nisnback));

     nbidx = find(isnback);

     % need to go back and get those that are double backs
     for zz=1:back
      seqi(nbidx)=seqi(nbidx-back);
      seqi(nbidx)=seqi(nbidx-back); 
     end

     nseen=histc(seqi,1:nseq);
  end

  seq=seqs(seqi);
end
