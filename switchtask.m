function switchtask(subjid, tasktype)
  %% SWITCHTASK - guided interface to run nBMSI
  if exist('OCTAVE_VERSION', 'builtin'), addpath('octave-shim'); end

  tasktypes = {'green', 'red', 'longmix1', 'longmix2', 'quit'};

  %% INFO
  fprintf('Welcome to the switch task\n');
  fprintf('This function guides you through running\n');
  fprintf('\tnBMSI SUBJECTID TYPE\n');
  fprintf('\t  SUBJECTID - lunaid of particiapnt like 12345\n')
  fprintf('\t  TYPE      - one of "green", "red", "longmix1", "longmix2"\n')
  fprintf('\t    green   ');
          fprintf('- congruent "pure" block (127 secs). like: 1 0 0\n');
  fprintf('\t    red     ');
          fprintf('- interfere "pure" block (138 secs). like: 3 2 2\n');
  fprintf('\t    longmix1');
         fprintf('- mixed block (425 secs)\n');


 % in octave this throws an implicit num to char warning?
 tasktypes_str = ['task type must be one of: ', strjoin(tasktypes, ', ')];

 %% loop until quit
 %while 1
     %% id check
     if nargin < 1
       subjid = input('Subject: ', 's');
     end
     while isempty(regexp(subjid, '^\d{5}$|^sub-'))
       disp('Bad subject id! enter 5 digit lunaid or "sub-XXXX" (where XXX is whatever)')
       subjid = input('Subject: ', 's');
     end

     %% task check
     if nargin < 2
       disp(tasktypes_str)
       tasktype = input('TaskType: ','s');
     end
     while ~ismember(tasktype, tasktypes)
       disp([tasktype, ' is not a valid task type!  ', tasktypes_str])
       tasktypes = input('TaskType: ', 's');
     end
     
     %% Run
     try
        nBMSI(subjid, tasktype);
     catch errormsg
         errormsg,
         warning('exited early or failed. trying again\n')
     end
     
%      ugly hack. copy paste code. change task type or quit
%      tasktype='';
%      while ~ismember(tasktype, tasktypes)
%        if ~isempty(tasktype), disp([tasktype, ' is not a valid task type! ']), end
%        disp(tasktypes_str)
%        tasktypes = input('TaskType: ', 's');
%      end
%      if ismember(tasktype,{'quit'}), break, end

     
%  end
end
