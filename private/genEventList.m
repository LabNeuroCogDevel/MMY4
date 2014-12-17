
% block types is 1 (Nback), 2 (Interfere), or 1:2 for both
function e = genEventList(blocktypes)

      time   = getSettings('time');
      colors = getSettings('colors');
      nbks   = getSettings('nbk');
      events = getSettings('events');

      nbnum=nbks.nbnum;

      types={'Nback','Interfere', 'Congruent'};


      %% build conditions
      % if blocktype 1-3, single block
      % if 4, mixed random
      % if 5, mixed hardcoded
      %
      % also set total number of trials n based on blocktype
      % and get random sequences for display


      % block of all same type
      if blocktypes<=3
         % single block type, use different n
         n=s.events.nSingleBlk;
         % set randIdx to all of the block type we wnat
         randIdx=repmat(blocktypes,1,n);

         % rather than figure out which we want
         % generate a bunch of all
         [nbackseq, isnback] = genNbackSeq( nnz(randIdx==1),nbks.nprobe,nbnum );
         intseq   = genInterfereSeq(  nnz(randIdx==2) );
         [cngrseq, discard] = genNbackSeq( nnz(randIdx==3) );

      % generate mixed block
      elseif blocktypes==4
         n=events.nTrl;
         ntrltypes=length(types);
         if mod(n,ntrltypes)~=0
           error('number of events is not divs by %d!',ntrltypes)
         end
         nminiblock=events.nminblocks;
         nprobe=nbks.nprobe;

         [ttvec,nbk,inf,cng]=genMixed(n,ntrltypes,nminiblock,nprobe,nbnum);
         randIdx=ttvec;
         nbackseq=nbk.seq;
         isnback =nbk.bool;
         intseq  =inf.seq;
         cngseq  =cng.seq;
      
      % used fixed -- hardcoded
      elseif blocktypes==5
         error('no longer implemented correctly :)')
         [ randIdx, nbackseq, isnback, intseq,cngseq, nblocks ] = ...
            fixedMixedSeq(1);
         length(intseq)
         n=length(randIdx);

      else
         error('unknown blocktype %d',blocktyes);
      end
      
      %% generate ITI

      exptrialtime=2; % 2 seconds is cue+probe
      adjust=1;
      ITIs=zeros(1,n);
      while(abs(sum(ITIs)-(n+1)*exptrialtime) > .5 )
       ITIs=exprnd(exptrialtime-adjust,1,n+1)+adjust;
      end



      %% build events list
      
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
        e(si).duration=ITIs(t); %TODO: random ITI
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
