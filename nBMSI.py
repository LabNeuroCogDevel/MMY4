#!/usr/bin/env python3
"""
NBMSI - n-Back Multi-Source Interference
port of matlab code for EEG in Luna SPA study (20250310)
"""
import pandas as pd
import numpy as np
import random
from psychopy import visual, event, core
from lncdtask import lncdtask
from lncdtask.externalcom import ExternalCom, FileLogger, ParallelPortEEG
from typing import Optional
import time

#: these functions used to build onset_df in generate_timing
def gen_flankters(btype='cng', crct_response=[1,1,2,3,3,1]):
    # if 1: 1 0 0 for cng
    pass

def max_rep(vec:list) -> int:
    """
    :param vec: list with repeating values
    :return: max number of sequential repeats
    >>> (max_rep([1,2,3,1]), max_rep([1,1,3,1]), max_rep([1,1,3,3,3]))
    (1, 2, 3)
    >>> max_rep([1,2,2,2,2,3,1])
    4
    """
    # np.diff is nonzero if not a repeat
    # np.nonzero returns index where there's a new value
    idx = np.nonzero(np.diff(vec))
    idx = [-1, *idx[0], len(vec)-1] # make sure we have start and stop idx. okay to repeat -- diff will be 0
    # diff of those indices is how many repeats were between a changing value
    return int(np.max(np.diff(idx)))


def gen_crct_response(n=35, max_rep_allowed=3) -> list[int]:
    """
    same number of each (even distributed responses)
    no repeat trains > 3
    :param n: number of trials (length of returned vector)
    :return: vector of length n, repeating 1 to 3 with
    >>> x = gen_crct_response(35,3)
    >>> len(x)
    35
    >>> max_reps(x) <= 3
    True
    """
    resps = []
    resp_options = [1,2,3]
    # if we ask for trials that cannot be evenly distirbuted go over total
    # will truncate later
    oversized = resp_options * int(np.ceil( n/len(resp_options)))

    # make sure we dont have too many repeats
    n_reps = max_rep_allowed + 1
    (i, max_iter) = (0, 1000)
    while n_reps > max_rep_allowed:
        random.shuffle(oversized)
        resps = oversized[:n] # truncate if we have too many
        n_reps = max_rep(resps)
        i = i + 1
        if i > max_iter:
            raise Exception(f"failed to converge generating random correct responses w/ fewer than {max_rep_allowed} repeats")

    return resps


