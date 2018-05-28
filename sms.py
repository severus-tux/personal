#!/usr/bin/python
import re
import time
import urllib.request
import urllib.parse

def sendSMS(apikey, numbers, sender, message):
    data =  urllib.parse.urlencode({'apikey': apikey, 'numbers': numbers,
        'message' : message, 'sender': sender})
    data = data.encode('utf-8')
    request = urllib.request.Request("https://api.textlocal.in/send/?")
    f = urllib.request.urlopen(request, data)
    fr = f.read()
    return(fr)


while 1:

    html_content = urllib.request.urlopen('http://www.cmi.ac.in//admissions/entrance-results-2018.php').read().decode('utf-8')
    #print (html_content)
    matches = re.findall('C-', html_content) # Because Computer Science Starts as C-BLR-0006
	
    if len(matches) == 0:
       print ("Yeah, Result Not Declared. Going to sleep") #will not send anything
       time.sleep(10) #sleep for 2 hours
    
    else:
       selected = re.findall('18200613', html_content)#18200613
       
       if len(selected) == 0:
           
           msg="CMI Results are Out! You are NOT Selected"
           res = sendSMS('XVuUR2zqhZE-KbZQQD4MwO10UjIpyGdAD16Wr2imtQ', '919481212950', 'TXTLCL', msg)
       
       else:
           
           msg="CMI Results are Out! You are Selected :) "
           res = sendSMS('XVuUR2zqhZE-KbZQQD4MwO10UjIpyGdAD16Wr2imtQ', '919481212950', 'TXTLCL', msg)
           
       print (res)
       quit()
