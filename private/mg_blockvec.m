%
% create vector (length "n_mini") of exp dist numbers with mean "mu" 
% used to set the length of each miniblock
% eg.
%  mg_blockvec(5,3,1) % gen 3 lengths with mean 5. no length less than 1
%  5 6 4  -> first block has 5 trials, second has 6, 3rd has 4 trials

function v=mg_blockvec(mu,n_mini, minlen)
 maxiter=1000; % stop after 1000 attempts

 % total should be average * repeats
 t_trlblk=mu*n_mini;

 % init loop vars
 d=Inf; v=0; iter=0;
 % go until diff is 0 and all lengths are greater than minlen
 while d~=0 || ~all(v>=minlen);
   v=round(exprnd(mu,1,n_mini));
   d=sum(v)-t_trlblk;
   iter=iter+1;
   if iter > maxiter
     error('could not generate vector of mini block sizes in reasonable time %.2f %.2f', mu, n_mini);
   end
 end
end

%!test assert (mean(mg_blockvec(5,8,1))==5)
%!test assert (length(mg_blockvec(5,8,1))==8)
%!test assert (sum(mg_blockvec(5,8,1))==5*8)

%!test  'not all the same length'
%! v=mg_blockvec(5,8,1);
%! assert (max(v)>min(v))

%!test 'minlength applied'
%! v=mg_blockvec(5,8,3);
%! assert (min(v)>=3)
%! v=mg_blockvec(5,3,3);
%! assert (min(v)>=3)
