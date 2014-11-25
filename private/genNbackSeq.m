function [seq, isnback, seqi] = genNbackSeq(n)
  back = 2;
  seqs = { {'1','0','0'};
           {'0','2','0'};
           {'0','0','3'} };
  
  nseq = length(seqs);
  % first "back" cannot be an nback
  nCanBeBack = n-back;
  seqi=ones(1,n);

  % how often is each sequence seen
  % repeat sampling until each is seen almost evenly
  nseen=histc(seqi,1:nseq);
  while max(nseen) - min(nseen) > 1

     isnback = repmat(0:1, 1, ceil( nCanBeBack/2 )  );
     isnback = [ repmat(0,1,back) Shuffle( isnback( 1:nCanBeBack )  ) ];

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
