function out_vec = shuffle_maxrep(in_vec, max_allowed)
  maxiterations=10000; % don't block forever
  out_vec = Shuffle(in_vec);
  i = 0;
  while max_reps_seen(out_vec) > max_allowed && i < maxiterations
    out_vec = Shuffle(in_vec);
    i = i +1;
  end
  if i >= maxiterations,
    error('could not generate random sequence with limited repeats!')
  end
 end

%!test 'not too many repeats (random)'
%!assert(max_reps_seen(shuffle_maxrep(repmat([1:2],[1 10]),2))==2)
