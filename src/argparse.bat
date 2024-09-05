:: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: argparse
:: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 
:: A submodule to realize parsing of arguments in batches.
:: 
:: Insert the call in following line to the top of your batch file, e.g.
:: call argparse <options> %*
::
:: argparse expects at least the argument <options>, as a string of
:: mandatory and possibly optional arguments, separated by ; (semicolon).
:: Arguments given left of ; are mandatory and right of ; are optional.
:: If no ; is given all arguments are interpreted as mandatory.
:: The order of defined arguments on the left and and on the right
:: is irrelevant.
:: 
:: Definition of arguments in options string:
:: - all arguments start with -
:: - all arguments end with :
::
:: Mandatory arguments have in addition:
:: - no default value
:: - multiple arguments are separated by space
:: e.g.: "-username:" or "-username: -password:"
::
:: Optional arguments have in addition:
:: - a default value
:: - multiple key-value pairs are separated by space
:: e.g.: "-username:paulo -high:160cm
::
:: Flags:
:: - are handled same as arguments, but are given without value
:: - given flags are set into environment as true; non-existent are set as false
:: - can be defined as both mandatory and optional, but it's not allowed to skip
::   an mandatory one.
::
:: Implementation inspired by:
:: - https://stackoverflow.com/questions/3973824/windows-bat-file-optional-argument-parsing/8162578#8162578
:: - https://stackoverflow.com/questions/55523387/local-variable-and-return-value-of-function-in-windows-batch
:: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 
:: usage: call argparse <options> %*
:: 
:: The argument <options> defines the api interface. The %* forwards
:: all received arguments to argparse. After call of argparse
:: forwarded keys and possible values are set as variables into the 
:: environment of the caller. Be aware of already exsistent variables!
:: argparse also deletes variables in the environment of correspondent
:: arguments before running itself.
::
:: In case the argument options is "-a: -b:;-c:5 -d: -e:point", argparse will
:: - expect -a and -b in forwarded arguments and print error if they are not given.
:: - preset -c to 5, -d (as flag) to true and -e to points.
:: Unknown arguments will cause also an error message. The return errorlevel
:: is on every occured error incremented.
::
:: Note that in options a : (colon) is used as delimiter.
:: But in forwarded argmuments a space or a = (equal sign)
:: is expected, as is usual.
::
:: Suppose options is equal "-a: -b:;-c:5 -d: -e:point".
:: Valid calls can look like:
:: a)
:: call argparse %options% -a cherry -b=homes
:: result: -a=cherry, -b=homes, -c=5, -e=point; -d does not exist in environment
:: b)
:: call argparse %options% -a=cherry -b homes -d
:: result: -a=cherry, -b=homes, -c=5, -d=true, -e=point
:: c)
:: call: argparse %options% -a cherry -b=homes -c=46
:: result: -a=cherry, -b=homes, -c=46, -e=point
:: d)
:: call: argparse %options% -b=homes -c=46
:: result: Error: Mandatory argument -a not given
::         -b=homes, -c=46
::
:: See more use cases in test cases.
::

@echo off

:: clear local from outer environment
for /f %%O in ('set - 2^>nul') do for /f "tokens=1,* delims==" %%A in ("%%O") do set "%%~A="

setlocal enableDelayedExpansion
set errlevel=0

set options=%~1
if "%options:~0,1%"==";" (
  set -optional_options=%options:~1%
) else (
  for /f "tokens=1,* delims=;" %%A in ("%options%") do set -mandatory_options=%%~A & set -optional_options=%%~B
)
shift /1

:: check given mandatory arguments
for %%O in (%-mandatory_options%) do for /f "tokens=1,2 delims=:" %%A in ("%%O") do (
  set "key=%%A"
  set "first_char=!key:~0,1!"
  set "value=%%~B"
  if "!value!" neq "" (
    echo Error: Default value '!value!' is not allowed on mandatory argument
    set /a errlevel+=1
  ) else if not "!first_char!"=="-" (
    echo Error: Invalid option '!key!'
    set /a errlevel+=1
  )
)

:: set optional arguments
for %%O in (%-optional_options%) do for /f "tokens=1,* delims=:" %%A in ("%%O") do (
  set "key=%%A"
  set "first_char=!key:~0,1!"
  if not "!first_char!"=="-" (
    echo Error: Invalid option '!key!'
    set /a errlevel+=1
  ) else (
    set "%%A=%%~B"
  )
)

:loop
if not "%~1"=="" (
  :: extract first group (%~1:) from options
  set "test=!options:*%~1:=! "
  if "!test!"=="!options! " (
    echo Error: Invalid option '%~1'
    set /a errlevel+=1
  ) else (
    :: echo valued option or mandatory flag
    setlocal disableDelayedExpansion
    set "val=%~2"
    call :escapeVal
    setlocal enableDelayedExpansion
    
    if "!val:~0,1!"=="-" (
      :: echo inner flag %~1
      endlocal
      endlocal
      set "%~1=true"
    ) else if "!val!"=="^=^^" (
      :: echo last flag %~1
      endlocal
      endlocal
      set "%~1=true"
    ) else (
      :: echo valued option %~1=!val!
      for /f delims^=^ eol^= %%A in ("!val!") do endlocal&endlocal&set "%~1=%%A" !
      shift /1
    )
  )
  shift /1

  goto :loop
)
goto :endArgs
:escapeVal
set "val=%val:^=^^%"
set "val=%val:!=^!%"
exit /b
:endArgs

:: check given mandatory arguments
for %%O in (%-mandatory_options%) do for /f "tokens=1,2 delims=:" %%A in ("%%O") do (
  if "!%%~A!"=="" (
    echo Error: Mandatory argument '%%A' not given
    set /a errlevel+=1
  )
)

for %%O in (%-optional_options%) do for /f "tokens=1,2 delims=:" %%A in ("%%O") do (
  if "!%%~A!"=="" set "%%A=false"
)

set -mandatory_options=
set -optional_options=

for /f "tokens=1,* delims==" %%A in ('set - 2^>nul') do (
  if defined _ret set _ret=!_ret!^& 
  set _ret=!_ret!set "%%A=%%B"
)

if defined _ret set _ret=!_ret!^& 
set _ret=!_ret!set "errorlevel=%errlevel%"

(
  endlocal
  %_ret%
)

exit /b %errorlevel%