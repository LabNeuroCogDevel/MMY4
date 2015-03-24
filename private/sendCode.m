% sendCode(code) - sends event code using psychtoolbox
% only for MEG
% test code for MR  eixsts
function  tcOnset = sendCode(code)
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
   putvalue(DIOHANDLE,code);
   tcOnset=getSecs();
   fprintf('\t%d trigger \n',code);
   % reset code
   % putvalue(DIOHANDLE,0); 
   
 else
   fprintf('\t%d trigger (not sent)\n',code);
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
 
