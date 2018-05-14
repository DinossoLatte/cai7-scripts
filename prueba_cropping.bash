#!/bin/bash
# Cambiar el siguiente comando con el elemento correspondiente
DISTORSION_MODULE="java -jar vsl-module-distortion-cropping.jar"
STEGANOGRAPHY_MODULE="java -jar vsl-module-steganography-klt.jar"
WIDTH=2048
HEIGHT=2048
IMAGE="Imagen_de_prueba.png"
TEXT="test_data.txt"
DATA_FOLDER="prueba_cropping"

# Vaciamos los tiempos
> errors-cropping.txt

ITER=0
ERRORS=0

# Ejecutamos 5 iteraciones
while [ $ITER -lt 5 ]
do
    # Generamos un archivo de 80Kbytes
    head -c 80K </dev/urandom > $TEXT
    # Generamos una altura y anchura aleatoria
    X_RAND=$(shuf -i1-$WIDTH -n1)
    Y_RAND=$(shuf -i1-$HEIGHT -n1)
    NEW_WIDTH=$(expr $WIDTH - $X_RAND)
    NEW_HEIGHT=$(expr $HEIGHT - $X_RAND)

    echo "X: $X_RAND | Y: $Y_RAND | Width: $NEW_WIDTH | Height: $NEW_HEIGHT"

	# Distorsionamos la imagen usando el módulo correspondiente
	$DISTORSION_MODULE $X_RAND $Y_RAND $NEW_WIDTH $NEW_HEIGHT $IMAGE "tmp-$IMAGE"

    # Si sale mal la operación, pasa al siguiente
    if [ $? -ne 0 ]
    then
        continue
    fi

	# Ocultamos el mensaje, obtieniendo el tiempo de ejecución
    eval $STEGANOGRAPHY_MODULE tmp-$IMAGE $TEXT $DATA_FOLDER/image.png $DATA_FOLDER/cols.txt $DATA_FOLDER/rows.txt $DATA_FOLDER/key.txt $DATA_FOLDER/mean.txt 2 0 1

    # Estará bien cuando la imagen se haya generado
    if [ -e $DATA_FOLDER/image.png ]
    then 
        ITER=$(expr $ITER + 1)
    else 
        ERRORS=$(expr $ERRORS + 1)
        continue
    fi
    
    # Ahora, recuperamos el texto
    eval $STEGANOGRAPHY_MODULE $DATA_FOLDER/image.png $DATA_FOLDER/result.txt $DATA_FOLDER/cols.txt $DATA_FOLDER/rows.txt $DATA_FOLDER/key.txt $DATA_FOLDER/mean.txt 2 0 1
    
    # Comprobamos que el archivo siga intacto
	echo "Iteración $ITER: " >> errors-cropping.txt
	cmp -l $TEXT prueba_cropping/result.txt | wc -l >> errors-cropping.txt

    # Si todo ha ido bien, eliminamos datos de la anterior iteración
	rm -f $DATA_FOLDER/*
done

echo "Número de errores de insuficiencia de tamaño: $ERRORS" >> errors-cropping.txt