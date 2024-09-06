:: This is simply a script for demonstration. It executes myApp with different
:: arguments. Available args and the functionality itself are defined in myApp.
:: myApp uses argparse to manage the supplied arguments.

@echo off

(echo. ) & echo example 1: --name is not set
call myApp

(echo. ) & echo example 2
call myApp --name Peter

(echo. ) & echo example 3
call myApp --name Peter --tall

(echo. ) & echo example 4
call myApp --name Peter --tall no

(echo. ) & echo example 5
call myApp --name Love --gender female --tall false

(echo. ) & echo example 6
call myApp --name Love --gender unknown --tall false
