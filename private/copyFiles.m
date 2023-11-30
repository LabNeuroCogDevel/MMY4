% copyFiles:
%   copy any 'log.txt', '.csv', and '.mat' files of the
%   "savename" given as input to the function
function copyFiles(subj,dstr,savename)
 
 % setup smb
 %copybase='L:/bea_res/Data/Tasks/Switch_SPA/Behave';
 % 2023-11-30 copy to hera. automate copying to bea_res from there
 copybase='H:\Raw\Task\SwitchSPA\';
 host=getSettings('host');
 
 if isfield(host,'isBehave')
     copybase=fullfile(copybase,'Behave');
 end
 
 % we dont expect to find local mounts if we are at MR or MEG
 if  exist(copybase,'dir')
  savedir=[copybase '/' subj];
  mkdir(savedir);
  savedir=[savedir '/' dstr];
  mkdir(savedir);

  for ft = {'_log.txt','.mat','.csv'}
    fname=[savename ft{1}];
    if exist(fname,'file')
      copyfile(fname,savedir);
    else
      warning(['couldn''t find ' fname]);
    end
  end

 % we have ssh
 elseif 0 && isfield(host,'isMEG') && host.isMEG
  % setup ssh
  if exist('private/ssh','dir'),
    addpath('private/ssh');
  elseif exist('ssh','dir'),
    addpath('ssh');
  end
  sshhost='rhea.wpic.upmc.edu';
  spath=['/Volumes/L/bea_res/Data/Tasks/Switch_SPA/MEG/' subj '/' dstr ];
  fprintf('transfering to %s:%s\n',sshhost,spath);
  conn = ssh2_config(sshhost,'lncd','B@ngal0re');
  command_output = ssh2_command(conn,['mkdir -p ' spath] );
  for ft = {'_log.txt','.mat','.csv'}
    fname=[savename ft{1}];
    if exist(fname,'file')
        scp_put(conn, fname,spath);
    else
      warning(['couldn''t find ' fname]);
    end
  end
   

 else
     %MR doesn't have internet, no where to transfer (maybe e:)
     %warning(['cannot find ' copybase])
 end
 
end
