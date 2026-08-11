#!/usr/bin/env python3

# simple script to sync FLAC music files to an MP3 player (transcoded to aac)

from pathlib import Path
import sys
import queue
import threading
import os
import stat
import tempfile
import mutagen
import mutagen.easyid3
import subprocess
import multiprocessing
import platform

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
            print('Convert:  ', job['dstrelpath'])
            decodedpath = tempfile.NamedTemporaryFile().name
            result = subprocess.run(['flac', '--decode', '--silent', '--decode-through-errors', '--output-name='+decodedpath, srcpath])
            if result.returncode != 0:
                print('Fail decode:', job['dstrelpath'])
                q.task_done()
                continue
        elif srcext == '.mp3':
            print('Transcode:', job['dstrelpath'])

            decodedpath = tempfile.NamedTemporaryFile().name
            result = subprocess.run(['mpg123', '-q', '-w', decodedpath, srcpath])
            if result.returncode != 0:
                print('Fail decode:', job['dstrelpath'])
                q.task_done()
                continue
        else:
            print('TODO:     ', job['dstrelpath'])
            q.task_done()
            continue

        # Encode the file with AAC.
        command = ['afconvert', '--file', 'm4af', '--data', 'aac', '--bitrate', '96000', decodedpath, tmppath]
        if platform.system() == 'Linux':
            # bitrate mode 3 is ~96kbps (in theory)
            command = ['fdkaac', '--bitrate-mode=3', '--silent', '-o', tmppath, decodedpath]
        result = subprocess.run(command)
        if result.returncode != 0:
            print('Fail encode:', command)
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

        # rename to final name after the file is complete
        os.rename(tmppath, dstpath)

        # remove the temporary decoded file.
        os.remove(decodedpath)

        q.task_done()


def sync(src, dst):
    q = queue.Queue(maxsize=1)
    for i in range(multiprocessing.cpu_count()):
        t = threading.Thread(target=convert_worker, args=(q,), daemon=True)
        t.start()

    print('getting file list:', src, dst)
    srcdir = Path(src)
    pathlist = srcdir.glob('**/*.*')
    print('syncing...')
    seenfiles = set()
    for srcpath in sorted(pathlist):
        srcext = os.path.splitext(srcpath)[1]
        if not srcext in ['.flac', '.mp3']:
            continue

        if os.path.basename(srcpath).startswith('.'):
            continue

        relpath = os.path.relpath(srcpath, srcdir)

        # read tags per file type
        if srcext == '.mp3':
            dstext = '.m4a'
            try:
                srctags = mutagen.easyid3.EasyID3(srcpath)
            except mutagen.id3.ID3NoHeaderError:
                print('No ID3:   ', relpath)
                continue
        else:
            dstext = '.m4a'
            srctags = mutagen.File(srcpath)

        title = srctags.get('title', [''])[0]
        artist = srctags.get('artist', [''])[0]
        album = srctags.get('album', [''])[0]
        albumartist = srctags.get('albumartist', [''])[0]
        date = srctags.get('date', [''])[0]
        tracknumber = srctags.get('tracknumber', [''])[0]

        # Prefer albumartist over artist (the MP3 player doesn't support
        # albumartist so the artist list would get very long otherwise).
        if albumartist:
            artist = albumartist
        if not artist:
            print('No artist:', relpath)
            continue
        if not album:
            print('No album: ', relpath)
            continue
        if not title:
            print('No title: ', relpath)
            continue
        if not tracknumber:
            print('No track: ', relpath)
            continue
        if '/' in tracknumber:
            tracknumber = tracknumber.split('/')[0]
        filename = '%02d %s%s' % (int(tracknumber), title, dstext)
        filename = filename.replace('/', '~')
        filename = filename.replace('\\', '~')
        filename = filename.replace(':', '~')
        filename = filename.replace('?', '~')
        filename = filename.replace('*', '~')
        filename = filename.replace('"', '\'')
        dstparent = os.path.join(dst, os.path.dirname(relpath))
        dstpath = os.path.join(dstparent, filename)
        dstrelpath = os.path.relpath(dstpath, dst)
        seenfiles.add(dstrelpath)
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

    # Scan all files on the destination, see which ones don't exist in the
    # source.
    print('\n=================')
    print('checking for to-remove files...')
    dstpaths = Path(dst).glob('**/*.*')
    toremove = []
    totalsize = 0
    for dstpath in sorted(dstpaths):
        relpath = os.path.relpath(dstpath, dst)
        if relpath in seenfiles:
            continue
        st = os.stat(dstpath)
        if stat.S_ISDIR(st.st_mode):
            continue
        totalsize += st.st_size
        print('Remove:', relpath)
        toremove.append(dstpath)

    if toremove and input('Remove all these? (%.1fMB) ' % (totalsize / 1024 / 1024)).lower() in {'yes', 'y'}:
        for path in toremove:
            os.remove(path)


if __name__ == '__main__':
    sync(sys.argv[1], sys.argv[2])
