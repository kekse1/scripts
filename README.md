<img src="https://kekse.biz/github.php?draw&override=github:scripts&text=`scripts`&draw" />

## Index
1. [News](#news)
2. [Bash](#bash)
	* [`prompt`.sh](#promptsh)
3. [JavaScript](#javascript)
4. [Copyright and License](#copyright-and-license)

## News
* \[**2024-03-05**\] **Started** the [**`ansi.sh`**](#ansish), to be `source`d/`.` (maybe at `/etc/profile.d/` or in your shell)
* \[**2024-03-05**\] **New version (v2.0.3) of my [`prompt.sh`](#promptsh) (including new screenshot here)! :-D**
* \[**2024-02-25**\] Shell scripts are using the 'builtin' `getopt` command now. **:-)**
* \[**2024-02-25**\] The [`count-all-lines.sh`](#count-all-linessh) now worx correctly (with more than one -iname/glob/..)!
* \[**2024-02-25**\] This news section is reduced to only the last changes.. jfyi: these days I added some new scripts.

## [Bash](sh/)

### [`prompt`.sh](sh/prompt.sh)
Just copy this to `/etc/profile.d/prompt.sh`.. will change your `$PS1` prompt.
Uses the `$PROMPT_COMMAND` variable to dynamically change the prompt.

* [Version **v2.0.3**](sh/prompt.sh) (updated **2024-03-06**)

#### Screenshot
![$PS1](img/prompt.sh.png)

### [`unexify`.sh](sh/unexify.sh)
Little helper script to recursively remove all headers from images.

* [Version **v0.1.1**](sh/unexify.sh) (updated **2024-02-25**)

The primary intention is to secure **all** images in your web root.
So e.g. when you take photos with your smartphone, they'll no longer
contain the GPS coordinates, etc. ;-)

Call with `-h` or `--help` to get to know a bit more.. the help text is encoded
in a variable on the file's top.

_JFYI_: Dependency is the [**`exiftool`**](https://exiftool.org), which is the
packet `libimage-exiftool-perl` within [**Debian** Linux](https://debian.org/).

### [`sync`.sh](sh/sync.sh)
Another helping hand which became required since I'm managing some archive on my server,
which needs to be synchronized with an SB stick (using `crontab`, ..).

* [Version **v0.3.2**](sh/sync.sh) (updated **2024-02-25**)

> **Warning**
> PLEASE CHECK the **FIRST BOTH** configuration parts, relatively on top of the file..

_BTW_: My target USB stick is formatted as `ExFAT` file system, so not all linux
file permissions and attributes are supported, and also no symbolic links. So I
decided to disable all these by default. If you want/need them, use the `-l` or
`--linux` cmdline argument. **;-)**

> **Note**
> As usual, you can also use `-h` or `--help`! **:-D**

### [`ansi`.sh](sh/ansi.sh)
Starting with a shell script (to be `source`d) for ANSI escape sequences.

* [Version **v0.0.2**](sh/ansi.sh) (created **2024-03-05**)

You either need to manually `source` or `.` in your shell (it's NOT executable),
or copy it to `/etc/profile.d/ansi.sh`.

### [`up2date`.sh](sh/up2date.sh)
Tool for [Gentoo](https://gentoo.org/) Linux, [Debian](https://debian.org/) and [Termux](https://termux.dev/) Linux.
I'm using it to do all steps to keep your packages `up2date`, in just one step!

* [Version **v0.2.1**](sh/up2date.sh)

Also, just copy it to `/etc/profile.d/up2date.sh`

### [`layout`.sh](sh/layout.sh)
The most important thing for me was to switch between keyboard layouts - easily with a shortcut I've set up in XFCE
(Settings -> Keyboard): calling this script with '-' argument only (so traversing, *not* setting..)!

* [Version **v0.2.0**](sh/layout.sh)

Here's an example screenshot:
![layout.sh](img/layout.sh.png)

So either call it without arguments, so it'll show you the currently used layout. Call it with a concrete layout, to
switch to it directly. Or call it with a single `-`, so it'll traverse through the `layouts` array (on top, by default
it's `layouts=("us" "de")`).

### [`count-all-lines`.sh](sh/count-all-lines.sh)
Will traverse recursively through all sub directories (of current working directory) using one or more `find -iname`
parameters (especially globs to define file extensions!), and output a list of found ones with their line counts,
sorted ascending, and ending with the line count sum of all line counts.

* [Version **v0.3.1**](sh/count-all-lines.sh) (updated **2024-02-25**)

### [`copy`.sh](sh/copy.sh)
A little helper to `scp` files, with only the remote file path as argument.

* [Version **v0.1.2**](sh/copy.sh) (updated **2024-02-25**)

I'm using this to copy backups from my server, most because on errors this
is going to repeat the copy (as long you define in the 'loops' variable).
So just set your server {user,host,port} and copy securely.

BTW: yes, I had an unstable line when I created this.. via mobile phone.

### [`move-by-ext`.sh](sh/move-by-ext.sh)
Another tiny helper... really nothing special.

* [Version **v0.0.2**](sh/move-by-ext.sh) (updated **2024-02-25**)

### [`find-ext`.sh](sh/find-ext.sh)
Something similar to the [`move-by-ext`.sh](#move-by-extsh) helper, but here without write operations,
only counting all different extensions available under the current working directory. And it's possible
to limit the `find` recursion depth via optional first argument (needs to be positive integer).

* [Version **v0.1.2**](sh/find-ext.sh) (updated **2024-02-25**)

### [`make-nodejs`.sh](sh/make-nodejs.sh)
For **amd64** and **arm64** (Termux): a script to build a [Node.js](https://nodejs.org/) version that you define in
the command line, with target path `/opt/node.js/${version}/` plus a **symbolic link** `0` pointing to there.

* [Version **v0.2.0**](sh/make-nodejs.sh) (updated **2024-02-25**)

So you can also manage multiple versions, or just check if the newest installation really works, before removing the
old one.. the only thing left to do, _just once_, is to merge the fs structure under the symlink path `/opt/node.js/0`
into the `/usr/` hierarchy.

I'm using this script on every new Node.js version, on my Linux desktop/workstation and on my Termux smartphone app;
therefore the `0` symlink will point to the newest version - and as you've merged everything _under it before_ (into
the `/usr` hierarchy), there's no need to change anything else. Just `rm -rf` the older version if the newest one
works! :)~

> **Note**
> Just call it via `make-nodejs.sh 21.6.2`, e.g.!

### [`router`.sh](sh/router.sh)
Some time ago I needed to setup my computer as a router (using `iptables`).

* [Version **v0.1.0**](sh/router.sh)

This was created very quickly, without much features or tests.
Feel free to use it as kinda template; see [this link](https://wiki.gentoo.org/wiki/Home_router) for more.

### [`junior`.sh](sh/junior.sh)
Since I'm using the [`llama.cpp`](https://github.com/ggerganov/llama.cpp/), or rather the
[`node-llama-cpp`](https://github.com/withcatai/node-llama-cpp), I just wrote a short
shell script to handle multiple models and prompts better.

* [Version **v0.2.0**](sh/junior.sh) (updated **2024-02-25**)

Syntax: `$0 <model> <prompt> [ <context size> ]`.

### [`fresh`.sh](sh/fresh.sh)
Helper to quickly update `git` repositories.. really tiny.

* [Version **v0.0.2**](sh/fresh.sh) (updated **2024-02-25**)

## JavaScript
My favorite language.. ^\_^

### [`clone.js`](js/clone.js)
Just my own `Reflect.clone()` version, since JavaScript doesn't include it natively..

* [Version **0.4.1**](js/clone.js) (updated **2024-03-04**)

### [`fold.css.js`](js/fold.css.js)
**Early version, so only the real basics are covered.**

'Folds' CSS style code. Earlier I used the `fold` (Linux) command, but that didn't work that well for what
I needed the resulting code: had to filter out CSS classes in `.html` code and `grep` for them in many
`.css` files - since `grep` is for lines, and `cut` is too stupid, .. I couldn't find the CSS styles in
stylesheets without newlines, etc. ..

* [Version **0.1.0**](js/fold.css.js) (updated **2024-03-04**)

>> *Warning*
>> TODO!

# Copyright and License
The Copyright is [(c) Sebastian Kucharczyk](./COPYRIGHT.txt),
and it's licensed under the [MIT](./LICENSE.txt) (also known as 'X' or 'X11' license).

![kekse.biz](favicon.png)

