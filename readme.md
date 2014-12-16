# n-Back Modified Multi-Source Interference Task
task switching between interference/incongruent oddball selection and n-back congruent oddball selection/recall

## run
in `octave` or `matlab` with [`PTB`](http://psychtoolbox.org/download/)

```matlab
subj='subjname' % subjectname for matfile
runtype=3       % 1=nback,2=interference,3=mixed, 4=hard coded sequence

nBMSI(subj,runtype)
```

## Install
```matlab
% PTB
urlwrite('https://raw.github.com/Psychtoolbox-3/Psychtoolbox-3/master/Psychtoolbox/DownloadPsychtoolbox.m','DownloadPsychtoolbox.m')
DownloadPsychtoolbox
```

``` bash
# get task
git clone https://github.com/LabNeuroCogDevel/MMY4.git
cd MMY4
```

## Citations
* MSIT: http://www.nature.com/nprot/journal/v1/n1/full/nprot.2006.48.html
* PTB: ??
