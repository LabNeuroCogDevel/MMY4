% copyFiles:
%   copy any 'log.txt', '.csv', and '.mat' files of the
%   "savename" given as input to the function
function copyFiles(subj,dstr,savename)
 copybase='B/rcn1/bea_res/Data/Tasks/Switch_MMY4/Behave'

 if  exist(copybase,'dir')
  savedir=[copybase '/' subj]
  mkdir(savedir)
  savedir=[savedir '/' dstr]
  mkdir(savedir)

  for ft = {'_log.txt','.mat','.csv'}
    fname=[savename ft{1}]
    if exist(fname,'file')
      copy(fname,savedir)
    end
  end
 end
 
end
