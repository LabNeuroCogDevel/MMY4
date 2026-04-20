from psychopy import core
import pyxid2

class Cedrus():
    """ cedrus response box (RB-x40)
    top 3 right buttons are 5, 6, 7 (0-2 left, 3,4 thumb 5-7 right)"""
    def __init__(self):
        self.dev = pyxid2.get_xid_devices()[0]

        self.resp_to_key = {5: '1', #: left button(5) is keyboard '1' (idx)
                            6: '2', #: up (5) is keyboard '2' (mdl)
                            7: '3',  #: right (7) is keyboard '3' (ring)
                            8: '4',
                            9: '5' 
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

    def close(self):
        """
        Need to close connection to or self.dev.flush_serial_buffer() will eventualy fail
        """
        del self.dev


def main():
    import sys

    i=0
    while True:
        print("Opening new cedrus object.")
        ced = Cedrus()
        while True:
            print("push a cedrus button.  3 to open new w/o close; 4. close existing. 5 to quit")
            (pushed, push_time, bbtime) = ced.wait(.5)
            i=i+1
            print("Pushed {pushed} at {push_time} ({bbtime})")
            if pushed == '3':
                sys.exit()
            elif pushed == '4':
                print("Restarting")
                i=0
                ced.close()
                ced=Cedurs()
                continue
            elif pushed == '5':
                print("New without close")
                continue
