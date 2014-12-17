% print response for pretty output
%
% printRsp('Congru',t,seq,issamenback)
% printRsp('Interf',t,seq,0)
%
function printRsp(task,t,seq,isprobe)
  % use to decode t.seqCrct
  %         -1        0       1
  corincor={'NORESP','WRONG','correct'};

  %fprintf('\t%s',task);
  %if(isprobe); fprintf(' nbk'); end
  fprintf('\t%s',corincor{t.seqCrct+2}); 
  fprintf('\tRT: %.3f  ', t.seqRT );
  fprintf('%s ', seq{:});
  fprintf('=> %d | %d', t.crctKey, t.pushed );
  fprintf('\n');
end
