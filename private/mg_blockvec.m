% sample from n_mini length list with avg mu
%
% if using 'random' (WF20150303)
%   create vector (length "n_mini") of exp dist numbers with mean "mu" 
%   used to set the length of each miniblock
%   eg.
%    mg_blockvec(5,3,1) % gen 3 lengths with mean 5. no length less than 1
%    5 6 4  -> first block has 5 trials, second has 6, 3rd has 4 trials

function v=mg_blockvec(mu,n_mini, minlen,varargin)


 %% random lengths exp with exp dist
 %% WF20150303 -- random use to be default, now now must be called explicity
 if ~isempty(varargin) && strmatch(varargin{1},'random','exact')
    if(minlen >= mu), error('rand mini block min %d >= mu %d',minlen,mu); end

    maxiter=1000; % stop after 1000 attempts

    % total should be average * repeats
    t_trlblk=mu*n_mini;

    % init loop vars
    d=Inf; v=0; iter=0;
    % go until diff is 0 and all lengths are greater than minlen
    while d~=0 || ~all(v>=minlen);
      v=round(exprnd(mu-minlen,1,n_mini))+minlen;
      d=sum(v)-t_trlblk;
      iter=iter+1;
      if iter > maxiter
        error('could not generate vector of mini block sizes in reasonable time (%d iterations) for mu %.2f w/ %.0f elements (min %d)',...
              maxiter, mu, n_mini,minlen);
      end
    end

 %% sample from a pool of discrete options
 %  -- better guaranties about binned block size
 else

  % if we had 12 mini blocks instead of 4
  %v=Shuffle([3 3 3 3 4 4 4 6 6 6 8 10]);
  v=Shuffle([3 4 5 8]);

  % 20230929 no nback changes breakdown of miniblocks
  if n_mini == 6
    v=Shuffle([3 3 4 4 6 10]);
  end

  if ~(minlen <= min(v)  &&  ...
       mu     == mean(v) &&  ...
       n_mini == length(v)  )
    error(['mg_blockvec: changed hardcoded miniblock length/number settings!\n'...
           '\texpect mean=%.1f n=%d min=%d\n'...
           '\tgot    mean=%.1f n=%d min=%d\n'],...
           mean(v),length(v),min(v), ...
           mu,n_mini,minlen)
  end


 end 
end

%
%!error  mg_blockvec(1,2,2)  % hardcoded values fail when we change parameters

%!test 'hardcoded values mean length and min 20150303 5,12,3'
%! assert(  mean(  mg_blockvec(5,4,3) )==5   )
%! assert(  length(mg_blockvec(5,4,3) )==4   )
%! assert(  sum(   mg_blockvec(5,4,3) )==5*4 )
%! assert(  min(   mg_blockvec(5,4,3) )>=3   )

%!test  'not all the same length'
%! v=mg_blockvec(5,8,1,'random');
%! assert (max(v)>min(v))

%!test 'random respects length and mu constraints'
%! assert (  mean(mg_blockvec(5,8,1,'random'))==5   )
%! assert (length(mg_blockvec(5,8,1,'random'))==8   )
%! assert (   sum(mg_blockvec(5,8,1,'random'))==5*8 )

%!test 'minlength applied'
%! v=mg_blockvec(5,12,3,'random');
%! assert (min(v)>=3)
%
