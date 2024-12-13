<img src="https://kekse.biz/github.php?draw&override=github:scripts" />

# **Scripts**
Every script is made by myself, arose out of necessity.. or because I found it interesting.

> [!IMPORTANT]
> * \[**2024-09-24**\] **Moved** some scripts to my **new**
> [**`utilities`**](https://github.com/kekse1/utilities/) and
> [**`javascript`**](https://github.com/kekse1/javascript/) repositories.

## Index
1. [News](#news)
2. [Bash](#bash)
	* [`prompt`.sh](#promptsh)
	* [`dump`](#dump)
	* [`lines`.sh](#linessh)
	* [`layout`.sh](#layoutsh)
	* [`up2date`.sh](#up2datesh)
	* [`fresh`.sh](#freshsh)
	* [`make-nodejs`.sh](#make-nodejssh)
	* [`lines`.sh](#linessh)
	* [`unexify`.sh](#unexifysh)
	* [`sync`.sh](#syncsh)
	* [`ansi`.sh](#ansish)
	* [`up2date`.sh](#up2datesh)
	* [`count-all-lines`.sh](#count-all-linessh)
	* [`copy`.sh](#copysh)
	* [`fresh`.sh](#freshsh)
	* [`create-random-files`.sh](#create-random-filessh)
	* [`replace`.sh](#replacesh)
	* [`toilets`.sh](#toiletssh)
	* [`math`.sh](#mathsh)
	* [`baseutils`.sh](#baseutilssh)
	* [`move-by-ext`.sh](#move-by-extsh)
	* [`find-ext`.sh](#find-extsh)
	* [`insert-header`.sh](#insert-headersh)
	* [`router`.sh](#routersh)
	* [`hfdownloader`.sh](#hfdownloadersh)
	* [`convert-hf-to-gguf`.sh](#convert-hf-to-ggufsh)
	* [`hfget`.sh](#hfgetsh)
	* [`nightlounge`.sh](#nightloungesh)
	* [`lsblk`.sh](#lsblksh)
    * [`cursor`.sh](#cursorsh)
	* [`init-sub-proj`.sh](#init-sub-projsh)
3. [JavaScript](#javascript)
4. [C/C++](#cc)
    * [`nproc.c`](#nprocc)
5. [Copyright and License](#copyright-and-license)

## News
* \[**2024-12-13**\] Updated the **`line()`** function in [`baseutils`.sh](#baseutilssh); .. **v0.3.0**;
* \[**2024-11-26**\] Integrated the old `utilties` repository into here.. again.
* \[**2024-11-01**\] Updated [`create-random-files`.sh](#create-random-filessh) to **v1.5.1**
* \[**2024-10-24**\] Updated the [`lsblk`.sh](#lsblksh) to **v0.2.3**;
* \[**2024-10-07**\] Updated [`math`.sh](#mathsh) to **v0.2.3**;
* \[**2024-09-24**\] **Moved** some scripts to my **new** [**`utilities`**](https://github.com/kekse1/utilities/) and [**`javascript`**](https://github.com/kekse1/javascript/) repositories.
* \[**2024-09-09**\] Updated [`lines`.sh](#linessh): **v0.4.1**
* \[**2024-09-09**\] New [`cursor`.sh](#cursorsh), **v0.0.1**
* \[**2024-08-18**\] New [`hfget`.sh](#hfgetsh), **v0.2.0**
* \[**2024-08-09**\] [`make-nodejs`.sh](#make-nodejssh) to **v0.3.9**
* \[**2024-07-29**\] [`convert-hf-to-gguf`.sh](#convert-hf-to-ggufsh) **v0.1.1**
* \[**2024-07-29**\] [`hfdownloader`.sh](#hfdownloadersh) **v0.3.1**
* \[**2024-07-06**\] Updated the [`fresh`.sh](#freshsh) to **v0.4.4** (for lazy people like me)
* \[**2024-06-25**\] Updated [`nightlounge`.sh](#nightloungesh) to **v0.2.7**
* \[**2024-06-19**\] Created my [`insert-header`.sh](#insert-headersh) shell script, **v0.2.3**;
* \[**2024-06-14**\] Created it's own GitHub repository for the [`prompt`.sh](#promptsh)

## [Bash](sh/)

### [`prompt`.sh](https://github.com/kekse1/prompt/)
**Moved** to it's [own repository](https://github.com/kekse1/prompt).

### [`dump`](https://github.com/kekse1/dump/)
In [another repository](https://github.com/kekse1/dump/).

### [`lines`.sh](sh/lines.sh)
You should put this script into your `/etc/profile.d/` directory,
so the `lines()` function will get `source`d. Then just call it this
way - possible parameters are described on top of this bash shell
script file.

* [Version **v0.4.1**](sh/lines.sh) (updated **2024-09-09**)

Simple script you can use with either a file path parameter or the
stdin `-` (if defined at all), to perform one of these actions:

* display the line count of your input
* extract a specific line
* extract an area of lines
* negative numbers counting backwards from the `EOF`

### [`layout`.sh](sh/layout.sh)
* [Version **v0.2.0**](sh/layout.sh)

The most important thing for me was to switch between keyboard layouts - easily with a shortcut I've set up in XFCE
(Settings -> Keyboard): calling this script with '-' argument only, to switch between the configured layouts.

![layout.sh](img/layout.png)

So either call it without arguments, so it'll show you the currently used layout. Call it with a concrete layout, to
switch to it directly. Or call it with a single `-`, so it'll switch between the configured layouts (by default, it's
on top: `layouts=("us" "de")`).

### [`up2date`.sh](sh/up2date.sh)
* [Version **v0.2.1**](sh/up2date.sh)

Tool for [Gentoo](https://gentoo.org/) Linux, [Debian](https://debian.org/) and [Termux](https://termux.dev/) Linux.
I'm using it to do all steps to keep your packages `up2date`, in just one step!

Also, just copy it to `/etc/profile.d/up2date.sh`

### [`fresh`.sh](sh/fresh.sh)
* [Version **v0.4.4**](sh/fresh.sh) (updated **2024-07-06**)

Helper to quickly update `git` repositories.. really tiny.

Now with check if you're inside a git repository, and also a commit message
is now required (because I was too lazy before..).

> [!TIP]
> Includes a function `keep()` to create `.keep` files in empty directories.
> Useful for `git`, since it won't obey empty directories.

### [`make-nodejs`.sh](sh/make-nodejs.sh)
* [Version **v0.3.10**](sh/make-nodejs.sh) (updated **2024-10-06**)

For **amd64** and **arm64** (Termux): a script to build a [Node.js](https://nodejs.org/) version that you define in
the command line, with target path `/opt/node.js/${version}/` plus a **symbolic link** `0` pointing to there: so you
can also manage multiple versions, or just check if the newest installation really works, before removing the old one..
the only thing left to do, _just once_, is to merge the fs structure under the symlink path `/opt/node.js/0` into
the `/usr/` hierarchy.

> [!NOTE]
> Just call it via `make-nodejs.sh 22.9.0` (or `make-nodejs.sh v22.9.0`), e.g.!

### [`unexify`.sh](sh/unexify.sh)
* [Version **v0.1.2**](sh/unexify.sh) (updated **2024-04-23**)

Little helper script to recursively remove all headers from images.

The primary intention is to secure **all** images in your web root.
So e.g. when you take photos with your smartphone, they'll no longer
contain the GPS coordinates, etc. ;-)

Call with `-h` or `--help` to get to know a bit more.. the help text is encoded
in a variable on the file's top.

_JFYI_: Dependency is the [**`exiftool`**](https://exiftool.org), which is the
packet `libimage-exiftool-perl` within [**Debian** Linux](https://debian.org/).

### [`sync`.sh](sh/sync.sh)
* [Version **v0.4.4**](sh/sync.sh) (updated **2024-05-01**)

Another helping hand which became required since I'm managing some archive on my server,
which needs to be synchronized with an SB stick (using `crontab`, ..).

> [!WARNING]
> PLEASE CHECK the **FIRST BOTH** configuration parts, relatively on top of the file..

_BTW_: My target USB stick is formatted as `ExFAT` file system, so not all linux
file permissions and attributes are supported, and also no symbolic links. So I
decided to disable all these by default. If you want/need them, use the `-l` or
`--linux` cmdline argument. Additionally see `-d` or `--dereference`. **;-)**

> [!TOP]
> As usual, you can also use `-h` or `--help`! **:-D**

### [`ansi`.sh](sh/ansi.sh)
* [Version **v0.0.3**](sh/ansi.sh) (updated **2024-04-21**)

Starting with a shell script (to be `source`d) for ANSI escape sequences.

You either need to manually `source` or `.` in your shell (it's NOT executable),
or copy it to `/etc/profile.d/ansi.sh`.

### [`up2date`.sh](sh/up2date.sh)
* [Version **v0.2.1**](sh/up2date.sh)

Tool for [Gentoo](https://gentoo.org/) Linux, [Debian](https://debian.org/) and [Termux](https://termux.dev/) Linux.
I'm using it to do all steps to keep your packages `up2date`, in just one step!

Also, just copy it to `/etc/profile.d/up2date.sh`

### [`count-all-lines`.sh](sh/count-all-lines.sh)
* [Version **v0.3.1**](sh/count-all-lines.sh) (updated **2024-02-25**)

Will traverse recursively through all sub directories (of current working directory) using one or more `find -iname`
parameters (especially globs to define file extensions!), and output a list of found ones with their line counts,
sorted ascending, and ending with the line count sum of all line counts.

### [`copy`.sh](sh/copy.sh)
* [Version **v0.1.2**](sh/copy.sh) (updated **2024-02-25**)

A little helper to `scp` files, with only the remote file path as argument.

I'm using this to copy backups from my server, most because on errors this
is going to repeat the copy (as long you define in the 'loops' variable).
So just set your server {user,host,port} and copy securely.

BTW: yes, I had an unstable line when I created this.. via mobile phone.

### [`fresh`.sh](sh/fresh.sh)
* [Version **v0.4.4**](sh/fresh.sh) (updated **2024-07-06**)

Helper to quickly update `git` repositories.. really tiny.

Now with check if you're inside a git repository, and also a commit message
is now required (because I was too lazy before..).

**Now** (**v0.3.0**) w/ new **`keep`** function (inter alia because `git`
won't see empty directories).

**New** in **v0.4.4**: use **`+`** (or `$_GIT_DATE_SYMBOL` config) to only
set the commit message (without it there'd be **no** `git add/commit/push`,
only `git pull`) to the current `date +"$_GIT_DATE_FORMAT_EXT"`, if you're
lazy like me.

### [`create-random-files`.sh](sh/create-random-files.sh)
My [`Norbert`](https://github.com/kekse1/norbert/) needed some random input data,
from a directory I wanted to propagate with some temporary files (of an exactly
defined file size).

* [Version **v1.5.1**](sh/create-random-files.sh) (updated **2024-11-04**);

So I created this very tiny tool.

> [!IMPORTANT]
> Dependencies: the **`dd`** utility.

> [!NOTE]
> JFYI: Since **v1.4.0** the 1st, 2nd and 3rd argument can
> also be negative. In this case the absolute values of them
> define their maximum of randomly generated params.

> [!TIP]
> Feel free to extract the **`randomChars()`** and **`random()`** functions
> out of the file and put it into one of your `/etc/profile.d/*.sh`.

### [`replace`.sh](sh/replace.sh)
* [Version **v0.1.1**](sh/replace.sh) (created **2024-03-19**)

Recursive (really!) `sed` (regular expression) replacement in (only real!) files.

### [`toilets`.sh](sh/toilets.sh)
* [Version **v0.0.2**](sh/figlets.sh) (created **2024-03-19**)

Easily compare `toilet` (or `figlet`) outputs for a list of fonts in a file (each line another font).
Command line switches are passed through to the tool itself. Input texts can also be set via command
line, or just wait to get asked via `stdin`.

For many fonts see [this link](http://www.jave.de/figlet/fonts/overview.html); and here are the
websites of [`toilet`](http://caca.zoy.org/wiki/toilet) and [`figlet`](http://www.figlet.org/).

The font archive can be un-zipped in `/usr/share/figlet/` (even for `toilet`), or rather it's
`fonts/` directory itself.

### [`math`.sh](sh/math.sh)
* [Version **v0.2.4**](sh/math.sh) (updated **2024-11-04**)

Functions to be `source`d (so copy to `/etc/profile.d/`) providing conversions for size, and in
the future also some more math related functions.. for now, look at the source to get to know more.

You crender an amount of bytes to `GiB`, etc.. base 1024 and 1000 support,
and direct conversion to a specific target unit, or it'll automatically
detect which suites best:
* ` >> Syntax: bytes <value> [ <base=1024 | <unit> [ <prec=2> ] ]`

### [`baseutils`.sh](sh/baseutils.sh)
* [Version **v0.3.0**](sh/baseutils.sh) (updated **2024-12-13**)

This is just the beginning of more bash functions.

The project began with [`baseutils.org`](https://baseutils.org/), which was planned as regular
code (either C or JavaScript). Some first tools had been finished then.. they were planned for
my `Any/Linux` project (with still much, much TODO).. BUT I began to take over some old functions
from my `/etc/profile.d/` scripts, and now here we are..

Still _much_ **TODO**, but the first functions are declared and I'm going to implement everything soon!

### [`move-by-ext`.sh](sh/move-by-ext.sh)
* [Version **v0.0.2**](sh/move-by-ext.sh) (updated **2024-02-25**)

Another tiny helper... really nothing special.

### [`find-ext`.sh](sh/find-ext.sh)
* [Version **v0.1.2**](sh/find-ext.sh) (updated **2024-02-25**)

Something similar to the [`move-by-ext`.sh](#move-by-extsh) helper, but here without write operations,
only counting all different extensions available under the current working directory. And it's possible
to limit the `find` recursion depth via optional first argument (needs to be positive integer).

### [`insert-header`.sh](sh/insert-header.sh)
* [Version **v0.2.3**](sh/insert-header.sh) (updated **2024-06-25**)

My source code needed my (copyright) header when I published it.
So I created this script, since more than just less files needed
to be updated..

The usage is merely simple, look at the output when calling this
script without parameters!

> [!TIP]
> Use the `-d` or `--delete` parameter to unlink all of this script's
> backup files (`*.BACKUP`, or see the (only) `$BACKUP` variable), and
> use `-r` or `--restore` to restore the original files via backups.

> [!NOTE]
> My **TODO** is to replace the file extension argv-parameters by full
> globs, to be pass-thru directed to the `find` command.

### [`router`.sh](sh/router.sh)
* [Version **v0.1.1**](sh/router.sh) (updated **2024-04-23**)

Some time ago I needed to setup my computer as a router (using `iptables`).

This was created very quickly, without much features or tests.
Feel free to use it as kinda template; see [this link](https://wiki.gentoo.org/wiki/Home_router) for more.

### [`hfdownloader`.sh](sh/hfdownloader.sh)
* [Version **v0.3.1**](sh/hfdownloader.sh) (updated **2024-07-29**)

Easily use the [`hfdownloader`](https://github.com/bodaay/HuggingFaceModelDownloader) tool, to download
full models from [Hugging Face](https://huggingface.co/), a community for Large Language Models, etc.

You don't really need this script, since the [`hfdownloader`](https://github.com/bodaay/HuggingFaceModelDownloader)
tool is easy enough; it's rather kinda reminder' for myself..

> [!TIP]
> For some more things about **Artificial Intelligence**, take a look at my private website,
> concretely at the [**`~intelligence`** area](https://kekse.biz/?~intelligence).

### [`convert-hf-to-gguf`.sh](sh/convert-hf-to-gguf.sh)
* [Version **v0.1.1**](sh/convert-hf-to-gguf.sh) (updated **2024-07-29**)

> [!IMPORTANT]
> Dependencies: **Python 3** (w/ `pip`) and [`llama.cpp`](https://github.com/ggerganov/llama.cpp/);

This script helps you converting hugging face models (see [**huggingface.co**](https://huggingface.co/))
to **GGUF format `.gguf`**, which is necessary for the transformers I listed
on **my website @ [`~intelligence`](https://kekse.biz/?~intelligence)**.

> [!TIP]
> Preparations:
> `python3 -m venv venv`
> `cd venv`
> `source bin/activate`
> `git clone https://github.com/ggerganov/llama.cpp.git`
> `./bin/python3 ./bin/pip install -r llama.cpp/requirements.txt`
> `./bin/python3 llama.cpp/convert-hf-to-gguf.py -h`

### [`hfget`.sh](sh/hfget.sh)
Just a tiny helper, if you don't want to use the [`hfdownloader(.sh)`](#hfdownloadersh).

* [Version **v0.2.0**](sh/hfget.sh) (created **2024-08-18**)

Downloads from [**Hugging Face**](https://huggingface.co/) with your
own **Token** (a file) included in the HTTP request header. This
massively increases the speed of your downloads, and it allows you
to access (your) non-public files, and maybe more..

Expects either a URL or a file with a list of URLs as parameter. Depends on `wget`.

### [`nightlounge`.sh](sh/nightlounge.sh)
Downloads a Stream until the `DURATION` is reached (then `wget` will be stopped).
I use this script for my daily download of the 'BigFM Nightlounge' podcast.

* [Version **v0.2.7**](sh/nightlounge.sh) (updated **2024-06-26**)

> [!TIP]
> You can add this to your '/etc/crontab'. ;-)

### [`lsblk`.sh](sh/lsblk.sh)
* [Version **v0.2.3**](sh/lsblk.sh) (updated **2024-10-24**)

The main reason for this script was: my Node.js projects need to handle
whole block devices oder partitions. But I wanted to configure them by
their (PART)UUID, so there'd be no problems when regular '/dev/sdb' or
so change (which can happen, and this is a big problem!).

In Node.js there's no regular way to open devices/partitions by their
(PART)UUID; additionally, I couldn't get the sizes of the partitions
or drives via `fstat*()`..

The second reason was: using bash arrays and a special syntax to split
the `--pairs` output into key/value etc., I wanted to leave myself a
hint for future shell scripts.. and for you! Note, that I marked out
for you where to use `case`, if you'd like to manage the key/value pairs.

> [!NOTE]
> For a bit more infos about this, see the top of [the script](sh/lsblk.sh)!

### [`cursor`.sh](sh/cursor.sh)
Tiniest.. just prints out the current cursor position in your active terminal.

* [Version **v0.0.1**](sh/cursor.sh) (created **2024-09-09**)

The real function `cursor()` is only **seven lines** long.

### [`init-sub-proj`.sh](sh/init-sub-proj.sh)
* [Version **v0.3.1**](sh/init-sub-proj.sh) (updated **2024-05-23**)

I do initialize a sub part of my bigger project with
the help of this script.

See the $COPY file list. And end each item without
slash to only initialize it empty (even though dirs
contain entries in your original project). Symbolic
Links stay exactly the same (so using `readlink`).

## C/C++

### [`nproc`.c](c-cpp/nproc.c)
* [Version **v0.2.2**](c-cpp/nproc.c) (created **2024-04-15**)

Modificated `/usr/bin/nproc`, to optionally set the `NPROC` environment variable,
which can be an arbitrary number of cores/threads to output.

If `$NPROC` is not defined or below 1, it will try to get the real value.

# Copyright and License
The Copyright is [(c) Sebastian Kucharczyk](./COPYRIGHT.txt),
and it's licensed under the [MIT](./LICENSE.txt) (also known as 'X' or 'X11' license).

<a href="favicon.512px.png" target="_blank">
<img src="favicon.png" alt="Favicon" />
</a>

