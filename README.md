# MiniFaaS en Kumori
La solución adoptada y su uso están descritos en el documento "memoria.pdf"

# Ejemplo de uso:
Este es el ejemplo de uso descrito en la memoria, copiado aquí para facilitar su uso:

Ejecutamos los siguientes comandos en el directorio "minifaas":

Descargamos las dependencias:

'kumorictl fetch-dependencies'

Configuramos la URL de admisión:

'kumorictl config --admission admission-ccmaster.vera.kumori.cloud'

Hacemos login en la plataforma con nuestro usuario:

'kumorictl login myuser'

\textbf{Nota:} El autoscaler utiliza mis credenciales para realizar la monitorización (jgoncam), por lo que esta funcionalidad no estará disponible si el despliegue se realiza con otro usuario.

Establecemos el dominio por defecto:

'kumorictl config --user-domain myuser'

Registramos un certificado:

'kumorictl register certificate calccert.wildcard \
  --domain *.vera.kumori.cloud \
  --cert-file cert/wildcard.vera.kumori.cloud.crt.wildcard \
  --key-file cert/wildcard.vera.kumori.cloud.key.wildcard'
  
Regitramos el inbound:

'kumorictl register http-inbound minifaasinb \
  --domain minifaas-myuser.vera.kumori.cloud \
  --cert calccert.wildcard'
  
El inbound no funcionará hasta pasado un tiempo debido a los tiempos de propagación de DNS:

'curl https://minifaas-myuser.vera.kumori.cloud
curl: (6) Could not resolve host: minifaas-myuser.vera.kumori.cloud'

Registramos el despliegue:

'kumorictl register deployment minifaasdep \
--deployment ./cue-manifests/deployment'

\textbf{Nota:} Es importante llamar al despliegue "minifaasdep", ya que el autoscaler utiliza ese nombre para monitorizar el sistema.\\
Enlazamos el inbound con el despliegue:

'kumorictl link minifaasdep:service minifaasinb'

Ahora podemos ejecutar:

'kumorictl describe deployment minifaasdep'

Para visualizar el estado del sistema.

A continuación, vamos al directorio "Ejemplo".

Comenzamos por comprobar que el sistema está activo:

'curl -X GET https://minifaas-myuser.vera.kumori.cloud/
The MiniFaaS frontend is up!'

A continuación, añadimos un usuario:

'curl -X GET https://minifaas-myuser.vera.kumori.cloud/user
There are no users registered in the system
curl -X POST https://minifaas-myuser.vera.kumori.cloud/user/faasuser
faasuser added to the system'

Registramos dos funciones de ejemplo para el usuario:

'curl --data-binary '@suma.js' -H "Content-Type: text/plain" \
https://minifaas-myuser.vera.kumori.cloud/user/faasuser/function/suma
suma added to the system for user faasuser

curl --data-binary '@random_array.js' -H "Content-Type: text/plain" \
https://minifaas-myuser.vera.kumori.cloud/user/faasuser/function/\
random_array
random_array added to the system for user faasuser'

Y realizamos algunas ejecuciones de prueba:

'curl -X GET -d '{"args":[1, 2]}' -H "Content-Type: text/plain" \
https://minifaas-myuser.vera.kumori.cloud/user/faasuser/function/suma
3

curl -X GET -d '{"args":[50, 40]}' -H "Content-Type: text/plain" \
https://minifaas-myuser.vera.kumori.cloud/user/faasuser/function/suma
90

curl -X GET -d '{"args":[4]}' -H "Content-Type: text/plain" \
https://minifaas-myuser.vera.kumori.cloud/user/faasuser/function/\
random_array
[0.437667661747563,0.01856356190768338,0.5870984797426209,0.4329093550785834]

curl -X GET -d '{"args":[2]}' -H "Content-Type: text/plain" \
https://minifaas-myuser.vera.kumori.cloud/user/faasuser/function/\
random_array
[0.9527953579139501,0.23508150908274783]'

Ahora podemos comprobar el tiempo de uso para este usuario:

'curl -k https://minifaas-myuser.vera.kumori.cloud/user/faasuser/usage
Execution history for faasuser
[["suma",0.000150758],["suma",0.000221502],
["random_array",0.000213538],["random_array",0.000173587]]
Total usage in seconds: 0.000759385'

Para ver el efecto del autoescalado, podemos usar la función bucle, que tarda en ejecutarse unos 8 minutos en un worker en Kumori. Durante la ejecución, podemos ir comprobando mediante el comando kumorictl describe deployment, cómo aumenta el uso de CPU para uno de los workers, y cómo se despliega automáticamente uno nuevo cuando se supera un 80\% de uso de la CPU. Una vez termina la ejecución, podemos observar cómo se elimina el Worker adicional.\\
Es posible que el escalado no se produzca inmediatamente al superar el 80\% de carga, y tarde algo más. Esto se debe a que el Autoscaler comprueba la carga cada minuto, y una vez detecta que se ha superado el límite hace login en kumori y despliega el nuevo manifiesto, lo cual lleva un tiempo. En todas las pruebas hasta ahora, el escalado se ha producido mucho antes de que termine esta ejecución de 8 minutos.

'curl -k --data-binary '@bucle.js' -H "Content-Type: text/plain" \
https://minifaas-jgoncam.vera.kumori.cloud/user/faasuser/function/bucle
bucle added to the system for user faasuser

curl -k -X GET -d '{"args":[]}' -H "Content-Type: text/plain" \
https://minifaas-jgoncam.vera.kumori.cloud/user/faasuser/function/bucle'
