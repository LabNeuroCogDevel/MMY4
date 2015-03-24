% copyFiles:
%   copy any 'log.txt', '.csv', and '.mat' files of the
%   "savename" given as input to the function
function copyFiles(subj,dstr,savename, varargin)
 addpath('private/ssh')
 copybase='B:/bea_res/Data/Tasks/Switch_MMY4/Behave';

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
 elseif ~isempty(varargin)
  spath=['/Volumes/GropeGate/Switch_MMY4/subj/' subj '/' dstr '/behave'];
  conn = ssh2_config('arnold.wpic.upmc.edu','lncd','B@ngal0re');
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
