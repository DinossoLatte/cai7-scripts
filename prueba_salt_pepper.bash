#!/bin/bash
# Cambiar el siguiente comando con el elemento correspondiente
DISTORSION_MODULE="java -jar vsl-module-distortion-salt-pepper-noise.jar"
STEGANOGRAPHY_MODULE="java -jar vsl-module-steganography-klt.jar"
IMAGE="Imagen_de_prueba.png"
TEXT="test_data.txt"
DATA_FOLDER="prueba_S\&P"

# Vaciamos los tiempos
> errors.txt

# Ejecutamos 5 iteraciones
for ITER in `seq 1 5`
do
    # Generamos un archivo de 80Kbytes
    head -c 80K </dev/urandom > $TEXT
	# Distorsionamos la imagen usando el módulo correspondiente
	$DISTORSION_MODULE "0.2" $IMAGE "tmp-$IMAGE"

	# Ocultamos el mensaje, obtieniendo el tiempo de ejecución
    eval $STEGANOGRAPHY_MODULE tmp-$IMAGE $TEXT $DATA_FOLDER/image.png $DATA_FOLDER/cols.txt $DATA_FOLDER/rows.txt $DATA_FOLDER/key.txt $DATA_FOLDER/mean.txt 2 0 1
    
    # Ahora, recuperamos el texto
    eval $STEGANOGRAPHY_MODULE $DATA_FOLDER/image.png $DATA_FOLDER/result.txt $DATA_FOLDER/cols.txt $DATA_FOLDER/rows.txt $DATA_FOLDER/key.txt $DATA_FOLDER/mean.txt 2 0 1
    
    # Comprobamos que el archivo siga intacto
	echo "Iteración $ITER: " >> errors.txt
	cmp -l $TEXT prueba_S\&P/result.txt | wc -l >> errors.txt

    # Si todo ha ido bien, eliminamos datos de la anterior iteración
	echo $DATA_FOLDER/*
    rm -f $DATA_FOLDER/*
done
