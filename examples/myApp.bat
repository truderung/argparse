@echo off

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
    echo  - but unfortunately the flag --tall is valued wrongly
)

goto :eof

:error
goto :eof