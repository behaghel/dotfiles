#!/bin/sh

for i in `cat .tobedotlinked`; do
  ln -s $i ~/.$i
done


