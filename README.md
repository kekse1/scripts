<img src="https://kekse.biz/php/count.php?draw&override=github:scripts&text=`scripts`&draw" />

## Index
1. [News](#news)
2. [Bash](#bash)
	* [`prompt`.sh](#promptsh)
	* [`up2date`.sh](#up2datesh)
    * [`layout`.sh](#layoutsh)
    * [`make-nodejs`.sh](#make-nodejssh)
    * [Snippets and one-liners](#bash/snippets-and-one-liners)
        * [`chmod`.sh](#chmodsh)
        * [`count-all-lines`.sh](#count-all-linessh)
        * [`fresh`.sh](#freshsh)
        * [`qemu`.sh](#qemush)
        * [`substring`.sh](#substringsh)
3. [Copyright and License](#copyright-and-license)

## News
* Just increased the minor version of the `prompt.sh`, to v1.1.0. Changed the first 'arrow' and it's color. :)~

## [Bash](bash/)

### [`prompt`.sh](bash/prompt.sh)
Just copy this to `/etc/profile.d/prompt.sh`.. will change your `$PS1` prompt.
Uses the `$PROMPT_COMMAND` variable to dynamically change the prompt.

Version 1.1.0.

#### Screenshot
![$PS1](docs/prompt.sh.png)

### [`up2date`.sh](bash/up2date.sh)
Tool for [Gentoo](https://gentoo.org/) Linux, [Debian](https://debian.org/) and [Termux](https://termux.dev/) Linux.
I'm using it to do all steps to keep your packages `up2date`, in just one step!

Also, just copy it to `/etc/profile.d/up2date.sh`

### [`layout`.sh](bash/layout.sh)
The most important thing for me was to switch between keyboard layouts - easily with a shortcut I've set up in XFCE
(Settings -> Keyboard): calling this script with '-' argument only (so traversing, *not* setting..)!

Here's an example screenshot:
![layout.sh](docs/layout.sh.png)

So either call it without arguments, so it'll show you the currently used layout. Call it with a concrete layout, to
switch to it directly. Or call it with a single `-`, so it'll traverse through the `layouts` array (on top, by default
it's `layouts=("us" "de")`).

### [`make-nodejs`.sh](bash/make-nodejs.sh)
For **amd64** and **arm64** (Termux): a script to build a [Node.js](https://nodejs.org/) version that you define in
the command line, with target path `/opt/node.js/${version}/` plus a **symbolic link** `0` pointing to there.

So you can also manage multiple versions, or just check if the newest installation really works, before removing the
old one.. the only thing left to do, _just once_, is to merge the fs structure under the symlink path `/opt/node.js/0`
into the `/usr/` hierarchy.

I'm using this script on every new Node.js version, on my Linux desktop/workstation and on my Termux smartphone app;
therefore the `0` symlink will point to the newest version - and as you've merged everything _under it before_ (into
the `/usr` hierarchy), there's no need to change anything else. Just `rm -rf` the older version if the newest one
works! :)~

> **Note**
> Just call it via `make-nodejs.sh 20.4.0`, e.g.!

### Snippets and one-liners
Really tiny helper scripts, or one-liner, cheats, etc..

#### [`chmod`.sh](bash/snippets/chmod.sh)
For recursive `chmod`, with different types for directories and files.

After this you'll see how many items were changed, and how many errors occured (if any), and how many files were
ignored (due to '$ignore' list; the one setting of two, together with '$hidden').

The erroneous files will be printed as list, so you can check them manually (otherwise just redirect the STDERR
by appending ` 2>/dev/null` to the cmdline).

#### [`count-all-lines`.sh](bash/snippets/count-all-lines.sh)
Define a glob and search for them (only _real_ files), then print their line counts (sorted, ascending),
plus the total count in the last line.

#### [`fresh`.sh](bash/snippets/fresh.sh)
One command to 'fresh up' the current git repository.. mentioned to be in `/etc/profile.d/`.

#### [`qemu`.sh](bash/snippets/qemu.sh)
Starting `qemu` with some most common, configurable parameters (as I like them).. really nothing special!

#### [`substring`.sh](bash/dunno/substring.sh)
Short overview over the string substitutions supported by the `bash`.. dug it out under my `~/git/knowledge/`,
so really not worth to mention here, but maybe a help if you need to write a shell script quickly (I don't
like it when using the `bash` but doing such things with external commands...).

## Copyright and License
The Copyright is [(c) Sebastian Kucharczyk](./COPYRIGHT.txt),
and it's licensed under the [MIT](./LICENSE.txt) (also known as 'X' or 'X11' license).

