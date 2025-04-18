% generate seq seqi and congIdx w/help from genInterfereSeq
% varargout{1} is index of embeded congruent trials
function [seq,seqi, varargout] = genInterfereSeq(n, nInfPureCng, seqi)
  % GENINTERFERESEQ - create interference seq and seqi
  %  n - number of trials
  %  nInfPureCng - number of semi-congruent like '1 2 1' (default 0)
  %  seqi - correct key index like len([1|2|3]) == n (default: generated)

  MAX_CORRECT_KEY_REP_INF = 3;
  keys = getSettings('keys');
  %keys.string = {'1','2','3'};
  
  nkeys = length(keys.string);

  % if we dont give seqi as input, make on the spot
  % 20250417 - prev always made here, and didn't try to limit repeats
  if nargin <= 2
    seqi  = repmat(1:nkeys,1,ceil(n/nkeys));
    seqi = shuffle_maxrep(seqi(1:n), MAX_CORRECT_KEY_REP_INF); % Shuffle(seqi(1:n));
  end

  seq = genInterference(seqi,keys.string);
  
  %20150106 - want to have a few "congruent" 
  %     in interference pure block
  %20250417 - in SPA we dont.
  %     now called in genMixed w/0 to disable (none like '1 2 1')
  if nargin <= 1
    nInfPureCng= 0;
  end

  % either an input error, or we want nothing
  if nInfPureCng > n
    if n==0
     nInfPureCng=0
    else
     error('cannot have num cong (%d) > total n (%d)',nInfPureCng,n)
    end
  end

  % generate which indexes will have the embeded congruent
  idx=Shuffle(1:n);
  idx=sort(idx(1:nInfPureCng));
  for ii=idx

     % congruent key is the correct key
     congpos=seqi(ii);
     % the distractor is originally in the pos idx
     % of the correct key press
     distract = seq{ii}{congpos};
     % the new positions of the distractor will
     % be everywhere the pos index is not
     distidxs = setdiff( 1:length(seq{ii}), congpos );


     % set the correct key to its position index
     seq{ii}{congpos} = num2str(congpos);
     % set the distractor to every other position
     %seq{ii}(distidxs) = distract; %works in octave, not ML
     % 20150108 WF - matlab safe eq. of above
     for di=distidxs, seq{ii}{di} = distract; end

  end

  % index of embedded congruent trials
  varargout{1} = idx;

end


%!test 'can handle 0'
%! [s,k ] = genInterfereSeq(0) ;
%! [s,k,ci ] = genInterfereSeq(0,4) ;


%% n_cong > n is failure
%!error genInterfereSeq(20,30) ;

%!test 'keys match expected'
%! [s,k ] = genInterfereSeq(10) ;
%! kk=arrayfun(@(x) findOddball(x{1},{'1','2','3'}), s);
%! assert( all(k==kk) )

%!test 'congruent trials are congruent'
%! N=10;
%! ncong=2;
%! [s,k,i ] = genInterfereSeq(N,ncong) ;
%! assert(length(i) , ncong)
%! are_same = arrayfun( @(ii) s{ii}{k(ii)} == num2str(k(ii)), i);
%! assert( all(~~are_same) )

%!test 'incongruent trials are incongruent'
%! N=10;
%! ncong=2;
%! [s,k,i ] = genInterfereSeq(N,ncong) ;
%! are_diff = arrayfun( @(ii) s{ii}{k(ii)}==num2str(k(ii)), setdiff(1:N,i) );
%! assert( ~any(~~are_diff) )


%!test 'fixed input seqi'
%! N=10;
%! seqi = [1:3 1:3 1];
%! [s,k] = genInterfereSeq(N,0,seqi) ;
%! assert( all(seqi == k ))
