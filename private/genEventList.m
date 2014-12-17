
% block types is 1 (Nback), 2 (Interfere), or 1:2 for both
function e = genEventList(n,blocktypes)

      time   = getSettings('time');
      colors = getSettings('colors');
      nbnum  = getSettings('nbnum');

      if mod(n,2)~=0
        error('number of events is not divs by 2!')
      end

      types={'Nback','Interfere', 'Congruent'};

      % used fixed -- force this -- hardcoded
      if blocktypes==5
         [ randIdx, nbackseq, isnback, intseq,cngseq, nblocks ] = ...
            fixedMixedSeq(1);
         length(intseq)
         n=length(randIdx);

      % block of all same type
      elseif blocktypes<=3
         randIdx=repmat(blocktypes,1,n);
         [nbackseq, isnback] = genNbackSeq( nnz(randIdx==1) );
         intseq   = genInterfereSeq(  nnz(randIdx==2) );
         [cngrseq, discard] = genNbackSeq( nnz(randIdx==3) );

      % generate mixed block
      elseif blocktypes==3
         %nbmu=4; nimu=2;
         %[ randIdx, nbackseq, isnback, intseq, nblocks ] = ...
         %   genEventMixed(n,nbmu,nimu,nbnum);
         [t,n,i,c]= genMixed(n,3,24,12,2);
         randIdx=t;
         nbackseq=nbk.seq;
         isnback =nbk.bool;
         intseq  =inf.seq;
         cngseq  =cng.seq;
      else
         error('unknown blocktype %d',blocktyes);
      end

      trlTypes=types(randIdx);

      cumtime=0;

      for t=1:n
        si=3*t -2;
        tt = trlTypes{t};

        %% ITI
        e(si).trl=t;
        e(si).tt=tt;
        e(si).name='Fix';
        e(si).onset=cumtime;
        e(si).duration=1; %TODO: random ITI
        e(si).func=@event_Fix;
        e(si).params={colors.iticross,0};
        cumtime=cumtime+e(si).duration;

        si=si+1;
        %% Fix
        e(si).trl=t;
        e(si).tt=tt;
        e(si).name='Cue';
        e(si).onset=cumtime;
        e(si).duration=time.(tt).cue;
        e(si).func=@event_Fix;
        e(si).params={colors.Fix.(tt)};
        cumtime=cumtime+e(si).duration;

        %% Disp + Resp
        si=si+1;
        e(si).trl=t;
        e(si).tt=tt;
        e(si).name='Rsp';
        e(si).onset=cumtime;
        e(si).duration=time.(tt).wait;

        if strncmp('Nback',tt,5)
           seqidx=sum(randIdx(1:t)==1);
           e(si).func=@event_Nback;
           e(si).params={time.(tt).wait, ...
                           nbackseq{seqidx},...
                           isnback(seqidx) };
        elseif strncmp('Interfere',tt,9)
           seqidx=sum(randIdx(1:t)==2);
           e(si).func=@event_Interfere;
           e(si).params={time.(tt).wait, ...
                           intseq{seqidx} };

        elseif strncmp('Congruent',tt,9)
           seqidx=sum(randIdx(1:t)==3);
           e(si).func=@event_Nback;
           e(si).params={time.(tt).wait, ...
                           cngseq{seqidx},...
                           zeros(1,length(seqidx)) };

        else
         error('unknown trial type: %s',tt);
        end

        cumtime=cumtime+e(si).duration;

      end

end
