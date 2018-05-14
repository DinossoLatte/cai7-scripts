rm -f $3/*
java -jar vsl-module-steganography-klt.jar $1 $2 $3/img.png $3/cols.txt $3/rows.txt $3/key.txt $3/mean.txt $4 $5 $6
java -jar vsl-module-steganography-klt.jar $3/img.png $3/result.txt $3/cols.txt $3/rows.txt $3/key.txt $3/mean.txt $4 $5 $6