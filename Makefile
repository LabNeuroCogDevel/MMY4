.PHONY: octave-setup
all: octave-setup


octave-setup: Psychtoolbox-3/Psychtoolbox/PsychBasic/Octave5LinuxFiles64/Screen.mex
	grep -q Psychtoolbox-3 $(HOME)/.octaverc || \
	  octave --eval "cd('Psychtoolbox-3/Psychtoolbox/');SetupPsychtoolbox"
	octave --eval "try pkg('load','statistics'),1;catch,pkg('install','-forge','statistic'),end" # 'exprnd' in stats needed for MR ITI

Psychtoolbox-3/Psychtoolbox/PsychBasic/Octave5LinuxFiles64/Screen.mex:
	git clone --depth 1 https://github.com/kleinerm/Psychtoolbox-3
	cd Psychtoolbox-3/PsychSourceGL/Source/ && \
		octave --eval 'linuxmakeitoctave3'
	ldd $@ | grep not\ found && exit 1

ssh/:
	wget https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/e5881c25-4a80-11e4-9553-005056977bd0/e41839fb-9b33-47f4-9d94-60fce8395aa1/packages/zip/ssh2_v2_m1_r7.zip
	unzip -d sshtmp/ ssh2_v2_m1_r7.zip
	mv sshtmp/ssh2_v2* ssh/
    rm -r sshtmp/

###
# if gstream and libdc1394 match expected could just download.
# but then you're probably already on debian/ubuntu and should use neurodebian package
Psychtoolbox: DownloadPsychtoolbox.m
	octave --eval "DownloadPsychtoolbox('$(PWD)')"

DownloadPsychtoolbox.m:
	wget https://raw.github.com/Psychtoolbox-3/Psychtoolbox-3/master/Psychtoolbox/DownloadPsychtoolbox.m.zip
	unzip DownloadPsychtoolbox.m.zip
	rm DownloadPsychtoolbox.m.zip
lncdtask/:
	git clone git@github.com:LabNeuroCogDevel/lncdtask.git
