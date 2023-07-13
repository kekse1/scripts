<img src="https://kekse.biz/php/count.php?draw&override=github:scripts&text=<%20kuchen@kekse.biz%20>" />

# scripts/
Atm only [Bash](#bash) shell scripts. May grow..

## Index
1. [Bash](#bash)
	* [`prompt`.sh](#promptsh)
	* [`up2date`.sh](#up2datesh)
    * [`layout`.sh](#layoutsh)
    * [Snippets and one-liners](#bash/snippets-and-one-liners)
        * [`chmod`.sh](#chmodsh)
        * [`count-all-lines`.sh](#count-all-linessh)
        * [`fresh`.sh](#freshsh)
        * [`qemu`.sh](#qemush)
        * [`substring`.sh](#substringsh)
3. [Copyright and License](#copyright-and-license)

## [Bash](bash/)

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
The most important thing for me was to switch between keyboard layouts - easily with a shortcut I've set up in XFCE
(Settings -> Keyboard): calling this script with '-' argument only (so traversing, *not* setting..)!

Here's an example screenshot:
![layout.sh](docs/layout.sh.png)

So either call it without arguments, so it'll show you the currently used layout. Call it with a concrete layout, to
switch to it directly. Or call it with a single `-`, so it'll traverse through the `layouts` array (on top, by default
it's `layouts=("us" "de")`).

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

