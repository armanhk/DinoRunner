from NeuroPy import NeuroPy
from time import sleep
from threading import Timer

def end_reading():
    file_at.close()
    # file_me.close()
    # file_bl.close()
    neuropy.stop()

neuropy = NeuroPy('COM4') 
neuropy.start()
t = Timer(10.0, end_reading)
file_at = open('data-bl.txt','w')
t.start()

while True:
    file_at.write(str(neuropy.blink))
    file_at.write('\n')
    sleep(0.2)