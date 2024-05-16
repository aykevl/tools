#!/usr/bin/env python3

# simple script to sync FLAC music files to an MP3 player (transcoded to aac)

from pathlib import Path
import sys
import queue
import threading
import os
import tempfile
import mutagen
import subprocess
import shutil
import multiprocessing

tagMap = {
    'title': '\xa9nam',
    'artist': '\xa9ART',
    'album': '\xa9alb',
    'date': '\xa9day',
    'albumartist': 'aART',
    'tracknumber': 'sonm',
}

def convert_worker(q):
    while True:
        job = q.get()
        srcpath = job['srcpath']
        srcext = os.path.splitext(srcpath)[1]
        if srcext == '.flac':
            print('Convert:', job['dstrelpath'])
            dstpath = job['dstpath']
            srctags = job['srctags']
            tmppath = dstpath + '.tmp'
            result = subprocess.run(['afconvert', '--file', 'm4af', '--data', 'aac', '--bitrate', '96000', srcpath, tmppath])
            if result.returncode != 0:
                print('Fail:   ', job['dstrelpath'])
                q.task_done()
                continue

            # copy tags
            dsttags = mutagen.File(tmppath)
            for tag in ['title', 'album', 'date', 'tracknumber']:
                if tag  in srctags:
                    dsttags[tagMap[tag]] = srctags[tag]
            # Handle artist separately (the MP3 player doesn't support
            # albumartist).
            artist = srctags.get('albumartist', srctags.get('artist'))
            if not artist:
                print('No artist:', job['dstrelpath'])
                q.task_done()
                continue
            dsttags[tagMap['artist']] = artist
            dsttags.save()

            os.rename(tmppath, dstpath)
            q.task_done()
        else:
            print('Copy:   ', job['dstrelpath'])
            q.task_done()


def sync(src, dst):
    q = queue.Queue(maxsize=1)
    for i in range(multiprocessing.cpu_count()):
        t = threading.Thread(target=convert_worker, args=(q,), daemon=True)
        t.start()

    print('syncing:', src, dst)
    srcdir = Path(src)
    pathlist = srcdir.glob('**/*.*')
    for srcpath in pathlist:
        srcext = os.path.splitext(srcpath)[1]
        if not srcext in ['.flac', '.mp3']:
            continue
        if srcext == '.mp3':
            dstext = '.mp3'
            # ignore MP3 for now
            continue
        else:
            dstext = '.m4a'
        relpath = os.path.relpath(srcpath, srcdir)
        srctags = mutagen.File(srcpath)
        if 'title' not in srctags or 'tracknumber' not in srctags:
            print('Skip:', relpath)
            continue
        tracknumber = srctags['tracknumber'][0]
        if '/' in tracknumber:
            tracknumber = tracknumber.split('/')[0]
        filename = '%02d %s%s' % (int(tracknumber), srctags['title'][0], dstext)
        filename = filename.replace('/', '~')
        filename = filename.replace('\\', '~')
        dstparent = os.path.join(dst, os.path.dirname(relpath))
        dstpath = os.path.join(dstparent, filename)
        dstrelpath = os.path.relpath(dstpath, dst)
        if not os.path.exists(dstpath):
            os.makedirs(dstparent, exist_ok=True)
            q.put({
                'srcpath': srcpath,
                'dstpath': dstpath,
                'dstrelpath': dstrelpath,
                'srctags': srctags,
            })

    # Wait until all jobs have finished processing.
    q.join()

if __name__ == '__main__':
    sync(sys.argv[1], sys.argv[2])
