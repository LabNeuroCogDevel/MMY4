
% block types is -1 or 1 (Nback), -2 or 2 (Interfere), -3 or 3 (Cong), 0 or >=4 (Mix)
%
function [e mat] = genEventList(blocktypes)

      time   = getSettings('time');
      colors = getSettings('colors');
      nbks   = getSettings('nbk');
      events = getSettings('events');

      nbnum=nbks.nbnum;

      types={'Nback','Interfere', 'Congruent'};

      % all blocks greater than 4 are of type 4 (mix)
      % negative block types are practice
      % 0 is practice mix
      blocktypes=abs(blocktypes);
      if blocktypes > 3 || blocktypes == 0; blocktypes=4; end


      %% build conditions
      % if blocktype 1-3, pure block
      % if 4, mixed random
      % if 5,6 mixed
      % 20150122WF 
      %
      % also set total number of trials n based on blocktype
      % and get random sequences for display


      % block of all same type
      if blocktypes<=3
         % pure block type, use different n
         n=events.nPureBlk;
         % set randIdx to all of the block type we wnat
         randIdx=repmat(blocktypes,1,n);

         % generate the one we need
         %  nnz(randIDx... will be 0 for all but the type we want
         
         % working memory -- nback
         nbk = nbkMatchSettings( nnz(randIdx==1),nbks.pureBlkNprobe,nbnum,[] );

         % interference -- incongruent
         % second argument is number of "congruent" 
         [inf.seq, inf.seqi, inf.congidx] = ...
              genInterfereSeq( nnz(randIdx==2) , events.nInfPureCng );

         % congruent
         [cng.seq, junk, cng.seqi ] = ...
              genNbackSeq( nnz(randIdx==3), 0, 0 );

      % generate mixed block
      %  blocktypes transforemed at top of file to be between 1 and 4
      elseif blocktypes==4
         n=events.nTrl;
         ntrltypes=length(types);
         if mod(n,ntrltypes)~=0
           error('number of events is not divs by %d!',ntrltypes)
         end
         nminiblock=events.nminblocks;
         nprobe=nbks.nprobe;

         [ttvec,nbk,inf,cng] = genMixed(n,ntrltypes,nminiblock,nprobe,nbnum);
         randIdx=ttvec;
      
      % 20150122 WF - any num>4 is a mix block, nothing is hardcoded
      % used fixed -- hardcoded --
      %elseif blocktypes==5
      %   error('no longer implemented correctly :)')

      %   [ randIdx, nbackseq, isnback, infseq,cngseq, nblocks ] = ...
      %      fixedMixedSeq(1);
      %   length(infseq)
      %   n=length(randIdx);

      else
         error('unknown blocktype %d',blocktyes);
      end

      %% format outputs for putting into events
      %   ... accomidate old code
      nbackseq=nbk.seq;
      isnback =nbk.bool;
      infseq  =inf.seq;
      cngseq  =cng.seq;

      %% mat output 
      %   easier to parse then event structure
      mat.nbk=nbk;
      mat.inf=inf;
      mat.cng=cng;
      
      %% generate ITI
      %  fixation time should be about equal to task time
      %  NB. will wait full resp time after button push, so fix time will be greater
      %WF20150224 -- move into function
      ITIs=genITI(n,time.ITI.mu,time.ITI.min);


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
        e(si).duration=ITIs(t); 
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
           mat.crctkey(t)= nbk.seqi(seqidx);

           e(si).func=@event_Nback;
           e(si).params={time.(tt).wait, ...
                           nbackseq{seqidx},...
                           isnback(seqidx) };
        elseif strncmp('Interfere',tt,9)
           seqidx=sum(randIdx(1:t)==2);
           mat.crctkey(t)= inf.seqi(seqidx);

           e(si).func=@event_Interfere;
           e(si).params={time.(tt).wait, ...
                           infseq{seqidx} };

        elseif strncmp('Congruent',tt,9)
           seqidx=sum(randIdx(1:t)==3);
           mat.crctkey(t)= cng.seqi(seqidx);

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

%!test
%! getSettings('init','nbnum',3);
%! [e m] = genEventList(4);
%! %isprobe=find(cellfun(@(x) strncmp(x,'Rsp',3), {e.name}) & cellfun(@(x) strncmp(x,'Nback',5), {e.tt}))
%! 
