
% block types is 1 (Nback), 2 (Interfere), or 1:2 for both
function e = genEventList(n,blocktypes)

      time   = getSettings('time');
      colors = getSettings('colors');

      if mod(n,2)~=0
        error('number of events is not divs by 2!')
      end

      types={'Nback','Interfere'};
      if blocktypes<=2
         randIdx=repmat(blocktypes,1,n);
         [nbackseq, isnback] = genNbackSeq( nnz(randIdx==1) );
         intseq   = genInterfereSeq(  nnz(randIdx==2) );

      else
         nbmu=4; nimu=2;
         [ randIdx, nbackseq, isnback, intseq ] = ...
            genEventMixed(n,nbmu,nimu);
      end

      trlTypes=types(randIdx);

      cumtime=0;

      for t=1:n
        si=2*t-1;
        tt = trlTypes{t};

        %% Fix
        e(si).trl=t;
        e(si).tt=tt;
        e(si).name='Fix';
        e(si).onset=cumtime;
        e(si).duration=time.(tt).fix;
        e(si).func=@event_Fix;
        e(si).params={colors.Fix.(tt)};
        cumtime=cumtime+e(si).duration;

        %% Disp + Resp
        e(si+1).trl=t;
        e(si+1).tt=tt;
        e(si+1).name='Rsp';
        e(si+1).onset=cumtime;
        e(si+1).duration=time.(tt).wait;

        if strncmp('Nback',tt,5)
           seqidx=sum(randIdx(1:t)==1);
           e(si+1).func=@event_Nback;
           e(si+1).params={time.(tt).wait, ...
                           nbackseq{seqidx},...
                           isnback(seqidx) };
        else
           seqidx=sum(randIdx(1:t)==2);
           e(si+1).func=@event_Interfere;
           e(si+1).params={time.(tt).wait, ...
                           intseq{seqidx} };
        end

        cumtime=cumtime+e(si).duration;

      end

end
