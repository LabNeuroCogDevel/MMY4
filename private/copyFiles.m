% copyFiles:
%   copy any 'log.txt', '.csv', and '.mat' files of the
%   "savename" given as input to the function
function copyFiles(subj,dstr,savename)
 % setup ssh
 addpath('private/ssh');
 addpath('ssh');
 sshhost='arnold.wpic.upmc.edu';
 
 % setup smb
 copybase='B:/bea_res/Data/Tasks/Switch_MMY4/Behave';

 host=getSettings('host');
 % we dont expect to find B if we are at MR or MEG
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
  spath=['/Users/lncd/rcn/bea_res/Data/Tasks/Switch_MMY4/MEG/' subj '/' dstr ];
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
