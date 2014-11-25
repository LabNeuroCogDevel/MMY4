%% clean up
function closedown()
      
    %fprintf('getting ListenChar back\n');
    ListenChar(0);
    
    %fprintf('getting Cursor back\n');
    ShowCursor;
    
    %fprintf('Closeing all screens\n');
    Screen('CloseAll');
    
    % At MEG, closing audio thats not open causes a crash
    % so lets only close the audio when it's open
    %v=version;
    % global a
    %if(~isempty(a) && str2double(v(1:3))>7.9 )    
    if PsychPortAudio('GetOpenDeviceCount')>0
        fprintf('Closeing all Audio\n');
        PsychPortAudio('Close');
    end
    
    %fprintf('Restoring priority\n');
    Priority(0);
    
    %fprintf('double clear screen\n');
    sca;
    
    %fprintf('closing diary\n');
    diary off;
    
    %fprintf('closing everything\n');
    close all;
end