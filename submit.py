#!/usr/bin/env python3
import sys, os, json
import tempfile as tmp
import subprocess

# template-string for release-note
release_template = """
## v{version} Changelog
---
{changes}
"""

# get a dict in list-notation
unpack = lambda x: [(k, x[k]) for k in x]

# repack a list-dict into a dict
def pack( pairs ):
    d = {}
    for (k, v) in pairs:
        d[k] = v
    return d

# get only the unique items in the given list
def unique( items ):
    found = []
    return [(x, found.append(x))[0] for x in items if not (x in found)]

# open and edit a File with vim, and return it's content afterwards
def vimopen(txt=''):
    rns = tmp._RandomNameSequence()
    name = os.path.join(tmp.gettempdir(), rns.__next__()+'.md')
    f = open(name, 'w', 1)
    f.write( txt )
    f.close()
    os.system('vim '+name)
    f = open(name, 'r', 1)
    data = f.read()
    f.close()
    os.unlink( name )
    return data

# get the git-history since the last time we submitted
def command(cmd, args):
    p = subprocess.Popen(['ls', '-a'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=os.getcwd())
    out, err = p.communicate()
    return out, err

# get the git-history since the last time we committed
def git_history():
    output, error = command('git', ['log', '--pretty=format:" - %cr %s" -10'])
    return str(output).split('\n')

# get the haxelib.json data
def get_data():
    return json.load(open('haxelib.json', 'r', 1))

# save some JSON data to 'haxelib.json'
def set_data( changes ):
    data = unpack(get_data())
    data += unpack(changes)
    json_data = pack( data )

    json.dump(json_data, open('haxelib-test.json', 'w', 1), indent=4)

# handle version-number
def vnumber(curr, prev='0.0.0'):
    pb = prev.split('.')
    cb = curr.split('.')
    result = ['', '', '']
    i = 0
    while i < len(cb):
        c, p = (cb[i], pb[i])
        if c.strip() in ['', '_', '!']:
            result[i] = p
        elif c.startswith('+'):
            result[i] = str(int(p) + 1)
        else:
            result[i] = c
        i += 1
    return ('.'.join( result ))

# handle tags
def taglist(curr, prev=[]):
    tags = ([] + prev)

    if curr.startswith('-'):
        _strip = [t.strip() for t in curr[1:].strip().split(',')]
        tags = [t for t in tags if not (t in _strip)]

    elif curr.strip() == '':
        return prev

    else:
        tags += curr.strip().split(',')
    tags = unique(tags)
    return tags

# Prompt the user for update-info
def update_info():
    data = get_data()
    changes = {}
    # prompt the user for the new version number
    vn = input('version (currently '+data['version']+'): ')
    data['version'] = changes['version'] = vnumber(vn, data['version'])

    ntags = input('tags (currently '+(','.join(data['tags']))+'): ')
    data['tags'] = changes['tags'] = taglist(ntags, data['tags'])

    logs = []
    while True:
        l = input('changelog entry: ')
        if l.strip() == '':
            break
        else:
            logs.append(' - ' + l.strip())
    data['changes'] = '\n'.join( logs )
    release_note = vimopen(release_template.format( **data ))
    changes['releasenote'] = release_note
    return changes


def main(args):
    changes = update_info()
    print(json.dumps(changes, indent=4))
    
    set_data( changes )
    os.system('haxelib submit ./')

if __name__ == '__main__':
    args = sys.argv[1:]

    main( args )


