# Coding
This folder contains matlab codes for Huffman encoding and decoding, Lempel-Ziv encoding and decoding, (7,4) Hamming code encoding, Syndrome decoding and Error generator.
Error generator function generates a bit error with probability 0.04.

The codes are combined in 'code.m' where the flow goes as below:

inputfile.txt(message) -- Huffman encoding --> huffmancode.txt -- Huffman decoding --> huffman_decoded.txt

inputfile.txt(message) -- Lempel-Ziv encoding --> lempelcode.txt -- Lempel-Ziv decoding -->lempel_decoded.txt

inputfile.txt(message) -- Huffman encoding --> huffmancode.txt --> (7,4) Hamming code encoding --> hammingcode.txt -- Error generator --> errorhammingcode.txt -- syndrome decoding --> syndromedecoded.txt -- Huffman decoding --> huffman_decoded_channel.txt
