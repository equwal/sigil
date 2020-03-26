# Sigil

Generate source documentation inside of texinfo files with short macros.

``` tex
@c defun is a macro defined in the standard.
%%% defun
```
Which expands to:
```
@c defun is a macro defined in the standard.
@defmac {defun} name lambda-list &body body
Define a function at top level.
@end defmac
```
This has been used to generate the docs for [StumpWM](https://stumpwm.github.io/).

## Install
Requires SBCL, because `sb-introspect` is used. Support for other
implementations is welcome.

## Hacking
Write new forms with the `defdoc` macro.

### TODO

- Be more general in supporting more output types than tex.

## License

GNU GPL 2.0

### _Spenser Truex <web@spensertruex.com>_
