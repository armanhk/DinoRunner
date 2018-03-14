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
file_at = open('data-at.txt','w')
t.start()
# file_me = open('data-me.txt','w')
# file_bl = open('data-bl.txt','w')

while True:
    # print(str(neuropy.attention))
    file_at.write(str(neuropy.attention))
    file_at.write('\n')
    # file_me.write(neuropy.meditation)
    # file_bl.write(neuropy.blink)
    # if neuropy.meditation > 70:
    #     neuropy.stop() 
    sleep(0.2) # Don't eat the CPU cycles