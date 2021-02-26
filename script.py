#!/usr/bin/python3
import os
import subprocess
from shutil import copyfile
import sys
# generate crashes directory
os.mkdir('crashes', 0o777)
# loop forever
i = 0
while(1):
    # generate tests in a directory
    r = subprocess.Popen(['/usr/local/bin/grammarinator-generate', '-p','output/JavaScriptUnparser.py','-l', 'output/JavaScriptUnlexer.py', '-r', 'program', '-d', '10', '-n', '300', '-o', 'tests/test.js'])
    if(r.stderr):
        print('Error generating files')
        print(r.stderr)
        exit(1)
    os.system('sed -i -e \'s/debugger//g\' tests/*')
    print('Generated tests')
    for subdir, _, files in os.walk('/home/tests'):
        for file in files:
            filepath = subdir + os.sep + file
            results = subprocess.run(['/home/'+sys.argv[1], filepath], capture_output=True)
            # check for segmentation fault
            if b'Fault' in results.stdout or b'Fault' in results.stderr:
                # if there is one move file to crashes directory
                copyfile(filepath, '/home/crashes/'+file+str(i))
                i += 1
            print('Ran ', filepath)
            # remove file after we have run it
            os.remove(filepath)
    print('Finished loop')
    print(str(i)+' crashes found')
    
    