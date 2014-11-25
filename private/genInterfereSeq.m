function [seq,seqi] = genInterfereSeq(n)
 
  keys = getSettings('keys');
  %keys.string = {'1','2','3'};
  
  nkeys = length(keys.string);

  seqi  = repmat(1:nkeys,1,ceil(n/nkeys));
  seqi  = Shuffle(seqi(1:n));

  seq=cell(1,n);
  for i=1:length(seqi);
    key=keys.string{seqi(i)};
    % this is interference, so number can be in it's home
    keyidx  = strmatch(key, keys.string);
    avalpos = Shuffle(setdiff( 1:nkeys, keyidx));
    seq{i} = {'0','0','0'};
    seq{i}{avalpos(1)}= key;

    emptypos = Shuffle(setdiff( avalpos(1), 1:nkeys));
    avalchars = setdiff( key, keys.string);
    for e=1:length(emptypos);
      seq{i}{emptypos(e)} = avalchars(e);
     end
  end


end
