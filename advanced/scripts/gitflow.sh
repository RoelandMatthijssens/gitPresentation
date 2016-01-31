#------------
#| player 1 |
#------------
git co -b "feature/GIT-111"
echo "fixes" > file.txt
git add file.txt
git commit -m "implemented feature"
echo "some more fixes" > file.txt
git add file.txt
git commit -m "fixed a bug"

git co develop
git merge --no-ff feature/GIT-111

#------------
#| player 2 |
#------------

git co -b "feature/GIT-112"
echo "fixes" > file.txt
git add file.txt
git commit -m "implemented feature"
echo "some more fixes" > file.txt
git add file.txt
git commit -m "fixed a bug"

git co develop
git merge --no-ff feature/GIT-111

#------------
#| player 1 |
#------------
git push origin develop
#------------
#| player 2 |
#------------
git push origin develop
#>> MERGE CONFLICT
git pull
git mergetool
#>> fix merge conflict
git commit -am "fixed merge conflicts"
git push origin dev

#------------
#| player 1 |
#------------
git pull origin dev
#>> merge conflicts (automatically resolved)
#>> Merge made by 'recursive' strategy
