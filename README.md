Contains the files I use to setup vim for editing code.

Includes akitaonrails + jredville's dot-files.

= Usage

Clone this repo somewhere on your drive.

Then 'cd' into the repo and run this to get the snippets submodule:

<pre><code>
git submodule init
git submodule update
</code></pre>

Copy the contents to your home folder 
on Linux/Mac copy the contents of vimfiles to ~/.vim
on Windows you can copy the contents to %HOME%\vimfiles

Put this in your .vimrc file (in your home folder) along with your personal hacks:
<pre><code>
source ~/.vim/vimrc      "linux
source ~/vimfiles/vimrc  "windows
</code></pre>

= Dependencies

You will need these dependencies figured out:

* Ruby (for the fuzzy finder plugin)
* Exuberant Ctags (http://ctags.sourceforge.net/)
* Ncurses-term (in Linux only)

In Ubuntu, for example, you will have to do:

    apt-get install exuberant-ctags ncurses-term

On Windows you have to download Ctags and add ctags.exe in your PATH.

Mac OS X and most Linux distros come with Ruby already. If you're in Windows
look for Luis Lavena's latest Ruby Installer (http://rubyforge.org/projects/rubyinstaller/)

h2. Credits

* Original project and most of the heavy lifting: @scrooloose
* Hacks and some snippets: @akitaonrails
* More hacks and snippets: @jredville


