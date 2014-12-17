% given `seqi` of correct key indexes
% generate `seq`, a cell of strings to display
% from the key->string lookup `keystring`
%
% NB. there are two types of errors that can be made
%
%  if you do not respond to the odd ball key
%  you may respond to the oddball key's postion
%  OR
%  you may respond to the flanking numbers
%

function seq = genInterference(seqi,keystring)
  % how many keys are we pushing?
  nkeys=length(keystring);
  % we have a list of correct answers
  n=size(seqi,2);
  % keep track of flankers for balenced dist
  OBPosCnt=zeros(1,nkeys);
  % initialize cell to hold seq strings
  seq=cell(1,n);

  for i=1:length(seqi);
    % correct response for this sequence
    key=keystring{seqi(i)};
    % this is interference, so number cannot be in it's home
    keyidx  = strmatch(key, keystring);
    avalpos = Shuffle(setdiff( 1:nkeys, keyidx));
    % try to balance 
    [m mi]  =min(OBPosCnt(avalpos)); %mi is idx of avalpos
    obpos =avalpos(mi); % odd ball position
    OBPosCnt(obpos)=OBPosCnt(obpos)+1;

    %20141217 -- we want flanker, not just 0s
    %seq{i} = {'0','0','0'};
    
    
    % flanker is always be the number of
    % the position the oddball is in
    % -- always hard
    % alternatively, we could use the 
    % number that is neither oddball pos or correct key
    % for increased resolution of error type
    dispkey=Shuffle(setdiff(1:nkeys,[obpos,keyidx]));
    dispkey=dispkey(1);
    baseseqidx=repmat(dispkey,1,nkeys); % if we want two types of error
    %baseseqidx=repmat(obpos,1,nkeys); % if we want always hardest
    seq{i}=keystring(baseseqidx );

    % set odd ball positition to correct response key 
    seq{i}{obpos}= key;

    emptypos = Shuffle(setdiff( avalpos(1), 1:nkeys));
    avalchars = setdiff( key, keystring);
    for e=1:length(emptypos);
      seq{i}{emptypos(e)} = avalchars(e);
     end
  end

end

