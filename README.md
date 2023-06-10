<img src="https://kekse.biz/php/count.php?draw&override=github:scripts&fg=120,130,40&size=48&v=16" />

# scripts/
Atm only [Bash](#bash) shell scripts. May grow..

## Index
1. [Bash](#bash)
	* [`prompt.sh`](#promptsh)
	* [`up2date.sh`](#up2datesh)
2. [Copyright and License](#copyright-and-license)

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

## Copyright and License
The Copyright is [(c) Sebastian Kucharczyk](./COPYRIGHT.txt),
and it's licensed under the [MIT](./LICENSE.txt) (also known as 'X' or 'X11' license).

