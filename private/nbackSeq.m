function [seq, nseq] = nbackSeq(seqi)
  seqs = { {'1','0','0'};
           {'0','2','0'};
           {'0','0','3'} };
  nseq = length(seqs);
  seq = seqs(seqi);
end
