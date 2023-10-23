# Contenedorización y despliegue en Kubernetes de una API de productos en Laravel

Veremos cómo crear una API de gestión de productos en Laravel usando un entorno de desarrollo en Docker. El entorno estará formado por el framework Laravel y una base de datos MySQL. A continuación veremos cómo empaquetarla en una imagen Docker, que subiremos a Docker Hub. Por último, la desplegaremos en un cluster de Kubernetes y veremos cómo realizar una actualización.

## Endpoints de la API

* `GET api/product`
* `GET api/product/{id}`
* `POST api/product`
* `PUT api/product/{id}`
* `DELETE api/product/{id}`

## Modelo

* `id: integer (autoincrement)`
* `barcode: string`
* `product: string`
* `description: string`
* `stock: integer`
* `price: float`
* `timestamps`

## Preparación del entorno

Bitnami propociona un [`docker-compose.yml`](https://raw.githubusercontent.com/bitnami/containers/main/bitnami/laravel/docker-compose.yml) para desplegar MariaDB y Laravel.
   
Lo descargamos y lo lanzamos con `docker-compose up -d`. 

Esto crea:
   * Dos servicios: 
     * `mariadb`: Servicio MariaDB
     * `myapp`: Servicio Laravel
   * Un proyecto nuevo denominado `my-project`

Para este tutorial usaremos un [`docker-compose.yml`](https://github.com/ualmtorres/laravel-products-api/blob/master/docker-compose.yml) adaptado para trabajar con variables de entorno en un archivo [`.env`](https://gist.github.com/ualmtorres/dc2b289e4cb76f1059fad1be68d6f418).

> **NOTA**
> Excluiremos el `.env` del control de versiones del [`.gitignore`](https://gist.github.com/ualmtorres/9d97317b97afaa188cc52d6d08084ef5) y usaremos en su puesto un [`.env.example`](https://gist.github.com/ualmtorres/218d175806ac8bdc1b1304cf0e9f4a13) para que proporcione las indicaciones de configuración.


## Ejecución de comandos Laravel

Podemos ejecutar los comandos Laravel a través del servicio Laravel del `docker compose` o abriendo una terminal en el contenedor de la aplicación.

### Con `docker compose`

En nuestro ejemplo el servicio Laravel se denomina `myapp`

* Comando `php artisan`:
    
    `docker-compose exec myapp php artisan …`
* Comando `composer`:
  
    `docker-compose exec myapp composer …`

### Con Docker Desktop 

Podemos ejecutar los comandos Laravel directamente desde la terminal del contenedor. Para ello, seleccionamos el contenedor de la aplicación e introducimos directamente los comandos Laravel en la pestaña Terminal (p.e. `php artisan …` o `composer …`)

## Preparación de la base de datos

Podemos preparar la base de datos a través del servicio Laravel del `docker compose` o abriendo una terminal en el contenedor de la aplicación.

### Con `docker compose`

* Creación de una migración para una tabla `Productos` con el comando siguiente: 

    `docker-compose exec myapp php artisan make:migration create_products_table`
* Configurar la [migración de la tabla de productos](https://gist.github.com/ualmtorres/d440a496d3562d0e92a34727cb78c228) en `<proyecto>/database/migrations`
* Ejecutar la migración con el comando siguiente:

    `docker-compose exec myapp php artisan migrate`

### Con Docker Desktop 

Podemos ejecutar los comandos Laravel directamente desde la terminal del contenedor. Para ello, seleccionamos el contenedor de la aplicación e introducimos directamente los comandos Laravel en la pestaña Terminal (p.e. `php artisan make:migration create_products_table`)

## Preparación del modelo y el controlador

Podemos preparar el modelo y el controlador a través del servicio Laravel del `docker compose` o abriendo una terminal en el contenedor de la aplicación.

### Con `docker compose`

* Crear modelo y controlador

    `docker-compose exec myapp php artisan make:model Product -c`

* Programar el [controlador](https://gist.github.com/ualmtorres/2c92fe219534f50701358b3b38683092)  en `<proyecto>/app/Http/Controllers`
* Programar el [modelo](https://gist.github.com/ualmtorres/0df1575c095330736bb519f2eb874173) en `<proyecto>/app/Models`
* Añadir las [rutas](https://gist.github.com/ualmtorres/4dabff3a333d267650c69820edc30e1f) en `<proyecto>/routes/api.php`

Ya estará disponible la API en `localhost:8000/api/product`.

### Con Docker Desktop

Podemos ejecutar los comandos Laravel directamente desde la terminal del contenedor. Para ello, seleccionamos el contenedor de la aplicación e introducimos directamente los comandos Laravel en la pestaña Terminal (p.e. `php artisan make:model Product -c`)

## Carga de datos de ejemplo en la base de datos

Veamos cómo podemos cargar datos de ejemplo en la base de datos usando el endpoint `POST api/product`.

Previamente, generaremos un archivo JSON con los datos a insertar. Para este caso, hemos usado [Mockaroo](https://www.mockaroo.com/) para generar un archivo JSON con 10 registros de ejemplo. Realmente no es un archivo JSON válido con un array de objetos, sino un conjunto de objetos JSON separados por saltos de línea [MOCK_DATA.json](https://gist.github.com/ualmtorres/85602e0da53ce6649342c14e709a5772).

Para cargar los datos de ejemplo en la base de datos, creamos un script Bash [`populate.sh`](https://gist.github.com/ualmtorres/704e2532d19b6fe0d8fef0ded0884def) en el que pegaremos los datos generados, **encerrando cada documento JSON de producto entre comillas simples**. Con esto crearemos un array con los productos que podremos pasar como parámetro al comando `curl` para insertar los datos en la base de datos.

<script src="https://gist.github.com/ualmtorres/704e2532d19b6fe0d8fef0ded0884def.js"></script>

Ejecutamos el script con `bash populate.sh` y los datos se insertarán en la base de datos.

## Creación de la imagen

A partir de este [Dockerfile](https://github.com/ualmtorres/laravel-products-api/blob/master/Dockerfile) generaremos la imagen con este comando

    docker build -t ualmtorres/laravel-products-api:v0 .

A continuación, subiremos la imagen a Docker Hub con este comando

    docker push ualmtorres/laravel-products-api:v0

## Despliegue en una plataforma con Docker Compose

Consideremos el siguiente escenario:

* Tenemos una máquina virtual Ubuntu Linux con Docker instalado.
* Tenemos la imagen Docker de la API en Docker Hub. Esto lo hemos realizado en el apartado anterior.

Optaremos por uno de los siguientes casos:

### Caso 1. Despliegue para testing

* En este caso la base de datos correrá en local en un contenedor junto al contenedor de la API. 
* En la máquina virtual tenemos un archivo `.env` con las variables de entorno necesarias. Podemos usar el [`.env`](https://gist.github.com/ualmtorres/dc2b289e4cb76f1059fad1be68d6f418) que teníamos para desarrollo.
* El archivo Docker compose [`docker-compose-testing.yml`](https://github.com/ualmtorres/laravel-products-api/blob/master/docker-compose-testing.yml) que usemos tendrá que instanciar la imagen de la API creada en el apartado anterior. 

Descargamos el archivo `docker-compose-testing.yml` en la máquina virtual y lo desplegamos con el comando siguiente

    docker-compose -f docker-compose-testing.yml up -d

### Caso 2. Despliegue para producción

* En este caso la base de datos correrá en remoto y ya estará inicializada con la base de datos de inventario. 
* En la máquina virtual tenemos un archivo `.env` con las variables de entorno necesarias. Podemos usar el [`.env`](https://gist.github.com/ualmtorres/dc2b289e4cb76f1059fad1be68d6f418) que teníamos para desarrollo y adaptarlo modificando los valores necesarios (p.e. `DB_HOST`).
* El archivo Docker compose [`docker-compose-produccion.yml`](https://github.com/ualmtorres/laravel-products-api/blob/master/docker-compose-produccion.yml) que usemos tendrá que instanciar la imagen de la API creada en el apartado anterior. 

Descargamos el archivo `docker-compose-produccion.yml` en la máquina virtual y lo desplegamos con el comando siguiente

    docker-compose -f docker-compose-produccion.yml up -d



## Despliegue en Kubernetes

Partimos de un cluster Kubernetes creado y de una instancia MySQL corriendo con la base de datos `inventario` ya creada y con la tabla de productos creada.

Usaremos 4 objetos Kubernetes para el despliegue:

* Objeto [`ConfigMap`](https://github.com/ualmtorres/laravel-products-api/blob/main/k8s/laravel-products-api-configmap.yml):
  Contiene la variable de entorno `DB_PORT`, que es un valor no sensible. 
* Objeto [`Secret`](https://github.com/ualmtorres/laravel-products-api/blob/main/k8s/laravel-products-api-secret.yml):
  Contiene las variables de entorno `DB_HOST, DB_USERNAME, DB_PASSWORD, DB_DATABASE`. 
  
  > **NOTA**
  > En un objeto _secret_ los valores van codificados en base64. Para codificarlos lo haremos con este comando

  > `echo -n '<valor-a-codificar>' | base64`

  > Por ejemplo, `echo -n '123' | base64` produce el valor `MTIz`

* Objeto [`Deployment`](https://github.com/ualmtorres/laravel-products-api/blob/main/k8s/laravel-products-api-deployment.yml): Despliega la imagen de la API en dos pods.
* Objeto [`Service`](https://github.com/ualmtorres/laravel-products-api/blob/main/k8s/laravel-products-api-service.yml): Expone el servicio de la API en el puerto 8000 de una IP generada para la ocasión.

Desplegaremos estos objetos con `kubectl apply -f <filename>`

> **NOTA**
> El archivo [`laravel-products-api.yml`](https://github.com/ualmtorres/laravel-products-api/blob/main/k8s/laravel-products-api.yml) contiene los 4 objetos en un solo archivo. Si queremos desplegarlos todos a la vez, usaremos este archivo. Si queremos desplegarlos por separado, usaremos los archivos individuales.

## Actualización del despliegue de Kubernetes

Actualizaremos el despliegue por dos motivos: actualización del código de la API o cambio de credenciales en la base de datos.

* Actualización del código de la API
    1. Crear una nueva imagen local de la API con una etiqueta nueva (p.e. `ualmtorres/laravel-products-api:v0.1`) mediante 

        `docker build -t ualmtorres/laravel-products-api:v0.1 .`

    1. Subir la imagen al registro de imágenes con `docker push` mediante

        `docker push ualmtorres/laravel-products-api:v0.1`

    1. Modificar el archivo de _deployment_ actualizando la versión de la imagen de la API
    1. Redesplegar el archivo de _deployment_
* Cambio de credenciales en la base de datos
    1. Modificar el archivo _secret_ con las nuevas credenciales
    2. Redesplegar el archivo _secret_
    3. Reiniciar el despliegue con el comando siguiente para que se actualicen los pods con las nuevas credenciales

        `kubectl rollout restart deployment laravel-products-api`

## Enlaces de interés

* [docker-compose.yml para MariaDB y Laravel de Bitnami](https://raw.githubusercontent.com/bitnami/containers/main/bitnami/laravel/docker-compose.yml)