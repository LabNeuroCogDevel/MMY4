s = getSettings('init','Admin_PC'); % for MR timing

iti=zeros(s.events.nTrlNoNbk+1,1000);
for i = 1:length(iti)
                      % 40    1.7667    1
    iti(:,i) = genITI(s.events.nTrlNoNbk,s.time.ITI.mu,s.time.ITI.min);
end
save('iti_mix_nonbk.mat','iti');
max(abs(sum(iti) - s.time.ITI.mu*(s.events.nPureBlk+1)))

iti=zeros(s.events.nPureBlk+1,1000);
for i = 1:length(iti)
                      % 35  1.7667    1
    iti(:,i) = genITI(s.events.nPureBlk,s.time.ITI.mu,s.time.ITI.min);
end
save('iti_pure.mat','iti');

max(abs(sum(iti) - s.time.ITI.mu*(s.events.nPureBlk+1)))