'''
Required classes for Assembler of Project #1

Mert Kelkit - 150115013
Furkan Nakıp - 150115032
'''

__all__ = ['Assembler']


class Assembler:
    def __init__(self, infile, outfile, mode='logisim'):
        """
        :param infile: file that contains instructions
        :param outfile: file that machine code will be written in it - should have .hex extension
        :param mode: can be Logisim or Verilog, if Logisim, "v2.0 raw" will be written on the head of output file
        """
        self.__infile = infile

        if '.hex' not in outfile:
            print('Output file should be a hex file !')
            exit(-1)
        self.__outfile = outfile

        self.__mode = mode
        # Define required params
        self.__hex_values = None
        self.__instructions = None

    def convert_hex(self):
        # Reads instructions from the input file
        self.__read_instructions()
        # Creates an converter object
        conv = Converter(self.__instructions)
        # Then convert instructions to hex code and get them from converter object
        conv.convert()
        self.__hex_values = conv.get_hex_codes()

    # Encapsulation method
    def get_hex_values(self):
        if self.__hex_values is not None:
            return self.__hex_values
        else:
            print('No converted hex values found!')

    # Used for generation of output hex file
    def print_hex_file(self):
        if self.__hex_values is not None:
            with open(file=self.__outfile, mode='w') as f:

                if self.__mode == 'logisim':
                    f.write('v2.0 raw\n')

                f.write('\n'.join(self.__hex_values))
        else:
            # If no converted hex values
            print('No converted hex values found!')

    def __read_instructions(self):
        with open(self.__infile, 'r', encoding='UTF-8') as f:
            # Read line by line (instruction by instruction)
            self.__instructions = f.readlines()
            # Then split them from newline characters
            self.__instructions = [i.strip() for i in self.__instructions]