class NBMSI(lncdtask.LNCDTask):
    """
    modified n-back mutlisource interference main class.
    present congruent (green), incongruent/interference (red) or mixed. 

    No n-back -- removed from MR for timing reasons.
    """

    #: time in seconds for each event (n-back, interference, congruent)
    times = {'nbk': {'cue': .5, 'wait': 1.5},
             'inf': {'cue': .5, 'wait': 1.3},
             'cng': {'cue': .5, 'wait': 1}}

    #: inter trial interval times for EEG are fixed at .5
    #: originally in matlab for fMRI with variable iti
    iti_times = {'min': .5, 'mu': .5}

    #: number of trials in a given block. TODO(20250317) match ML
    ntrials = {'mix': 40, 'cng': 35, 'inf': 35}

    #: in interference, how many are also congruent. eg. '1 2 1' (push key in congruent spot) cf. '1 1 2'
    nInfCng = 4

    #: number of miniblocks, number of switch envets = nminblocks -1 (7 total)
    nMiniBlock = 8


    #: cue type to color lookup
    cue_color = {'nbk': 'blue',
                 'inf': 'red',
                 'cng': 'green'}

    #: value sent to EEG recording based on disp_seq or iti or cue. NB 128 = start; 129 = stop
    trigger_lookup = {
            'key 1': 1,
            'key 2': 2,
            'key 3': 3,
            'iti': 10,
            'cue': 50,
            # congruent
            '1 0 0': 101,
            '0 2 0': 102,
            '0 0 3': 103,
            # 200 = incogruent/interference
            # 210 = expect 1
            '1 2 2': 211, # congruent
            '2 1 2': 212,
            '2 2 1': 213,
            '1 3 3': 214, # congruent
            '3 1 3': 215,
            '3 3 1': 216,
            # 220 = expect 2
            '2 1 1': 221,
            '1 2 1': 222, # congruent
            '1 1 2': 223,
            '2 3 3': 224,
            '3 2 3': 225, # congruent
            '3 3 2': 226,
            # 230 = expect 3
            '3 1 1': 231,
            '1 3 1': 232,
            '1 1 3': 233, # congruent
            '3 2 2': 231,
            '2 3 2': 232,
            '2 2 3': 233, # congruent
            }

    response_from = 'keyboard' #: keyboard or buttonbox


    def ltp_lookup(self, disp_seq, **kargs):
        """
        Function for LTP/Parallel port external comm. Uses `trigger_lookup`.
        :param trial_number: sent for other externals. ignored here
        :param disp_seq: string triple of displayed numbers (e.g. '2 3 2')
        :return: 0-255 status channel value to send to EEG recording
        """
        return self.trigger_lookup.get(disp_seq,250)


    def __init__(self, *karg, **kargs):
        """ 

        >> win = create_window(False)
        >> onset_df= pd.DataFrame({'onset':[0], 'event_name':['ring']})
        >> printer = lncdtask.ExternalCom()
        >> tsk = NBMSI(win=win, onset_df=onset_df, externals=[printer])
        >> tsk.seq(disp='0 1 0')
        """
        super().__init__(*karg, **kargs)

        # extra stims/objects, exending base LNCDTask class
        self.trialnum = 0

        #: default background matches matlab grey
        #:  * matlab is 170 (/256)
        #:  * but psychopy -1 black to 1 white
        self.win.color = [0.33, 0.33, 0.33]
        # flip twice to get color change
        self.win.flip(); self.win.flip()
        
        #self.instructionpng = visual.ImageStim(self.win, name="instruct", interpolate=True, image='images/instructions.png')

        # events
        self.add_event_type('cue', self.cue, ['onset','trial_type'])
        self.add_event_type('seq', self.seq, ['onset','trial_type', 'disp_seq', 'crct'])
        self.add_event_type('iti', self.iti, ['onset'])

    # -- drawing functions
    def cue(self, onset=0, trial_type='MIA'):
        """ display fixation cross cue
        :param onset: time to show. unix epoc seconds. 0 = immediately
        :param trial_type: type to set color of cross. see :py:class:`NBMSI.cue_color`
                           will be black if given wrong type
        """
        self.trialnum = self.trialnum + 1
        self.cue_fix.color = self.cue_color.get(trial_type,'black')
        self.cue_fix.draw()
        return {**self.flip_at(onset, 'cue') , 'trial': self.trialnum}

    def iti(self, onset=0):
        """ white fixation cross between trials
        :param onset: time to flip"""
        self.cue_fix.color = 'white'
        self.cue_fix.draw()
        return(self.flip_at(onset, 'iti'))

    def seq(self, onset, trial_type='cng', disp_seq="0 0 0", crct_key=1):
        """position dot on horz axis to cue anti saccade
        position is from -1 to 1
        :param disp_sequence: 3 digit space separated sequence to show to participant
        :param crct_key: correct reponse key 1, 2, or 3
        """
        # hack to get dot size
        self.msgbox.color='black'
        self.msgbox.height = .25 # 25% of screen
        print(f"{self.trialnum} setting disp_seq to {disp_seq}")
        self.msgbox.text=disp_seq
        self.msgbox.pos=(0,0)
        self.msgbox.draw()
        seq_flip = self.flip_at(onset, disp_seq)
        # TODO: score trial
        if self.response_from == 'keyboard':
            pushed = event.waitKeys(keyList=['1','2','3'],
                                maxWait=self.times[trial_type]['wait'])
            push_time = core.getTime()

        elif self.response_from == 'buttonbox':
            pushed = [0]
            push_time = core.getTime()
        else:
            raise Exception("Unknown response_from type {self.response_from}")

        self.externals.event(f"key {pushed[0]}")
        rt = push_time - onset
        #self.update_dur()
        self.onset_df.loc[self.event_number, 'dur'] = rt
        return {'flip': seq_flip['flip'],
                'rt': rt,
                'pushed': pushed,
                'push_time': push_time}

    
    def generate_timing(self, block_type, dur=1.5, max_mix_rep=3):
        """
        generate timing with catches for rew and neutral
        not implemented, unfinished
        :param block_type: mix, cng, inf
        set onset_df (of the class); used by self.run() to actually run the task
        columns should include
        event_name, onset, dur, crct (key), disp_seq
        """

        # example one trial
        # columns should match those used by add_event_type above
        return pd.DataFrame([
            {'trial_type': 'cng', 'event_name': 'iti',
             'dur': self.iti_times['mu'], 'crct': 0, 'disp_seq': ''},
            {'trial_type': 'cng', 'event_name': 'cue',
             'dur': self.times['cng']['cue'], 'crct': 0, 'disp_seq': ''},
            {'trial_type': 'cng', 'event_name': 'seq',
             'dur': self.times['cng']['wait'], 'crct': 1, 'disp_seq': '1 0 0'},
            {'trial_type': 'cng', 'event_name': 'iti',
             'dur': self.iti_times['mu'], 'crct': 0, 'disp_seq': ''}])

        # TODO:
        # generate dataframe with:
        #  1. pseudo randomized  correct response per trial
        #     not too many repeates (<=3?)
        #  2. flanking distacors: 1 0 0
        #     inf for 2 could be: 1 2 1, 3 2 3; 2 3 3; 1 1 2; 3 3 2; 2 1 1
        #     TODO: in mablat, do we canre about congruent ish version
        #     TODO: random disit flankings


