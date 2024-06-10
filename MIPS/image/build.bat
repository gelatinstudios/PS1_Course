@echo off

armips image.s
python ..\bin2exe.py image.bin image.ps-exe
