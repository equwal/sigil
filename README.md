# Sigil

Generate documentation for sigil lines in the source, according to some input
documentation standard. This is intended to be the first pass in processing some
documentation.

This library is modified from that used to generate the docs for
[StumpWM](https://stumpwm.github.io/).

## Usage
Each "sigil" is a three character string must be at the beginning of the line,
and followed by a Common Lisp symbol. Some projects may need to define their own
sigils using `defdoc`.

Default included sigils:
```tex
@@@ function
%%% macro
### variable
```

### Texinfo
Currently the only supported output format is texinfo.

input:
``` tex
@c This is a texinfo comment. It will not be exported.
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
## Install
Requires SBCL, because `sb-introspect` is used. Support for other
implementations is welcome.

## Hacking
Write new sigils with the `defdoc` macro.

### TODO
- Be more general in supporting more output types than tex.
- Do not require sb-introspect, use other methods or leave out certain data as
  needed.

## License

GNU GPL v3

### _Spenser Truex <web@spensertruex.com>_
