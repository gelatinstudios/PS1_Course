@echo off

armips fillmem.s
python ..\bin2exe.py fillmem.bin fillmem.ps-exe