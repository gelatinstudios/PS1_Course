@echo off

armips factorial.s
python ..\bin2exe.py factorial.bin factorial.ps-exe
