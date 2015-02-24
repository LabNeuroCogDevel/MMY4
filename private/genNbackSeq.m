%  genNbackSeq - generate nback sequences of lenght n
%     NO BACK-TO-BACK RECALLS (20141215)
%
%  see nbkMatchSettings for more restricted output
%
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
function [seq, isprobe, seqi] = genNbackSeq(n,nProbe,back)
  

  % how many back to go doesn't matter if we have no nbacks
  if(n*nProbe*back==0) 
    back   = 0;
    nProbe = 0; 
  end


  % some things are impossible
  if(nProbe > floor(n/2) )
    error('cannot have %d probe with %d trials',nProbe,n)
  end
   
  paren = @(x, varargin) x(varargin{:});


  % get number of sequences from nbackSeq function
  % ...ugly hack to make sure we can extend 
  %    the number of sequnces 
  %    nseq=3 as of 20150105
  [junk,nseq] = nbackSeq([]); 

  % first "back" cannot be an nback
  nCanBeBack = n-back;
  seqi=ones(1,n);

   if(nProbe>floor(n/2))
     error('%d is too many nbacks for %d trials',nProbe,n);
   end

  
  % initialze isprobe as zeros
  isprobe=zeros(1,n);


  % added code, but commented 20150123 WF
  consProbeCnt=0;
  % build isprobe vectors until we get what we want
  while any(isprobe((1+back):end)==1 & isprobe(1:(end-back))) ... % no overlapping nbacks (eg back=2    1 2 X 1 X => bad! )
        || length(isprobe)~=n     ... % is the correct length
        || nnz(isprobe) ~= nProbe ... % we have the number of probes we want
        %|| consProbeCnt < consProbeMin ... % consectuive count is >= min
        %|| consProbeCnt > consProbeMax ... % consectuive count is <= max

    % go through all positions that we can set to an nback
    for ipi=(back+1):n
      % - no overlapping nbacks
      %   eg back=2; 1 2 X 1 X => bad!
      % - no more probes than we need
      if(isprobe(ipi-back)) || nnz(isprobe) >= nProbe
       isprobe(ipi)=0; % be explict here,
                       % in case we are overwriting prev iteration
       continue

      end

      % randomly set is probe
      isprobe(ipi)=rand(1) > .5;

      % % end if it's not possible to get what we need
      % probesToGo=nProbe - nnz(isprobe(1:ipi)) ;
      % numUnavail=sum(isprobe( (ipi-back):ipi) );
      % posToGo=(n-ipi+1) - numUnavail;
      % if probesToGo > posToGo       % very generous,could skip much sooner
      %  [ probesToGo, posToGo, ipi,n]
      %  %isprobe(1:ipi)
      %  break
      % end
    end


    %consProbeCnt = nnz(isprobe(2:end)==1 & isprobe(1:(end-1)))

  end

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

  seq=nbackSeq(seqi);
end


%%% TESTS

%% test number of probes
%!test 'nprobe=8 and 12'
%!  N=24;
%!  nback=1;
%!  for nprobe=[8 12]
%!    [seq, isprobe, seqi] = genNbackSeq(N,nprobe,nback);
%!    assert(nnz(isprobe), nprobe);
%!  end

%% test nbacks are valid
%!test 'nback=1 and 2'
%!  N=24;
%!  nprobe=8;
%!  for nback=[1 2]
%!    [seq, isprobe, seqi] = genNbackSeq(N,nprobe,nback);
%!    pidx=find(isprobe);
%!    assert(seqi(pidx) == seqi(pidx-nback))
%!  end


%% works with no nback
%!test
%!  [seq, isprobe, seqi] = genNbackSeq(8,0,0);
%!  assert(isempty(find(isprobe)));

%% can do max
%!test 'max probes'
%! genNbackSeq(8,4,1);
%! genNbackSeq(8,4,2);

%% fails when too many
%!error 'too many probes'
%! genNbackSeq(8,5,1);
