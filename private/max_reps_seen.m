function [max_cnt,varargout] = max_reps_seen(in_vec)
  % MAX_REPS_SEEN - count how many repeats are within in_vec
  %                 optionally return the value repeated the most
  %                 n=1 means we've seen once
  max_cnt=0;
  cur_cnt=1; % starting at second position, count first

  % add on a NaN so last comparision is included
  % if inputs have NaNs were in bigger trouble -- NaN ~= NaN?
  in_vec = [in_vec NaN];
  for i=2:length(in_vec)
    if in_vec(i-1) == in_vec(i)
        cur_cnt=cur_cnt+1;
    else
        % did we break the record?
        if max_cnt < cur_cnt
           max_cnt = cur_cnt;
           % record what is repeated
           if nargin>0, varargout{1} = in_vec(i-1); end
        end
        % reset
        cur_cnt=1;
    end
  end
end

%!test 'count max resps'
%! assert( max_reps_seen([2 1 1 1]) == 3)
%! assert( max_reps_seen([2 2 1 1]) == 2)
%! assert( max_reps_seen([1 2 1 4]) == 1)
%!test 'max rep value'
%! [n, v] = max_reps_seen([1 2 3 3]);
%! assert( v == 3)
%! assert( n == 2)
