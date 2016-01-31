# prepare repo,
# make `git init --bare` repo as remote
# `git gc` in remote

git clone <repo-url> <repo-name>
cd <repo-name>

git l
# NOTE:
# show structure of repo, where tags are, where branches are.
# SHOULD BE SAID

tree .

tree .git/objects/
# NOTE:
# This is where all the objects live,
# It doesn't matter how large the repo is it will all be contained in the pack file. This
# file will not be expanded, or extracted. This is how git saves disk space.
# note the pack file.
#     this file containse all the objects.
#     this file is compressed, the technique depends on compression algoritm
# note the info file next to the pack file.
#     this file containes info on where data is located in the pack file.

echo 'first' > file.txt
git add file.txt
tree .git/objects/
git cat-file -p <get object hash>
# NOTE:
# There is a single entry added in the objects directory. They are added on `git add` not
# on commit. You can inspect the file with `git cat-file`. This file is a complete
# duplicate of the content on disk in the working directory at the time that it was added.
zlib_decompress .git/objects/dc/2f8c2bb981d37d5e88d81ecc1af3d9e661d8df content.txt && cat content.txt
# NOTE:
# It really is just a flat file that is zlib compressed. There is little difference
# between `git cat-file` and decompressing it. There is no magic, the only difference is
# in the first line that specifies the object type, (here a blob)

git commit -m 'added first line to file'
tree .git/objects/
# NOTE:
# There are now three extra objects, the blob that we just added, the tree that containes
# the blob, and the commit itself. We can inspect these with `git cat-file -p`.

# -- hashes=$(find .git/objects -type f -not -iregex '.*pack.*' | sed -e 's/\.git\/objects\/\(.*\)\/\(.*\)/\1\2/')
# -- for hash in ${hashes}; do echo ${hash}; git cat-file -p ${hash}; done

echo 'second' > file.txt && git add .
tree .git/objects/
git cat-file -p <get object hash>
# NOTE:
# file present on disk 3 times!, once in working directory, once when first added and
# committed, and once when just now add. What a wast of space? especially when files are
# 100+ lines and only 2 where changed.

git gc
tree .git/objects/
# NOTE:
# Everything is stored back in the pack files. The content is compressed, and the total
# space on disk is minimal, a lot better then what svn is capable of. This is because git
# compresses the whole history at once so data is compressed better. It is free to choose
# what pieces of content is most like other pieces of content. It is not just a collection
# of deltas. This compression can be much better.
# Git will run `git gc` automatically over time (don't do this to often because dangling
# objects will be removed, and there is no way to recover them anymore, it is not necisary
# anyway).

git checkout -b develop
cat .git/info/refs
cat .git/refs/heads/develop
git cat-file -p $(cat .git/refs/heads/develop)
# NOTE:
# branches can be found in two locations, in the refs file under .git/info and as a file
# under the .git/refs directory. The ORIGIN_HEAD will be found in the refs file.
# just a flat file with a sha1 hash, this points to a commit.

cat .git/HEAD
git checkout develop~;
cat .git/HEAD
# NOTE:
# This is a relative path to the head that it is pointing at. WHen whe checkout something
# that is not a branch, we are in detached head mode, and the content of head contains the
# sha1 hash of the commit we are currently on.

git checkout develop
cat .git/HEAD && cat .git/refs/heads/develop
echo 'line' > file.txt && git commit -a -m 'add line to file'
cat .git/HEAD && cat .git/refs/heads/develop
# NOTE:
# The head file has not changed at all, the develop branch has moved and now points at the
# new commit that was just created
git cat-file -p develop
# NOTE:
# The commit we created has a pointer to its parent. This hash is the same one that we
# just had before we commited.

git merge --no-ff master
git cat-file -p develop
# NOTE:
# The parent now has 2 hashes in it. The first points to where develop was before. The
# other pointer is where master was.
cat .git/info/refs | grep master

git checkout master && git merge develop
git cat-file -p master && git cat-file -p develop
# NOTE:
# Only the hashes in the parents array are swapped. Here we also have a different
# timestamp. But even if they happend on the exact same time, the commits would still be
# different, and would still have a different sha1 hash as a result.
# The order of a merge is important.
git rev-parse master^ && git rev-parse develop^2
# NOTE:
# These are the same, but we have requested different parents. When we follow a branch
# with a '^' we ask for the parent, when we follow it with a '^n' we ask for the n-th
# parent. So '^2' is not the parent of the parent, but the second parent.
git l -n 4
# NOTE:
# see the history, and show why the above just happens to be the same.

git rev-parse master~ && git rev-parse master~2
git rev-pares master^2~2 && git rev-parse master~~
git rev-parse 'master@{2 days ago}'
# NOTE:
# there are other ways to refer to previous commits. a '~' asks for the first parent, a
# '~2' is the first parent, af the first parent, (or the grand parent when following
# first parents.
# these things can be chained
