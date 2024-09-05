# argparse

A submodule to realize parsing of mandatory and optional arguments in batches.

Let's assume that argparse is in same directory as your script. Insert the call in following line to the top (or close to the top, of course) of your batch file and argparse will do the job:

```batch
call argparse <options> %*
```

But first things first ...

argparse expects at least the argument `options`, as a string of mandatory and/or optional arguments, separated by ; (semicolon). Arguments given left of ; are mandatory and right of ; are optional. If no ; is given all arguments are interpreted as mandatory. The order of defined arguments on the left of ; and on the right is irrelevant.

To come back to the example from above, set your options as 1st argument of argparse.
```batch
call argparse "-a: -b:;-c:5 -d: -e:point" %*
```

The arguments need to be defined in `options` as follows:
- put option string into quotation marks
- all arguments start with -
- all arguments end with :

Mandatory arguments have in addition:
- no default value
- multiple arguments are separated by space
e.g.: "-username:" or "-username: -password:"

Optional arguments have in addition:
- a default value
- multiple key-value pairs are separated by space
e.g.: "-username:paulo -high: 160cm

Flags:
- are handled same as arguments, but are given without value
- given flags are set into environment as true; non-existent are set as false
- can be defined as both mandatory and optional, but it's not allowed to skip an mandatory one


Implementation inspired by [this](https://stackoverflow.com/questions/3973824/windows-bat-file-optional-argument-parsing/8162578#8162578) and by [this](https://stackoverflow.com/questions/55523387/local-variable-and-return-value-of-function-in-windows-batch)


# usage

```batch
call argparse <options> %*
```

The argument <options> defines the api interface. The %* forwards
all received arguments to argparse. After call of argparse
forwarded keys and possible values are set as variables into the 
environment of the caller. Be aware of already exsistent variables!
argparse also deletes variables in the environment of correspondent
arguments before running itself.

In case the argument options is "-a: -b:;-c:5 -d: -e:point", argparse will
- expect -a and -b in forwarded arguments and print error if they are not given.
- preset -c to 5, -d (as flag) to true and -e to points.
Unknown arguments will cause also an error message. The return errorlevel
is on every occured error incremented.

Note that in options a : (colon) is used as delimiter.
But in forwarded argmuments a space or a = (equal sign)
is expected, as is usual.

Suppose options is equal to "-a: -b:;-c:5 -d: -e:point".
Valid calls can look like:

a)
```batch
call argparse %options% -a cherry -b=homes
```
results in: -a=cherry, -b=homes, -c=5, -e=point; -d does not exist in environment

b)
```batch
call argparse %options% -a=cherry -b homes -d
```
results in: -a=cherry, -b=homes, -c=5, -d=true, -e=point

c)
```batch
call: argparse %options% -a cherry -b=homes -c=46
```
results in: -a=cherry, -b=homes, -c=46, -e=point

d)
```batch
call: argparse %options% -b=homes -c=46
```
results in: Error: Mandatory argument -a not given, -b=homes, -c=46

e)
To improve error handling you might want to add an jump on error using the
returned errorlevel.
```batch
call: argparse %options% -b=homes -c=46 || goto :error
```

See more use cases in test cases or in examples.