def parse_args(argv):
    import argparse
    parser = argparse.ArgumentParser(description='nBMSI (Switch) Task')
    parser.add_argument('--where', #nargs=1,
                        choices=["eeg"],
                        default="eeg",
                        help='where the experiment is run (different default settings)')
    parser.add_argument('--block_type', #nargs=1,
                        choices=["inf","cng","mix"],
                        default="cng",
                        help='How to run the task')
    parsed = parser.parse_args(argv)
    return parsed

def run_block(participant, run_info):

    printer = ExternalCom()
    logger = FileLogger()
    run_num = run_info.run_num()

    win = lncdtask.create_window(run_info.info['fullscreen'])
    # TODO: add lpt
    nbmsi = NBMSI(win=win, externals=[printer])
    nbmsi.gobal_quit_key()  # escape quits
    nbmsi.DEBUG = True # not used (yet? 20250317)

    # read_file_func goes through specified files
    # or defaults to original eprime task list
    onset_df = nbmsi.generate_timing(run_info.info['block'])
    # No onset. running on our own
    nbmsi.set_onsets(onset_df)

    # write to external files
    run_id = f"{participant.ses_id()}_task-switch_run-{run_num}"
    print(f"RUNNINFO: {run_info.info}")

    # EEG trigger in data recording
    if run_info.info['LPTport']:
        lpt = ParallelPortEEG(pp_address=run_info.info['LPTport'], lookup_func=nbmsi.ltp_lookup)
        # this goes first! most import timing is right for this
        nbmsi.externals.insert(0, lpt)


    # added after eyetracker
    # timing more important to eyetracker than log file
    logger.new(participant.log_path(run_id))
    nbmsi.externals.append(logger)


    # RUN
    #nbmsi.get_ready(triggers=triggers)
    nbmsi.run(end_wait=1)
    nbmsi.all_results().to_csv(participant.run_path(f"onsets_{run_num:02d}"))
    return nbmsi


def run_nbmsi(parsed):
    """
    run all blocks of nbmsi with gui popup between blocks
    """
    triggers = None
    participant = None
    n_runs = 4
    run_info = lncdtask.RunDialog(extra_dict={'block': ['cng','inf','mix'],
                                     'fullscreen': True,
                                     'ButtonBox': False, # TODO: update default to True
                                     'LPTport': "53264"},
                         order=['subjid', 'run_num', 'timepoint',
                                 'block',
                                'fullscreen', 'ButtonBox', 'LPTport'])

    # open a dialog and then a psychopy window for each run
    while run_info.run_num() <= n_runs:
        if not run_info.dlg_ok():
            break
        # update participant (logging info)
        if run_info.has_changed('subjid') or participant is None:
            participant = run_info.mk_participant(['switch'])
        nbmsi = run_block(participant, run_info)

        nbmsi.msgbox.height = .1 # 10% of screen. reset after seq()
        nbmsi.msg(f"Finished run {run_info.run_num()}/{n_runs}!")
        nbmsi.win.close()
            



class Cedrus():
    """ cedrus response box (RB-x40)
    top 3 right buttons are 5, 6, 7 (0-2 left, 3,4 thumb 5-7 right)"""
    def __init__(self, hw, kb):
        import pyxid2
        self.dev = pyxid2.get_xid_devices()[0]
        self.dev.reset_base_timer()
        self.dev.reset_rt_timer()
        self.resp_to_key = {5: Key.left, 6: Key.up, 7: Key.right, 4: Key.down}
        self.light_ttl = 1
        self.resp_to_ttl = {5: 2, 6: 3, 7: 4}
        # <XidDevice "Cedrus RB-840">

    def trigger(self, response):
        """ todo response number to ttl value translation
        port 0 is button box
        port 2 is photodiode/light sensor. always release. only when bright from dark
        """
        # {'port': 0, 'key': 7, 'pressed': True, 'time': 13594}
        # {'port': 2, 'key': 3, 'pressed': True, 'time': 3880}

        if response['pressed']:
            if response['port'] == 2:
                self.hw.send(self.light_ttl)
            if self.kb and response['port'] == 0:
                rk = response.get("key")
                ttl = self.resp_to_ttl.get(rk)
                key = self.resp_to_key.get(rk)
                if ttl:
                    self.hw.send(ttl)
                if key:
                    self.kb.push(key)
                print(f"pushed ttl: {ttl}; key: {key}; resp: {response}")
                sys.stdout.flush()

    def wait(self, max_dur=1.5) -> Optional[int]:
        resp = None
        ctime = 0
        start_time = core.getTime()
        while True:
            ctime = core.getTime()
            if ctime - start_time >= max_dur:
                break
            if not self.dev.has_response():
                self.dev.poll_for_response()
                sleep(.0001)
            else:
                resp = self.dev.get_next_response()
                break
        return (resp, ctime)


def main():
    print("working on it")
    import sys
    parsed = parse_args(sys.argv[1:])
    print(parsed)
    run_nbmsi(parsed)


if __name__ == "__main__":
    main()
