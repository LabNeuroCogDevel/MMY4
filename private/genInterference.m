function seq = genInterference(seqi,keystring)
  nkeys=length(keystring);
  n=size(seqi,2);
  seq=cell(1,n);
  for i=1:length(seqi);
    key=keystring{seqi(i)};
    % this is interference, so number can be in it's home
    keyidx  = strmatch(key, keystring);
    avalpos = Shuffle(setdiff( 1:nkeys, keyidx));
    seq{i} = {'0','0','0'};
    seq{i}{avalpos(1)}= key;

    emptypos = Shuffle(setdiff( avalpos(1), 1:nkeys));
    avalchars = setdiff( key, keystring);
    for e=1:length(emptypos);
      seq{i}{emptypos(e)} = avalchars(e);
     end
  end
end

