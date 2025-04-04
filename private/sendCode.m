% sendCode(code) - sends event code using psychtoolbox
% only for MEG
% test code for MR  eixsts
function  tcOnset = sendCode(code,varargin)
 tcOnset=0;
 
 persistent isMEG;
 persistent isEEG;
 persistent address;
 
 % get weither or not we are sending trigger codes
 % 20250117 isMEG or (new) isEEG
 if isempty(isMEG)
   h=getSettings('host');
   isMEG=h.isMEG;
   isEEG=h.isEEG;
   % replaces isempty(address) check. TODO(20250117): consolidate the two
   if isfield(h,'address')
      address = h.address
      addpath('C:\toolboxes\io64');
      config_io;
      outp(address,0);
   end
 end

 if ~ (isMEG || isEEG)
    %fprintf('\t%d trigger (not sent)\n',code);
    return
 end

 % make sure we have a diohandle to write to
 if(isempty(address))
     %DIOHANDLE=digitalio('parallel','lpt1');
     %addline(DIOHANDLE,0:7,0,'out');
     address=888;
     addpath('C:\toolboxes\io64');
     config_io;
     outp(address,0);
 end
 
 % write the trigger code out
 fprintf('\t%d trigger\n',code);
 %putvalue(DIOHANDLE,code);
 outp(address,code);
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
  %putvalue(DIOHANDLE,0); 
  outp(address,0);
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
 
