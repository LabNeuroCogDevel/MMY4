#!/usr/bin/env python3
"""
NBMSI - n-Back Multi-Source Interference
port of matlab code for EEG in Luna SPA study (20250310)
"""
import itertools
import re
import pandas as pd
import numpy as np
import random
import wx
from psychopy import visual, event, core, gui
from lncdtask import lncdtask
from lncdtask.externalcom import ExternalCom, FileLogger, ParallelPortEEG
from typing import Optional, Tuple


def disp_cng_txt(rsp: int) -> str:
    """
    generate congruent text based on correct response key
    :param rsp: response 1 to 3
    :return: string rep like '1 0 0'
    >>> disp_cng_txt(2)
    '0 2 0'
    """
    dispvec = [0,0,0]
    dispvec[rsp-1] = rsp
    return " ".join([str(x) for x in dispvec])


def disp_inf_txt(rsp: int, distract: int, pos: int) -> str:
    """
    generate incongruent/interference text
    :param rsp: response 1 to 3
    :param distrcat: repeated number to distract participant
    :param pos: offset for odd-one-out. 0 is semi-congruent
    :return: string rep like '2 1 2'
    >>> disp_inf_txt(2,1,1)
    '1 1 2'
    >>> disp_inf_txt(3,2,0)
    '2 2 3'
    """
    dispvec = [distract]*3
    dispvec[(rsp-1+pos) % 3] = rsp
    return " ".join([str(x) for x in dispvec])


