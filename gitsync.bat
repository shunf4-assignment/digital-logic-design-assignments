set dd=%DATE:~0,10%
set tt=%time:~0,8%
set hour=%tt:~0,2%
git pull
git add .
git commit -m "ScriptBack %dd:/=-% %tt%"
git push origin master

goto :eof