#!/usr/bin/env python
import sys
import fnmatch
import os
from fileinput import FileInput


def replace_rec(str1, str2, path):
    for dirpath, dirs, files in os.walk(path, topdown=True):
        # pattern usable for match specific type of files
        file_pattern = "*"
        all_files = [os.path.join(dirpath, filename) for filename in fnmatch.filter(files, file_pattern)]

        # using File input to avoid reading all whole files in memory
        for line in FileInput(all_files, inplace=True):
            print(line.replace(str1, str2), end='')


if __name__ == "__main__":
    n_param = 3
    if len(sys.argv) == n_param:
        for i in range(len(sys.argv)):
            if not isinstance(sys.argv[i], str):
                print("Arg n" + str(i) + "incorrect type")
                exit()
        replace_rec(sys.argv[0], sys.argv[1], sys.argv[2])
    else:
        print("Invalid number of Arguments")
        print("Usage -> str1 str2 absolute_path")
        exit()
