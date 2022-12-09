import fileinput
import re
import sys
import fnmatch
import os
from fileinput import FileInput


def find_shebang(shebang_pattern):
    dir = os.getcwd()
    all_files = [os.path.join(dir, f) for f in os.listdir(dir) if os.path.isfile(os.path.join(dir, f))]
    dic_unique = {}
    with fileinput.input(files=all_files, encoding="utf-8") as f:
        for line in f:
            pattern = re.compile(f"^#!{shebang_pattern}")
            print(pattern)
            if pattern.match(line):
                dic_unique[line] = dic_unique.get(line, 1)
                fileinput.nextfile()

    for elem in dic_unique.keys():
        print(str(dic_unique[elem]) + "  " + elem)


if __name__ == "__main__":
    n_param = 1
    if len(sys.argv) == n_param:
        if not isinstance(sys.argv[0], str):
            print("Arg n 1 have incorrect type")
            exit()
        find_shebang(sys.argv[0])
    else:
        print("Invalid number of Arguments")
        print("Usage -> str1 str2 absolute_path")
        exit()
