% openPTBSnd:
%  init, stores, and returns pulse audio handle for PTB sound playback
%  - taken from BasicSoundOutputDemo.m
%  if called with args, e.g. openPTBSnd('close')
%   will close PTBsnd

function openPTBSnd(varargin)
  persistent pahandle

  % if we haven't opened a handle and we aren't trying to close it
  % open it up
  if isempty(pahandle) && isempty(varargin)
     nrchannels=1;
     InitializePsychSound;
     
     % Open the default audio device [], with default mode [] (==Only playback),
     % and a required latencyclass of zero 0 == no low-latency mode, as well as
     % a frequency of freq and nrchannels sound channels.
     % This returns a handle to the audio device:
     pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
 end
 

 % if we have an open handle
 % and we have arguments -- we want to close the handle
 if ~isempty(varargin) && ~isempty(pahandle)
  % Stop playback:
  PsychPortAudio('Stop', pahandle);
  % Close the audio device:
  PsychPortAudio('Close', pahandle);
  pahandle=[];
 end

end
