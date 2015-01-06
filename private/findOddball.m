% find the number that is only displayed once
% used by interference task component
% seq like {'1','1','2'}
% keys like {'1','2','3'}
function keyidx = findOddball(seq,keys) 
  possNums = cellfun(@(x) str2num(x),keys); 
  seqNum   = cellfun(@(x) str2num(x),seq);
  repeats  = histc(sort(seqNum),possNums);
  oddball=possNums(repeats == 1);

  if length(oddball) ~= 1
    error('could not identify a unique oddball, bad seq')
  end

  keyidx = find(strcmp({num2str(oddball)},keys));

  if length(keyidx) ~= 1
    error('could not match oddball to keys')
  end

  % not an oddball
  %   happens in pure block of interference on bea's request: 20150106WF
  oddballpos = find(seqNum==oddball);
  if oddballpos == oddball
    warning('not interference! Key index is seq number')
  end
  
end

%% tests; in octave: `test findOddball`
% normal usage
%!assert ( findOddball({'5','1','1'},{'1','2','5'}), 3 )
%!assert ( findOddball({'3','1','1'},{'1','2','3'}), 3 ) 
%!assert ( findOddball({'1','1','2'},{'1','2','3'}), 2 )
%!assert ( findOddball({'3','3','1'},{'1','2','3'}), 1 )
%!assert ( findOddball({'3','3','1','10'},{'1','2','3'}), 1 )
%!assert ( findOddball({'3','3','1'},{'1','2','3','4'}), 1 )

% not interference errors -- just a warning 
%!warning findOddball({'1','3','3'},{'1','2','3'}) 
%!warning findOddball({'1','2','1'},{'1','2','3'}) 
%!warning findOddball({'2','2','3'},{'1','2','3'}) 
% other errors
%!error   findOddball({'1','2','3'},{'1','2','3'}) % no oddball
%!error   findOddball({'1','5','1'},{'1','2','3'}) % oddball not in keys
%!error   findOddball({'1','5','1'},{'a','b','c'}) % keys are not nums
%!error   findOddball({'a','5','1'},{'1','2','a'}) % more non nums
