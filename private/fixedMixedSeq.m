
function [ randIdx, nbackseq, isnback, intseq,nblocks ] = ...
            fixedMixedSeq(runnum)


 if runnum==1
   nbkblocks=[ 7 9 5 3 9 8 6 7 10 6]; % 70
   infblocks=[ 3 1 6 4 4 2 3 1 2 4 ];  % 30
 end
 nblocks=20


 % zip nbk and inf blocks together
 % so we have vec of 1 if nback
 % and 2 if inf
 s=1;
 for i=1:length(nbkblocks)
    e=nbkblocks(i)+s-1;
    randIdx(s:e) = 1;
    s=e+1; e=infblocks(i)+s-1;
    randIdx(s:e) = 2;
    s=e+1;
 end

 %% generage nbackseq
 idx=cumsum(nbkblocks);
 idxif=cumsum(infblocks);
 for nbki = 1:length(nbkblocks)
    if nbki<2, s=1; else s=idx(nbki-1)+1; end;
    e=idx(nbki);
    bsize=nbkblocks(nbki);
    [ nbackseq(s:e) isnback(s:e) ~ ] = ...
        genNbackSeq(bsize, round(bsize*.36),1);

    if nbki<2, s=1; else s=idxif(nbki-1)+1; end;
    e=idxif(nbki);
    intseq(s:e) = genInterfereSeq(infblocks(nbki));
 end


end
