%%%%%%%%%%%%%%%%%%%%%%%%
% trigger is calcuated like:
%
% CUE 
%     want to know type (nbk,int,cng) and if it is first of kind
% x=1 2 3 + 3*isfirst
%   1-6
%
% SEQUENCE
%     want to know finger that should be pushed
%     and if it is a probe
% y= if(probe)
%       40+finger(1 2 3)
%    else
%      finger(1 2 3)*10 + x
%   
% RT
%   want to know if correct or incorrect, no response capture by ITI
%
%  iscorrect(1=yes 2=no)*100 + y
%    
% ITI           255          (end of trial, thought to subj, end of trial is at resp-- help ID noresp)
%%%%%%%%%%%%%%%%%%%%%%%%


%% triggers build on past triggers
% level = 0 resets
% level around 40 is used for probe
function trgt=getTrigger(level,value,varargin)
 %fprintf('\t * get trigger %d %d\n',level,value);
 persistent prev;
 if isempty(prev) || level < 1
    prev=0;
 end

 % if is probe, then we are 40 + correct key idx
 if(~isempty(varargin) && varargin{1})
   trgt= 40 + value;

 else
  trgt= prev + (10^level) * value;
 end
 %% dont count ITI in cumulative
 if(trgt<255)
   prev=trgt;
 end
 
end


%% getTrigger(prevcue, cue,keyToPush,probe,keyPushed)
% get what the trigger should be 
% given:
%  previous cou type
%  cuetype
%  key to push
%  correct or incorrect
%
% if keyToPush or keyPushed are zero or empty,
%   assume that part of the trial hasn't happened yet
%
% if cue is 0 or empty, assume ITI
%

% function trgt=getTrigger(prevcue,cue,keyToPush,probe,correct)
%  % we have decent input, yes?
%  if( min(prevcue,cue) <0 || max(prevcue,cue) > 3)
%    error('cues are not in range (prev %d, current %d)',prevcue,cue);
%  end
% 
%  % no cue means ITI
%  if(isempty(prevcue) || isempty(cue) || cue==0)
%   tgr=255;
%   return
%  end
% 
%  trgt =  ...
%    cue + 3*(prevcue~=cue) + ...
%    probe*(40+keyToPush) + ~probe * (keyToPush*10) ...
%    (keyPushed>0) * ((keyPushed==keyToPush)+1)*100
% 
% end



 % explicity: meh
 %% % add 3 to cue code if it's the first one
 %% if(prevcue ~= cue)
 %%   tgr=cue+3;
 %%   cue=cue+3;
 %% end

 %% % done if no key to push
 %% if(isempty(keyToPush) || keyToPush == 0)
 %%  return
 %% end


 %% % we have a key, code we send depends on probe status
 %% if probe
 %%  trg=40+keyToPush;
 %% else
 %%  trg=keyToPush*10 + cue;
 %% end 
 %% 
 %% % done if no key has yet been pushed
 %% if(isempty(keyPushed) || keyPushed == 0)
 %%  return
 %% end


