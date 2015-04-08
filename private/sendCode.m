% sendCode(code) - sends event code using psychtoolbox
% only for MEG
% test code for MR  eixsts
function  tcOnset = sendCode(code,varargin)
 tcOnset=0;
 
 persistent isMEG;
 persistent DIOHANDLE;
 
 % get weither or not we are sending trigger codes
 if isempty(isMEG)
   h=getSettings('host');
   isMEG=h.isMEG;
 end

 if(isMEG) 
   % make sure we have a diohandle to write to
   if(isempty(DIOHANDLE))
       DIOHANDLE=digitalio('parallel','lpt1');
       addline(DIOHANDLE,0:7,0,'out');
   end
   
   % write the trigger code out
   fprintf('\t%d trigger\n',code);
   putvalue(DIOHANDLE,code);
   tcOnset=getSecs();

   % wait 100ms and send 0 to clear the triggers 
   %  so we dont have a sample above the desired value ( spikes in the trigger channel)
   %  the next time a trigger is sent
   % unless we said otherwise (e.g. with varargin={'dontsendzero'}  )
   %
   % this is most sketch when sending and clearing a code before waiting for keyboard input
   %   if we wait too long, we'll miss the key press!
   %   
   % and the wait could also throw off the timing if a response is made <.1s before the
   % end of the response window. then we'd wait to send 0 when when we should be flipping the next screen
   % so in this case we wont 0. conviently the following code is 255 (immune to spikes)
   if isempty(varargin)
    WaitSecs(.1);
    putvalue(DIOHANDLE,0); 
   end
   
 else
   %fprintf('\t%d trigger (not sent)\n',code);
 end

end
 
 %% MRI write to parallelPort
 % persistant address
 %elseif(0)
 %    if(isempty(address))
 %        % where the LPT1 port is
 %        % see device manager: mmc devmgmt.msc
 %        address=hex2dec('378');
 %        % where outp and inp are
 %        addpath('parallelPort/io32/win32/')
 %        % get settings? set conget?
 %        config_io
 %    end
 %    outp(address,code);
 %end
 
