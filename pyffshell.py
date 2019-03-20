import shlex, sys, os, readline, subprocess
daLoop = True
while daLoop:
    if len(sys.argv) < 2:
        print("You need a path to a video try again")
        exit()
    else:
        exists = os.path.isfile(sys.argv[1])
        if exists:
            print(sys.argv[1].split("."))
            fileExt = sys.argv[1].split(".")
            fileExt = fileExt[len(fileExt) - 1]
            print(fileExt)
            print(sys.argv[1] + " exists")
            process = subprocess.Popen(["ffprobe", "-i", sys.argv[1]], stdout=subprocess.PIPE)
            text = process.communicate()[0]
            print(text)
        else:
            print("It don't exist")
        exit()
