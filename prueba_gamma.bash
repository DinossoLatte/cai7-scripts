#!/bin/bash
# Cambiar el siguiente comando con el elemento correspondiente
DISTORSION_MODULE="java -Xmx4098m -jar vsl-module-distortion-gamma.jar"
STEGANOGRAPHY_MODULE="java -Xmx4098m -jar vsl-module-steganography-klt.jar"
IMAGE="Imagen_de_prueba.png"
TEXT="test_data.txt"
DATA_FOLDER="prueba_gamma"

# Vaciamos los tiempos
> errors-gamma.txt

ITER=0
# Ejecutamos 5 iteraciones
for ITER in `seq 1 5`
do
    # Generamos un archivo de 80Kbytes
    head -c 80K </dev/urandom > $TEXT
    # Generamos una cantidad a aumentar aleatoria
    R_FACTOR=$(shuf -i1-256 -n1)
    G_FACTOR=$(shuf -i1-256 -n1)
    B_FACTOR=$(shuf -i1-256 -n1)
    
    # Distorsionamos la imagen usando el módulo correspondiente
	$DISTORSION_MODULE $R_FACTOR $G_FACTOR $B_FACTOR $IMAGE "tmp-$IMAGE"

	# Ocultamos el mensaje, obtieniendo el tiempo de ejecución
    eval $STEGANOGRAPHY_MODULE tmp-$IMAGE $TEXT $DATA_FOLDER/image.png $DATA_FOLDER/cols.txt $DATA_FOLDER/rows.txt $DATA_FOLDER/key.txt $DATA_FOLDER/mean.txt 2 0 1
    
    # Ahora, recuperamos el texto
    eval $STEGANOGRAPHY_MODULE $DATA_FOLDER/image.png $DATA_FOLDER/result.txt $DATA_FOLDER/cols.txt $DATA_FOLDER/rows.txt $DATA_FOLDER/key.txt $DATA_FOLDER/mean.txt 2 0 1
    
    # Comprobamos que el archivo siga intacto
	echo "Iteración $ITER: " >> errors-gamma.txt
	cmp -l $TEXT prueba_gamma/result.txt | wc -l >> errors-gamma.txt

    # Si todo ha ido bien, eliminamos datos de la anterior iteración
	rm -f $DATA_FOLDER/*
done