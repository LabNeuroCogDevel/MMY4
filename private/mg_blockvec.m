
function v=mg_blockvec(mu,n_mini)
 maxiter=1000; % stop after 1000 attempts

 % total should be average * repeats
 t_trlblk=mu*n_mini;

 % init loop vars
 d=Inf; v=0; iter=0;
 % go until diff is 0 and there is no 0
 while d~=0 || ~all(v>0);
   v=round(exprnd(mu,1,n_mini));
   d=sum(v)-t_trlblk;
   iter=iter+1;
   if iter > maxiter
     error('could not generate vector of mini block sizes in reasonable time %.2f %.2f', mu, n_mini);
   end
 end
end

%!test assert (sum(mg_blockvec(5,8))==40)
%!test assert (mean(mg_blockvec(5,8))==5)
%!test assert (length(mg_blockvec(5,8))==8)
%!test 
%! v=mg_blockvec(5,8);
%! assert (max(v)>min(v))