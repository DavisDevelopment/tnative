#!/usr/bin/env python3
import sys, os, json

def set_data(changes):
    data = json.load(open('haxelib.json', 'r', 1))
    
    for k in changes.keys():
        data[k] = changes[k]

    json.dump(data, open('haxelib.json', 'w', 1), indent=4)

def main(args):
    changes = {}
    for a in args:
        if a.startswith('v'):
            changes['version'] = (a[1:])
        else:
            changes['releasenote'] = a
    print( changes )
    set_data( changes )
    os.system('haxelib submit ./')

if __name__ == '__main__':
    args = sys.argv[1:]

    main( args )
