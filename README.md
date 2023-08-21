# SlimeOS Yuescript

**IMPORTANT**: Only officially supports the latest git master of awesome, compiled agains luajit (`awesome-luajit-git` from the AUR). Not using LuaJIT is not supported and will probably not work (or, if it does, it may not work anymore in the future, because LuaJIT has a bunch of extra features that I may or may not end up using). Only tested on Arch Linux; if you want to use this elsewhere, you'll have to go figure it out on your own, I cannot help you with that.

Requirements:

- `awesome-luajit-git` from the AUR
- [`luautf8`](https://github.com/starwing/luautf8) (provided by `lua51-luautf8`)
- `playerctl`

Installing them all using `paru`:

```
paru -S awesome-luajit-git playerctl lua51-luautf8
```

Additional info:

- You need to also clone the submodules of this repo
- You will probably need to compile some C libraries in varios folders locally yourself (exact documentation TBD)