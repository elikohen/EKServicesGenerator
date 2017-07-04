# SUPER - DEPRECATED!

Now with GSON + Retrofit for android and iOS new Codable feature this project makes no sense. Moreover it was super outdated as it works with objective-c and old android apis.





# ServiceGenerator
## Plantilla de definición de servicios

Los servicios de una aplicación se definen en un fichero con formato XML
	
El fichero de definición define los tipos y servicios asociados a la
aplicación siguiendo el siguiente formato:

	<protocol>
			<messages>
				<!-- ############################# -->
				<!-- LISTADO DE MENSAJES DE LA APP -->
				<!-- ############################# -->
				<message [ATRIBUTOS_MESSAGE]>
					<urlPattern>
						<url [ATRIBUTOS_URL]/>
					</urlPattern>
					<request [ATRIBUTOS_REQUEST]>
						<field [ATRIBUTOS_FIELD]/>
						[...]
					</request>
					<response [ATRIBUTOS_RESPONSE]>
						<field [ATRIBUTOS_FIELD]/>
						[...]
					</response>
				</message>
				[...]
			</messages>
			<types>
				<!-- ########################## -->
				<!-- LISTADO DE TIPOS DE LA APP -->
				<!-- ########################## -->		
				<type [ATRIBUTOS_TYPE]>
					<field [ATRIBUTOS_FIELD]/>
					[...]
				</type>
			</types>
		</protocol>


Atributos de las etiquetas del fichero de definición de servicios:


### TAG: message

#### ATRIBUTOS:
##### name: 
Nombre único del servicio 
##### service: 
Grupo de servicios al que pertenece (varios mensajes con mismo service generarán la lógica en el mismo fichero)
##### method: 
Nombre del método para acceder al servicio, recomendable utilizar un valor identico a 'name'
##### description [Opcional]: 
Descripción del mensaje, comentario en documentación
##### type: 
Tipo del mensaje valores: Get, Put, PutJSON, Post, PostJSON o Delete  
*PutJSON y PostJSON mandarán los datos en formato json y setearan el Content-Type a application/json*
##### content_type [Opcional]: 
Override del header Content-Type seteado automáticamente en función del type (Get, Post, PostJson.. etc). Por ejemplo, si se quiere mandar un Post con "application/json" pero que en realidad se envie en modo form, habría que poner el **type='Post'** y **content_type='application/json'**



### TAG: url

#### ATRIBUTOS:

##### address: La dirección con la que se accede al servicio.
La url de acceso al servicio puede contener parámetros, que estarán definidos con el formato `${nombreParametro}`, estos parámetros se sustituirán por el valor del mismo en las propiedades de sistema (`System.getProperty`) que se pueden establecer en la invocación del servicio ( `-DnombrePropiedad=valorPropiedad`)<br>

Si no se encuentran los parámetrosen ése nivel, se consultan entre las propiedades del objeto utilizado en la petición (fields pertenecientes al request)
		
### TAG: request

#### ATRIBUTOS:
##### name:
Nombre del DTO en el código generado
                
### TAG: response

*En el caso del response, no hace falta rellenar los fields si se utiliza un name ya definido mas abajo en los types (objetos del modelo). Además Tampoco hace falta indicar si se trata de un Array de los responseDTO o un responseDTO simple, ya que el propio código generado hará la detección*


#### ATRIBUTOS:
##### name [opcional si type = raw]:
Nombre del DTO en el código generado
##### type [opcional]: 
Únicamente utilizado para la recepción de datos sin formato. En tal caso hay que utilizar **type='raw'** y NO  setear el atributo 'name'

### TAG: field

#### ATRIBUTOS:
##### name: 
Nombre del campo (Nombre de la propiedad en el DTO generado)
##### type: 
Tipo del campo, los tipos pueden ser :<br>
- básicos:<br>
int,String,long,float,double<br>
- compuestos<br>
[Nombres de tipos (véase tipos más adelante)]<br/>
- Arrays<br/>
Se utiliza el nombre del tipo (base o compuesto) seguido de `*`<br/>
##### description:[Opcional] 
Comentario que tendrá el campo en código fuente


### TAG: type

#### ATRIBUTOS:
##### name: 
Nombre del tipo (Es el nombre que tendrá el DTO generado)

## Generación

1.- Instalar dependencias

comando terminal...

*rake setup*

2.- Ejecutar generador

Comando terminal...

*ruby generator.rb -f [Ruta absoluta fichero xml] -pn [Nombre de proyecto] -package [Paquete Java Base] -aVersion [Versión de templates para android] -aOutput [Ruta al proyecto Android] -iVersion [Versión de templates para iOS] -iOutput [Ruta al proyecto iOS]*
