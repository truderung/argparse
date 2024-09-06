:: myApp expect --name as mandatory and except --gender and --tall as optional
:: arguments. Based on the input the output is, of course, for illustrative
:: purposes only.

@echo off

:: argparse is not in same directory, so the path is defined here
set src=%~dp0..\src

call %src%\argparse "--name:;--gender:male --tall:" %* || goto :error

echo I received this:
echo  - your name is %--name%
echo  - you're gender is %--gender%
if "%--tall%"=="true" (
    echo  - ... and you're tall
) else if "%--tall%"=="false" (
    if "%--gender%"=="male" (
        echo  - ... and you're a little man
    ) else if "%--gender%"=="female" (
        echo  - ... and you're absolutly fine.
    ) else (
        echo  - ... and you might be good.
    )
) else (
    echo  - but unfortunately the flag --tall is set incorrectly.
)

goto :eof

:error
goto :eof