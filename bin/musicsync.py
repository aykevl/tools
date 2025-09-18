#!/usr/bin/env python3

# simple script to sync FLAC music files to an MP3 player (transcoded to aac)

from pathlib import Path
import sys
import queue
import threading
import os
import tempfile
import mutagen
import mutagen.easyid3
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
        dstpath = job['dstpath']
        tmppath = dstpath + '.tmp'
        srcext = os.path.splitext(srcpath)[1]
        if srcext == '.flac':
            # Convert from FLAC to .wav, and then encode as AAC.
            # The .wav intermediary format may be needed in some cases when
            # afconvert can't read a particular file but the reference flac
            # decoder can.
            print('Convert:', job['dstrelpath'])
            wavpath = tempfile.NamedTemporaryFile().name
            result = subprocess.run(['flac', '--decode', '--silent', '--force', '--output-name='+wavpath, srcpath])
            if result.returncode != 0:
                print('Fail decode:', job['dstrelpath'])
                q.task_done()
                continue
            result = subprocess.run(['afconvert', '--file', 'm4af', '--data', 'aac', '--bitrate', '96000', wavpath, tmppath])
            if result.returncode != 0:
                print('Fail encode:', job['dstrelpath'])
                q.task_done()
                continue

            # copy tags
            dsttags = mutagen.File(tmppath)
            dsttags[tagMap['title']] = job['title']
            dsttags[tagMap['artist']] = job['artist']
            dsttags[tagMap['album']] = job['album']
            if job['date']:
                dsttags[tagMap['date']] = job['date']
            dsttags[tagMap['tracknumber']] = job['tracknumber']
            dsttags.save()

            os.rename(tmppath, dstpath)
        elif srcext == '.mp3':
            print('Copy:   ', job['dstrelpath'])

            # Copy the data.
            data = open(srcpath, 'rb').read()
            f = open(tmppath, 'wb')
            f.write(data)
            f.close()

            # copy tags
            dsttags = mutagen.easyid3.EasyID3(tmppath)
            dsttags['title'] = job['title']
            dsttags['artist'] = job['artist']
            dsttags['album'] = job['album']
            if job['date']:
                dsttags['date'] = job['date']
            dsttags['tracknumber'] = job['tracknumber']
            dsttags.save()

            os.rename(tmppath, dstpath)

        else:
            print('TODO:   ', job['dstrelpath'])

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

        # read tags per file type
        if srcext == '.mp3':
            dstext = '.mp3'
            srctags = mutagen.easyid3.EasyID3(srcpath)
        else:
            dstext = '.m4a'
            srctags = mutagen.File(srcpath)

        title = srctags.get('title', [''])[0]
        artist = srctags.get('artist')[0]
        album = srctags.get('album')[0]
        albumartist = srctags.get('albumartist', [''])[0]
        date = srctags.get('date', [''])[0]
        tracknumber = srctags.get('tracknumber', [''])[0]

        # Handle artist separately (the MP3 player doesn't support
        # albumartist).
        if not artist:
            artist = albumartist
        if not artist:
            print('No artist:', job['dstrelpath'])
            continue

        relpath = os.path.relpath(srcpath, srcdir)
        if not title or not tracknumber:
            print('Skip:', relpath)
            continue
        if '/' in tracknumber:
            tracknumber = tracknumber.split('/')[0]
        filename = '%02d %s%s' % (int(tracknumber), title, dstext)
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
                'title': title,
                'artist': artist,
                'album': album,
                'date': date,
                'tracknumber': tracknumber,
            })

    # Wait until all jobs have finished processing.
    q.join()

if __name__ == '__main__':
    sync(sys.argv[1], sys.argv[2])
