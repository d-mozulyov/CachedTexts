cd ..\
git.exe submodule update  --init -- "lib/CachedBuffers"
git.exe submodule update  --init -- "lib/UniConv"
git.exe submodule foreach git pull origin master
