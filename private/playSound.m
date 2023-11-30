% play an incorrect noise for practice
% plays sound:        playSound(1,0); playSound(1,-1)
% doesn't play sound: playSound(0,.); playSound(.,1)
function playSound(ispractice,iscorrect)
 
 % skip if this isn't practice or we are correct
 if iscorrect>=1 || ~ispractice
  return
 end

 pahandle=openPTBSnd();

 persistent incrctsnd;

 if isempty(incrctsnd)
    filename='snd/incorrect.wav';
    % should still work if we are in private dir
    if ~exist(filename,'file'), filename=['../' filename];end

    [y, freq] = audioread(filename);
    % only want one channel
    incrctsnd= y(:,1)';
 end
 PsychPortAudio('FillBuffer', pahandle, incrctsnd);
 
 % Start audio playback for 1 repetitions of the sound data,
 % start it immediately (0) and do not wait (0) for the playback to start
 PsychPortAudio('Start', pahandle, 1, 0, 0);


end
