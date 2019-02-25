"""
Test usage for Assembler of Project #1

Mert Kelkit - 150115013
Furkan Nakıp - 150115032
"""

from assembler import *


def main():
    assembler = Assembler('test.txt', 'outfile.hex')
    assembler.convert_hex()
    assembler.print_hex_file()


if __name__ == '__main__':
    main()


