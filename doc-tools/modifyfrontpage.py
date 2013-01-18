import argparse

# parse arguments

parser = argparse.ArgumentParser(description='Patch index.html with frontpagepatch.txt')

parser.add_argument('-i', required=True, action='store', dest='fin', 
                    help='path to index.html')

parser.add_argument('-p', required=True, action='store', dest='fpn', 
                    help='path to frontpagepatch.txt')

args = parser.parse_args()

#li2 = ''

with open(args.fpn, 'r') as fp:
    p = fp.read()

with open(args.fin, 'r') as fi:
    while True:
        li1 = fi.readline()
        if li1 == '':
            break
        if li1 == "<footer id=\"validator-badges\">\n":
            li1 = p + li1
        print li1,
