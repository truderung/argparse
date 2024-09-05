@echo off

set spath=%~dp0
set src=%spath%..\src\scripts
set command=argparse.bat
set failcounter=0
pushd %spath%
cd %src%

cls
title TEST argparse.bat

echo.
echo ----------------------------------------------------------
echo TEST argparse
echo ----------------------------------------------------------
echo.

if not exist %command% call :exception "%command% existiert nicht"

set options="-a: -b:;-c:5 -d: -e:point"

call %command% %options% -a cherry -b=homes || call :exception
call :assert "%-a%" cherry
call :assert "%-b%" homes
call :assert "%-c%" 5
call :assert "%-d%" false
call :assert "%-e%" point

call %command% %options% -a=cherry -b homes || call :exception
call :assert "%-a%" cherry
call :assert "%-b%" homes
call :assert "%-c%" 5
call :assert "%-d%" false
call :assert "%-e%" point

call %command% %options% -a -b=homes || call :exception
call :assert "%-a%" true
call :assert "%-b%" homes
call :assert "%-c%" 5
call :assert "%-d%" false
call :assert "%-e%" point

call %command% %options% -a -b homes -d || call :exception
call :assert "%-a%" true
call :assert "%-b%" homes
call :assert "%-c%" 5
call :assert "%-d%" true
call :assert "%-e%" point

call %command% %options% -d -b homes -a= || call :exception
call :assert "%-a%" true
call :assert "%-b%" homes
call :assert "%-c%" 5
call :assert "%-d%" true
call :assert "%-e%" point

call %command% %options% -a -d -b homes -e parade || call :exception
call :assert "%-a%" true
call :assert "%-b%" homes
call :assert "%-c%" 5
call :assert "%-d%" true
call :assert "%-e%" parade

call %command% %options% -a="space in string" -d -b homes || call :exception
call :assert "%-a%" "space in string"

:: double quote is missing around "not allowed"
call %command% %options% -a=not allowed -d -b homes >nul 2>&1 && call :missed_exception || call :expected_exception
:: mandatory -a is not set
call %command% %options% -d -b homes >nul 2>&1 && call :missed_exception || call :expected_exception
:: unknown argument -q
call %command% %options% -a -b homes -q >nul 2>&1 && call :missed_exception || call :expected_exception

:: default value on mandatory argument -a is not allowed
set options="-a:not -b:;-c:5 -d: -e:point"
call %command% %options% -a=cherry -d -b homes >nul 2>&1 && call :missed_exception || call :expected_exception

:: mistake in options: -a has no :
set options="-a;"
call %command% %options% -a=cherry >nul 2>&1 >nul 2>&1 && call :missed_exception || call :expected_exception

:: no ; is allowed: means all parameters are mandatory
set options="-a: -b:"
call %command% %options% -a cherry -b || call :exception

:: no existence of mandatory arguments is allowed
set options=";-c:5 -d: -e:point"
call %command% %options% || call :exception
call :assert "%-c%" 5
call :assert "%-d%" false
call :assert "%-e%" point

:: no existence of optional arguments is allowed
set options="-a: -b:;"
call %command% %options% -a -b || call :exception

:: spaces in key:value definition are not allowed
set options=";-c: 5 -d: -e:    point"
call %command% %options% >nul 2>&1 && call :missed_exception || call :expected_exception


goto :ende


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: subfunctions ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:expected_exception
echo | set /p dummy=^.
goto :eof

:missed_exception
echo F (exception expected, but no catched)
set /a failcounter+=1
goto :eof

:exception
set /a failcounter+=1
echo F (unexpected exception)
goto :eof

:error
set /a failcounter+=1
echo F (%~1)
goto :eof

:assert
if "%~1"=="%~2" ( echo | set /p dummy=^.) else call :error "assert failed: %~1==%~2"
goto :eof

:not_assert
if "%~1" neq "" ( echo | set /p dummy=^.) else call :error "not_assert failed: %~1"
goto :eof

:ende
popd
echo.
echo.
echo.
if %failcounter%==0 ( echo TEST PASSED.) else echo TEST FAILED, %failcounter% BROKEN CASES.
pause