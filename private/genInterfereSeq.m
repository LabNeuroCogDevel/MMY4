function [seq,seqi] = genInterfereSeq(n)
 
  keys = getSettings('keys');
  %keys.string = {'1','2','3'};
  
  nkeys = length(keys.string);

  seqi  = repmat(1:nkeys,1,ceil(n/nkeys));
  seqi  = Shuffle(seqi(1:n));

  seq = genInterference(seqi,keys.string)

end
