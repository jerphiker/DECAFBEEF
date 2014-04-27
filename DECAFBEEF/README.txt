# INSTRUCTIONS FOR RUNNING:

# INSTALL REX AND RACC
source build_alamode.sh

# GENERATE CODE USING TOOLCHAIN
make

# RUN GENERATED CODE -- FILENAME should be replaced with a .src file and OUTPUT should be replaced with the desired output file prepend.
# OUTPUT defaults to OUTPUT producing OUTPUT.p, OUTPUT.a, OUTPUT.ir, and OUTPUT.err.
# Double quotes are optional ("OUTPUT" and OUTPUT produce the same output)
cat FILENAME | ruby1.9.3 lang0.tab.rb OUTPUT