def gen_inf(crct_response, ncng) -> list[str]:
    """
    generate interference / incongruent block.
    :param crct_response: ideal responses [1,2,3,...]
    :param ncng: how many should be semi congruent
                 position matches odd-one-out (e.g. '1 2 1')
                 if None, equally distributed
                 2025-04-02: 0 == never seen for inf and mix
    :return: list of display strings ['1 1 2' '3 2 2']
    """
    # take out ncg, know positoin for those will be 0
    n = len(crct_response)-ncng
    # two ways to odd-one-out, shift positon by 1 or 2 places
    # '1' shifted by 1 gets places in 2nd slot: 'x 1 x'
    # '1' shifted by 2 to 3rd: 'x x 1'
    # '2' shifted by 2 (modulus 3) to 1st: '2 x x'
    pos = [1, 2]*(n//2+1)
    pos = pos[:n] + [0]*ncng
    # if we want to include ncng equally ('1 2 1' just as often as '2 1 1')
    if ncng is None:
        n = len(crct_response)
        pos = [0, 1, 2]*(n//3 + 1)

    # doesn't really matter if shift is repeated?
    # but this will "fairly" truncate if not easily divisile by 3
    pos = random_until(pos, len(crct_response), 3)

    # distracting non-odd-one-out can be either of the not target numbers
    # we'll just randomly select
    all_resp = {1, 2, 3}
    distract = [random.sample(list(all_resp-set([r])), 1)[0]
                for r in crct_response]

    return [disp_inf_txt(r, d, p)
            for r, d, p in zip(crct_response, distract, pos)]


def gen_trials_per_block(dist, total_trials):
    """
    shuffle count of trials for each blocks inf or cng block in mix
    :return: shuffled and balanced block distributin
    >>> x = gen_trials_per_block([6]*4 + [8]*2 + [10], 100)
    >>> len(x)  # 14 blocks
    14
    >>> x[0]  # always start with block of 6 trials
    6
    >>> sum(x)  # have 100 total trials
    100
    >>> sum(x[1::2])  # equally distributed between block types
    50
    >>> len([nt for nt in x[::2] if nt == 6]) # both should have 4 blocks of 6 trials
    4
    """

    # always start with 6
    # TODO: could always just start with the first element
    if dist[0] != 6:
        raise Exception("Expect dist of trials per block to start with 6")
    b1 = [6] + random_until(dist[1:], total_trials//2, 3)
    # second can be in any order
    b2 = random_until(dist, total_trials//2, 3)
    # interleave and flatten
    return list(itertools.chain(*zip(b1, b2)))


def gen_flankters(btype='cng',
                  crct_response=[1, 3, 2, 1],
                  ncng=4,
                  nblock=1,
                  cog_first=True,
                  trials_per_block=None):
    """
    :param btype: block type 'cng' or 'inf'
    :param crct_response: vector of correct responses. matches 
    :param ncng : number of congruent-ish trials '2 2 3' in inf TOTAL (floor division if nblock>1)
    :param nblock: how many blocks (inf + cng = 2)
    :param cog_first: in mix block, show cog first
    :param trials_per_block: trials per block. if None len(crct_response)//nblock
    >>> disp = gen_flankters('mix', [1,2,3]*4, ncng=4, nblock=2)
    >>> len(disp)
    12
    >>> disp[0][0]
    '1'
    >>> '3' in disp[-1].split(' ')
    True
    """
    # if 1: 1 0 0 for cng
    if btype == 'cng':
        return [disp_cng_txt(rsp) for rsp in crct_response]
    elif btype == 'inf':
        return gen_inf(crct_response, ncng)
    elif btype == 'mix':
        if nblock%2 != 0:
            raise Exception(f"Need an even number of blocks, got  {nblock}")
        if trials_per_block is None:
            blen = len(crct_response)//nblock # extras go into last block
            if blen*nblock != len(crct_response):
                raise Exception(f"number of trials {len(crct_response)} does not evenly fit into {nblock} blocks")
        else:
            if sum(trials_per_block) != len(crct_response):
                raise Exception(f"total number of trials {sum(trials_per_block)} does not match number of resposnes {len(crct_response)}")

        disp_seqs = []
        resp_idx = 0
        # go 2 blocks at a time
        for i in range(nblock//2):

            # did we manually specify the number of trials in each block?
            if trials_per_block is None:
                blen1 = len(crct_response)//nblock
                blen2 = blen1
            else:
                blen1 = trials_per_block[2*i]
                blen2 = trials_per_block[2*i + 1]

            start =  resp_idx
            mid   =  start + blen1
            end   =  mid + blen2
            resp_idx = end # update where we are overall

            resp_1 = crct_response[start:mid]
            resp_2 = crct_response[mid:end]
            if cog_first:
                cog_block = [disp_cng_txt(rsp) for rsp in resp_1]
                inf_block =  gen_inf(resp_2, ncng//nblock)
                disp_seqs.extend(cog_block + inf_block)
            else:
                inf_block =  gen_inf(resp_1, ncng//nblock)
                cog_block = [disp_cng_txt(rsp) for rsp in resp_2]
                disp_seqs.extend(inf_block + cog_block)

        return disp_seqs
    else:
        raise Exception(f"Do not know how to made sequences for {btype}")


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


def random_until(vec, n, max_rep_allowed):
    """
    shuffle until max rep criteria is met
    :param vec: input vector (maybe oversampled)
    :param n: final size of output
    :param max_rep_allowed: how many reps we can see
    :return: shuffled vec with out too many repeats
    """
    n_reps = max_rep_allowed + 1
    (i, max_iter) = (0, 1000)
    while n_reps > max_rep_allowed:
        random.shuffle(vec)
        resps = vec[:n] # truncate if we have too many
        n_reps = max_rep(resps)
        i = i + 1
        if i > max_iter:
            raise Exception(f"failed to converge generating random correct responses w/ fewer than {max_rep_allowed} repeats for sequence length {len(resps)}: {resps}")

    return resps

def gen_crct_response(n=35, max_rep_allowed=3) -> list[int]:
    """
    same number of each (even distributed responses)
    no repeat trains > 3
    :param n: number of trials (length of returned vector)
    :return: vector of length n, repeating 1 to 3 with
    >>> x = gen_crct_response(35,3)
    >>> len(x)
    35
    >>> max_rep(x) <= 3
    True
    """
    resps = []
    resp_options = [1,2,3]
    # if we ask for trials that cannot be evenly distirbuted go over total
    # will truncate later
    oversized = resp_options * int(np.ceil( n/len(resp_options)))

    # make sure we dont have too many repeats
    resps = random_until(oversized, n, max_rep_allowed)
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
             'cng': {'cue': .5, 'wait': 1.3}}

    #: inter trial interval times for EEG are fixed at .5
    #: originally in matlab for fMRI with variable iti
    iti_times = {'min': 1, 'max': 1.5}

    #: number of trials in a given block. TODO(20250317) match ML
    ntrials = {'mix': 100, 'cng': 35, 'inf': 35}
    #: one set of either inf or cng blocks. double for total (n=100)
    mix_trials_per_block = [6]*4 + [8]*2 + [10]

    #: in interference, how many are also congruent. eg. '1 2 1' (push key in congruent spot) cf. '1 1 2'
    nInfCng = 4

    #: number of miniblocks, number of switch envets = nminblocks -1 (7 total)
    nMiniBlock = 8

    #: how many of the same correct key can be in a row?
    max_rep_disp = 3

    #: cue type to color lookup
    cue_color = {'nbk': 'blue',
                 'inf': 'red',
                 'cng': 'green'}

    #: value sent to EEG recording based on disp_seq or iti or cue. NB 128 = start; 129 = stop
    trigger_lookup = {
            # event.send(128) happens in run code. allow for that here
            'start': 128, 128: 128,
            'stop': 129, 129: 129,
            'key 1': 2, # start at 2 b/c in habit task, 1 is photodiode
            'key 2': 3,
            'key 3': 4,
            'iti': 10,
            'cue': 50, # shouldn't be seen
            'cue cng': 51,
            'cue inf': 52,
            # congruent
            '1 0 0': 101,
            '0 2 0': 102,
            '0 0 3': 103,
            # 200 = incogruent/interference
            # 210 = expect 1
            '1 2 2': 211,  # semi-congruent
            '2 1 2': 212,  # no interference
            '2 2 1': 213,
            '1 3 3': 214,  # semi-congruent
            '3 1 3': 215,
            '3 3 1': 216,  # no interference
            # 220 = expect 2
            '2 1 1': 221,  # no interference
            '1 2 1': 222,  # semi-congruent
            '1 1 2': 223,
            '2 3 3': 224,
            '3 2 3': 225,  # semi-congruent
            '3 3 2': 226,  # no interference
            # 230 = expect 3
            '3 1 1': 231,  # no interference
            '1 3 1': 232,
            '1 1 3': 233,  # semi-congruent
            '3 2 2': 231,
            '2 3 2': 232,  # no interference
            '2 2 3': 233,  # semi-congruent
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

        # image to show for instructions. will update in insructions
        self.instructionpng = visual.ImageStim(self.win, name="instruct", interpolate=True, image='img/fingers.png')

    ## -- drawing/event functions
    def cue(self, onset=0, trial_type='MIA'):
        """ display fixation cross cue
        :param onset: time to show. unix epoc seconds. 0 = immediately
        :param trial_type: type to set color of cross. see :py:class:`NBMSI.cue_color`
                           will be black if given wrong type
        """
        self.trialnum = self.trialnum + 1
        self.cue_fix.height = .25 # 25% of screen
        self.cue_fix.color = self.cue_color.get(trial_type,'black')
        self.cue_fix.draw()
        return {**self.flip_at(onset, 'cue', trial_type) , 'trial': self.trialnum}

    def iti(self, onset=0):
        """ white fixation cross between trials
        :param onset: time to flip"""

        self.cue_fix.height = .25 # 25% of screen
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

        # keyboard will never have a buttonbox time
        # also set to None for no response
        bbtime = None 

        if self.response_from == 'keyboard':
            pushed = event.waitKeys(keyList=['1','2','3'],
                                maxWait=self.times[trial_type]['wait'])
            push_time = core.getTime()

        elif self.response_from == 'buttonbox':
            # TODO: check!
            (pushed, push_time, bbtime) = self.buttonbox.wait(self.times[trial_type]['wait'])
            pushed = [pushed] # match keyboard where multiple possible
        else:
            raise Exception("Unknown response_from type {self.response_from}")

        # no rt!
        if pushed is None or len(pushed) == 0:
        # default for no rt, no push. bbtime
            pushed = [None]

        self.externals.event(f"key {pushed[0]}")
        rt = push_time - onset

        # want next slide to launch immedetly 
        # so set duration of this current event to exactly now (RT)
        # on next iteration psychopy will be a few ms behind and launch iti right away
        self.onset_df.loc[self.event_number, 'dur'] = rt

        # TODO: score trial? nice to have for results.
        # but not needed and might slow down screen flip

        return {'flip': seq_flip['flip'],
                'rt': rt,
                'pushed': pushed,
                'bbtime': bbtime,
                'push_time': push_time}

    ## -- event/timing setup
    def gen_iti(self) -> dict:
        """
        inter trial interval settings
        """
        dur = random.uniform(self.iti_times['min'], self.iti_times['max'])
        return {'trial_type': '', 'event_name': 'iti',
                'dur': dur,
                'crct': 0, 'disp_seq': ''}

    def gen_trial(self, btype, crct, disp_seq):
        """
        trial events: iti, cue, seq
        """
        return [
            self.gen_iti(),
            {'trial_type': btype, 'event_name': 'cue',
             'dur': self.times[btype]['cue'],
             'crct': 0, 'disp_seq': ''},
            {'trial_type': btype, 'event_name': 'seq',
             'dur': self.times[btype]['wait'],
             'crct': crct, 'disp_seq': disp_seq}]

    def generate_timing(self, block_type):
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
        total_trials = self.ntrials[block_type]
        crct_resp = gen_crct_response(n=total_trials,
                                      max_rep_allowed=self.max_rep_disp)

        tpb = None
        if block_type == 'mix':
            tpb = gen_trials_per_block(self.mix_trials_per_block, total_trials)

        disp_seq = gen_flankters(btype=block_type,
                                 crct_response=crct_resp,
                                 ncng=self.nInfCng,
                                 nblock=self.nMiniBlock,
                                 cog_first=random.random() > .5,
                                 trials_per_block=tpb)
        # have computing seq component part separately
        # best way to get mix block type is test if is cog:
        #     is cog if '0' in disp text
        # if we want nback again, this will be trickier
        ttype = ['cng' if re.search('0', x) else 'inf' for x in disp_seq]

        events = [self.gen_trial(t, c, d)
                  for t, c, d in zip(ttype, crct_resp, disp_seq)]
        flattened = list(itertools.chain(*events)) + [self.gen_iti()]
        return pd.DataFrame(flattened)

    ## -- instructions
    def inst_welcome(self):
        self.msgbox.text = "Welcome to the LNCD switch task"
        self.msgbox.draw()
    def inst_keys(self):
        self.msgbox.text = "Your fingers correspond to numbers"
        self.msgbox.pos=(0, -.8)
        self.msgbox.draw()
        self.instructionpng.image = 'img/fingers.png'
        self.instructionpng.draw()
    def inst_goal(self):
      self.msgbox.text = 'In this game, you will see sets of 3 numbers.' + \
          '\n\nOne of the numbers will be different.' + \
          '\n\nAlways push the button for the DIFFERENT number.'
      self.msgbox.draw()
    def inst_inf(self):
        self.msgbox.pos = (-.25,0)
        self.msgbox.alignText = 'left'
        self.msgbox.setHorzJust = 'right'
        self.msgbox.text = \
            'This time, we are going to try to trick you with the RED cross.' +\
            'When the screen of numbers comes up after a RED cross,'+\
            '\n\n you will still push the button matching the different number.' +\
            '\n\nBut, make sure you are pushing the button matching the different number, NOT the location on the screen!'
        self.instructionpng.image ='img/interf.png'
        self.instructionpng.pos = (.5,0)
        self.msgbox.draw()
        self.instructionpng.draw()
    def inst_cng(self):

        self.msgbox.pos = (-.25,0)
        self.msgbox.text =\
            'First, you will practice the green cross trials\n\n' + \
            'Here, when the screen of numbers comes up after a GREEN cross,\n\n' + \
            'push the button that matches the different number.'
        self.instructionpng.image = 'img/congr.png'
        self.instructionpng.pos = (.5,0)
        self.msgbox.draw()
        self.instructionpng.draw()

    def inst_cng(self):

        self.msgbox.pos = (-.25,0)
        self.msgbox.text =\
            'First, you will practice the green cross trials\n\n' + \
            'Here, when the screen of numbers comes up after a GREEN cross,\n\n' + \
            'push the button that matches the different number.'
        self.instructionpng.image = 'img/congr.png'
        self.instructionpng.pos = (.5,0)
        self.msgbox.draw()
        self.instructionpng.draw()
    def inst_mix(self):
        self.msgbox.pos = (0,-.8)
        self.msgbox.text = 'This time you will see both GREEN and RED cues'
        self.msgbox.draw()
        self.instructionpng.image = 'img/instruct_cog_inf_only.png'
        self.instructionpng.draw()


    def instructions(self, run_num=1, block_type='mix'):
        """
        create and run through instruction slices.
        Use images from img/
        :param run_num: if first will show welcome slide
        :param block_type: cng, inf, and mix have different slides
        """
        slides = []
        if run_num == 1:
            slides.append(self.inst_welcome)

        slides.extend([self.inst_keys, self.inst_goal])

        if block_type == 'cng':
            slides.append(self.inst_cng)
        elif block_type == 'inf':
            slides.append(self.inst_inf)
        elif block_type == 'mix':
            slides.append(self.inst_mix)

        i=0
        while i < len(slides):
            if i < 0:
                i=0
            slides[i]()
            self.win.flip()
            core.wait(.3) # so we dont hammer the instructions
            # undo any text positoin changes
            self.msgbox.pos = (0,0)
            self.msgbox.alignText = 'center'
            self.msgbox.setHorzJust = 'center'
            keys = event.waitKeys()
            if 'up' in keys or 'left' in keys:
                i = i - 1
            else:
                i = i + 1

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
    nbmsi = NBMSI(win=win, externals=[printer])
    nbmsi.gobal_quit_key()  # escape quits
    nbmsi.DEBUG = True # not used (yet? 20250317)

    if run_info.info['ButtonBox']:
        nbmsi.response_from = 'buttonbox'
        nbmsi.buttonbox = Cedrus()

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
        nbmsi.externals.prepend(lpt)


    # added after lpt
    # timing more important to eyetracker than log file
    logger.new(participant.log_path(run_id))
    nbmsi.externals.append(logger)


    # RUN
    nbmsi.instructions(run_num, run_info.info['block'])
    lncdtask.wait_for_scanner(nbmsi.msgbox, trigger=None, msg="Ready? (Esc to quit)")
    nbmsi.run(end_wait=1)
    nbmsi.all_results().to_csv(participant.run_path(f"onsets_{run_num:02d}"))


    nbmsi.msgbox.height = .1 # 10% of screen. reset after seq()
    nbmsi.msg(f"Finished run {run_info.run_num()}!")
    nbmsi.win.close()


def run_nbmsi(parsed):
    """
    run all blocks of nbmsi with gui popup between blocks
    """
    participant = None
    #: RA facing names are friendlier than task names
    block_lookup = {'green': 'cng', 'red': 'inf', 'mix': 'mix'}
    run_info = lncdtask.RunDialog(
        extra_dict={
            'type': ['green','red','mix',],
            'fullscreen': True,
            'ButtonBox': True,
            'LPTport': "53264"},
        order=['subjid', 'run_num', 'timepoint',
               'type',
               'fullscreen', 'ButtonBox', 'LPTport'])

    # open a dialog and then a psychopy window for each run
    while True: # run_info.run_num() <= n_runs:
        if not run_info.dlg_ok():
            break
        block = block_lookup.get(run_info.info['type'])
        if block is None:
            error_msg = f"cannot run type '{run_info.info['type']}', expect 'green', 'red', or 'mix'"
            app = wx.App()
            wx.MessageBox(error_msg, 'Info', wx.OK | wx.ICON_INFORMATION)
            continue

        # add code name for block to run info
        run_info.info['block'] = block
        # update participant (logging info)
        if run_info.has_changed('subjid') or participant is None:
            participant = run_info.mk_participant(['switch'])

        nbmsi = run_block(participant, run_info)

        # remove block so it's not in the next dialog
        # RA sees and sets friendlier 'type'
        del run_info.info['block']

        # switch green<->red for second block
        # go to mix after second block
        run_info.info['run_num'] += 1
        if run_info.info['run_num'] <= 2:
            run_info.info['type'] = \
                'green' if run_info.info['type']=='red'  else 'red'
        else:
           run_info.info['type'] = 'mix'




class Cedrus():
    """ cedrus response box (RB-x40)
    top 3 right buttons are 5, 6, 7 (0-2 left, 3,4 thumb 5-7 right)"""
    def __init__(self):
        import pyxid2
        self.dev = pyxid2.get_xid_devices()[0]

        self.resp_to_key = {5: '1', #: left button(5) is keyboard '1' (idx)
                            6: '2', #: up (5) is keyboard '2' (mdl)
                            7: '3'  #: right (7) is keyboard '3' (ring)
                            } # 4 is down, not mapped to keyboard
        self.dev.reset_base_timer()
        self.dev.reset_rt_timer()
        # <XidDevice "Cedrus RB-840">


    def wait(self, max_dur=1.5) -> Tuple[str, float, float]:
        """
        :param max_dur: max wait time
        :return: keyboard like keypush ('1','2','3'),
                 core time,
                 RT buttonbox time
        """
        resp = '0'
        ctime = 0
        bbtime = 0
        start_time = core.getTime()

        # clear any hold overs. without this, every other trial has prev response
        # from https://github.com/cedrus-opensource/pyxid/blob/master/sample/responses.py
        self.dev.clear_response_queue()
        self.dev.flush_serial_buffer()

        while True:
            ctime = core.getTime()
            if ctime - start_time >= max_dur:
                break
            if not self.dev.has_response():
                self.dev.poll_for_response()
                core.wait(.0001)
            else:
                # only accept valid responses
                resp_raw = self.dev.get_next_response()
                #  {'port': 0, 'key': 5, 'pressed': True, 'time': 667489}
                resp = self.resp_to_key.get(resp_raw.get("key"))
                bbtime = resp_raw.get("time")
                if resp:
                    break
                else:
                    print(f"BAD Buttonbox key press?! {resp_raw}")

        return (resp, ctime, bbtime)


def main():
    import sys
    parsed = parse_args(sys.argv[1:])
    run_nbmsi(parsed)


if __name__ == "__main__":
    main()
