<img src="https://kekse.biz/php/count.php?draw&override=github:scripts&fg=120,130,40&size=48&v=16" />

# scripts/
Atm only [Bash](#bash) shell scripts. May grow..

## Index
1. [Bash](#bash)
	* [`prompt`.sh](#promptsh)
	* [`up2date`.sh](#up2datesh)
    * [`layout`.sh](#layoutsh)
2. [Snippets](#snippets)
    * [`count-all-lines`.sh](#count-all-lines)
    * [`fresh`.sh](#freshsh)
    * [`qemu`.sh](#qemush)
    * [`substring`.sh](#substringsh)
3. [Copyright and License](#copyright-and-license)

## Bash

### [`prompt`.sh](bash/prompt.sh)
Just copy this to `/etc/profile.d/prompt.sh`.. will change your `$PS1` prompt.
Uses the `$PROMPT_COMMAND` variable to dynamically change the prompt.

#### Screenshot
![$PS1](docs/prompt.sh.png)

### [`up2date`.sh](bash/up2date.sh)
Tool for [Gentoo](https://gentoo.org/) Linux, [Debian](https://debian.org/) and [Termux](https://termux.dev/) Linux.
I'm using it to do all steps to keep your packages `up2date`, in just one step!

Also, just copy it to `/etc/profile.d/up2date.sh`

### [`layout`.sh](bash/layout.sh)
See the comment on top of this file. Here's an example screenshot: ![layout.sh](docs/layout.sh.png)

## Snippets
Really tiny helper scripts, or one-liner, etc..

### [`count-all-lines`.sh](snippets/count-all-lines.sh)
Define a glob and search for them (only _real_ files), then print their line counts (sorted, ascending),
plus the total count in the last line.

### [`fresh`.sh](snippets/fresh.sh)
One command to 'fresh up' the current git repository.. ^\_^

### [`qemu`.sh](snippets/qemu.sh)
Starting `qemu` with some most common, configurable parameters (as I like them).. really nothing special!

### [`substring`.sh](dunno/substring.sh)
Short overview over the string substitution supported by the `bash`.. dug it out under 'knowledge/', so really
not worth to mention, but maybe a help if you need to write a shell script quickly.. so jfyi.

## Copyright and License
The Copyright is [(c) Sebastian Kucharczyk](./COPYRIGHT.txt),
and it's licensed under the [MIT](./LICENSE.txt) (also known as 'X' or 'X11' license).