class Converter:
    def __init__(self, instructions):
        """
        :param instructions: instructions red from input file
        """
        self.__instructions = instructions
        # List of binary codes
        self.__binary_code = []
        # List of hex codes, converted after binary conversion
        self.__hex_code = []
        # Specified unique opcodes for each instruction
        self.__opcode_dict = {
            'AND':  '0001',
            'ADD':  '0010',
            'LD':   '0011',
            'ST':   '0100',
            'ANDI': '0101',
            'ADDI': '0111',
            'CMP':  '1000',
            'JUMP': '1001',
            'JE':   '1010',
            'JA':   '1011',
            'JB':   '1100',
            'JBE':  '1101',
            'JAE':  '1110'
        }

    def convert(self):
        for instruction in self.__instructions:
            binary_code = ''

            split = instruction.split(' ')
            # First determine the operation from opcode dictionary
            operation = split[0]
            binary_opcode = self.__opcode_dict[operation]

            # Append corresponding opcode to the binary string of current instruction
            binary_code += binary_opcode

            # Then split all arguments like registers, addresses, immediate values etc.
            split_args = split[1].split(',')

            # If the operation is ADD or AND -- They have same form --
            if operation == 'ADD' or operation == 'AND':
                # Split all registers
                dest = split_args[0]
                src_1 = split_args[1]
                src_2 = split_args[2]
                # Send them to the corresponding method
                binary_register_values = self.__convert_registers_to_binary(dest=dest, src_1=src_1, src_2=src_2)
                # Then append the string to the binary code
                binary_code += ''.join(binary_register_values)

            # If operation is ADDI or ANDI -- They have same form --
            elif operation == 'ADDI' or operation == 'ANDI':
                # Split args - dest and src_1 are registers, imm is immediate value
                dest = split_args[0]
                src_1 = split_args[1]
                imm = split_args[2]

                # Since immediate can be negative or positive, determine it's sign
                sign = '1' if int(imm) < 0 else '0'
                # Then call corresponding methods for binary conversion
                binary_register_values = self.__convert_registers_to_binary(dest=dest, src_1=src_1)
                binary_imm = self.__convert_imm_to_binary(imm=imm)
                # After getting binary codes, append them to the binary code with proper order
                binary_code += ''.join(binary_register_values)
                binary_code += sign
                binary_code += ''.join(binary_imm)

            # If operation is LD
            elif operation == 'LD':
                # Split args - dest is the register, addr is an address in the data memory
                dest = split_args[0]
                addr = split_args[1]

                # Address value should be positive here
                if int(addr) < 0:
                    print('Address for LD must be greater than 0 !')
                    exit(-1)

                # Address can't be greater than 256 because 8 bits are allocated for them
                if int(addr) > 256:
                    print('Address can\'t be greater than 256 for LD !')
                    exit(-1)

                # Get binary representation of register and address
                binary_register_values = self.__convert_registers_to_binary(dest=dest)
                binary_addr = self.__convert_addr_to_binary(zero_pad=8, addr=addr)
                # Then append them to the binary code in proper order
                binary_code += ''.join(binary_register_values)
                binary_code += ''.join(binary_addr)

            # If operation is ST
            elif operation == 'ST':
                # Split arguments - src_1 is the source register, addr is an address in the data memory
                src_1 = split_args[0]
                addr = split_args[1]

                # Address value should be positive here
                if int(addr) < 0:
                    print('Address for ST must be greater than 0 !')
                    exit(-1)

                # Address can't be greater than 256 because 8 bits are allocated for them
                if int(addr) > 256:
                    print('Address can\'t be greater than 256 for ST !')
                    exit(-1)

                # Get binary representation of register and address, then append them to the binary code
                binary_register_values = self.__convert_registers_to_binary(src_1=src_1)
                binary_addr = self.__convert_addr_to_binary(zero_pad=8, addr=addr)
                binary_code += ''.join(binary_register_values)
                binary_code += ''.join(binary_addr)

            # If operation is CMP
            elif operation == 'CMP':
                # For padding purposes...
                binary_code += '0000'
                # Split args which are registers op_1 and op_2
                op_1 = split_args[0]
                op_2 = split_args[1]
                # Get binary representation of registers, then append them to the binary code
                binary_register_values = self.__convert_registers_to_binary(op_1=op_1, op_2=op_2)
                binary_code += ''.join(binary_register_values)

            # If operation is a derivative of JUMP...
            elif operation == 'JUMP' or operation == 'JE' or operation == 'JA' or operation == 'JB' \
                    or operation == 'JAE' or operation == 'JBE':

                # Get PC-relative address
                addr = split_args[0]
                """
                It must be between -2048 and 2047 in single instruction because 12 bits are allocated for them.
                Since it's PC-relative, it can be negative so it's between - 2^11 and 2^11 - 1 because of two's
                complement representation
                """
                if not -2048 < int(addr) < 2047:
                    print('PC-Relative address must be between -2048 and 2047 !')
                    exit(-1)

                # Determine sign of the address
                sign = '1' if int(addr) < 0 else '0'
                # Then append the sign bit
                binary_code += sign

                # Call corresponding method in order to convert address to the two's complement binary representation
                binary_addr = self.__convert_addr_to_binary(zero_pad=11, addr=addr)
                # Then append it to the binary code
                binary_code += ''.join(binary_addr)

            # Append each instruction's binary representation to the main list
            self.__binary_code.append(binary_code)
        # After converting all of the instructions to binary, then convert them 4 digit hexadecimal numbers
        self.__binary_to_hexadecimal()

    def __convert_registers_to_binary(self, **kwargs):
        binary_values = []
        for value in kwargs.values():
            # Split from R because registers are represented as R13, R7 etc.
            reg_no = int(value.split('R')[1])

            # Because there are 16 registers
            if reg_no > 15 or reg_no < 0:
                print('There are 16 register in processor !')
                exit(-1)

            binary_values.append(str(bin(reg_no))[2:].zfill(4))
        return binary_values

    def __convert_imm_to_binary(self, **kwargs):
        binary_values = []
        for value in kwargs.values():
            # Immediate value must be between -8 and 7 because 4 bits are allocated for them
            # and it's value can be positive or negative
            if not -8 < int(value) < 7:
                print('Immediate value should be between -8 and 7 !')
                exit(-1)

            # If imm value is negative
            if int(value) < 0:
                # Get it's two's complement representation
                # binary(|value| - 1) -> then flip bits
                abs_val = abs(int(value))
                bin_imm = str(bin(abs_val - 1))[2:].zfill(3)
                bin_inverted = []
                for c in bin_imm:
                    bin_inverted.append('0' if c == '1' else '1')
                binary_values.append(''.join(bin_inverted))
            # If imm is positive, convert binary directly
            else:
                binary_values.append(str(bin(int(value)))[2:].zfill(3))
        return binary_values

    def __convert_addr_to_binary(self, zero_pad, **kwargs):
        binary_values = []
        for value in kwargs.values():
            # If addr is negative
            if int(value) < 0:
                # Get two's complement representation
                abs_val = abs(int(value))
                # binary(|value| - 1) -> then flip bits
                bin_addr = str(bin(abs_val - 1))[2:].zfill(zero_pad)
                bin_inverted = []
                for c in bin_addr:
                    bin_inverted.append('0' if c == '1' else '1')
                binary_values.append(''.join(bin_inverted))
            # If it's positive, convert it directly
            else:
                binary_values.append(str(bin(int(value)))[2:].zfill(zero_pad))
        return binary_values

    # Return hex codes
    def get_hex_codes(self):
        return self.__hex_code

    # Convert binary to hexadecimal
    def __binary_to_hexadecimal(self):
        for b in self.__binary_code:
            self.__hex_code.append(str(hex(int(b, 2)))[2:].upper())
