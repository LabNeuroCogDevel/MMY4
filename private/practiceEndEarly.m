% subjects must get n correct in a row
% given results so far and the block type (1=nb,2=intf,3=cong)
% should we end early
function endnow = practiceEndEarly(res,blocktype)
 endnow=0;
 p=getSettings('pracsett');

 % get out of here if this isn't practice
 if ~p.ispractice; return; end
  
 % find the parts of results that have if we pushed 
 % the correct button
 ci = cellfun(@(x) isfield(x,'seqCrct'), res);
 respcell = res(ci);
 resp = cellfun(@(x) x.seqCrct, respcell)';


 % how many trials we need to have seen
 % depends on the block type
 if(blocktype==1)
   mintrial=p.nbk;
   
   % only care about probes if we are on nback
   ri = cellfun(@(x) x.probe, respcell);
   resp=resp(ri==1);

 elseif blocktype==2
   mintrial=p.intf;

 elseif blocktype==3
   mintrial=p.cong;

 else
   mintrial=p.mix;

 end

 %histc(resp,-1:1)
 nt=length(resp);

 % finish if last mintrial were good
 starti=max( 1, nt-mintrial+1 );
 endi  =max( nt, starti-mintrial );
 lastn=resp(starti:endi);
 lln=length(lastn);

 if lln >= mintrial &&  all( lastn == 1 )
    endnow=1
 end
 
 % 20150513 -- accuracy is hard to come back to
 %  just use window
 %
 % % if we've seen mintrials
 % % and we are pretty good at the task
 % nc= nnz(resp==1);
 % if( nt   >= mintrial && ...
 %    nc/nt >= p.mincorper )
 %   endnow=1;
 % end

end
