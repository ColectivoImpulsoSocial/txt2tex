Este proyecto se divide en 4 partes:

1. Conversión de imagen a texto.
	En esta parte se necesita un algoritmo OCR (Optical Character Recognition o Reconocimiento Óptico de Caracteres). Básicamente para trasladar imagen a texto, esto incluirá errores del programa y si la imagen escaneada no es buena, también se sufrirá por ello.
2. Corrección de texto convertido.
	Una vez se tenga el texto del OCR se deberá revisar para corregir errores, aquí entra el script txt2tex, el cual primero ayudará a revisar y corregir errores y luego nos servirá para la 3ra parte (igual se pueden hacer dos scripts diferentes).
3. Generación del archivo LaTeX.
	Cuando ya se tenga el texto final se generará un archivo .tex que será usado por otro programa que sepa leer archivos latex para generar pdf's con índice, capítulos, los saltos de línea y página adecuados, etc.
4. Correción del archivo .tex
	Una vez más se necesitará de un programa para ir corrigiendo el documento final, ya que ahora podría no haber errores ortográficos pero sí de estilo (correción de estilo), márgenes, índice, capítulos, etc.

*Nota 1. Actualmente y dependiendo del SO, la parte 1 se hace por separado, ya que Mac, Linux y Windows tienen diferentes GUI's o programas por línea de comandos, por lo que para correr txt2tex se debe tener un archivo de texto con todo el texto ya escaneado y pasado por un OCR.
**Nota 2. Actualmente no se genera aún un archivo .tex, ya que falta integrar la interfaz gráfica para corregir de manera más cómoda el texto, aunque por línea de comando ya se puede hacer:
	>txt2tex --input_text <archivo con texto a corregir>
	Luego se mostrará todo el texto en bloques de 3 líneas (se puede cambiar en max_height en global variables) y 100 caracteres por línea (max_width). Cada palabra será identificada con un número; ejemplo:
        
	Había una ves un chivitddo que ...
	  1    2   3   4    5     6
	
	Para cambiar el texto hay que escribir cuando pida la opción:
	i 3 vez   --> Esto cambiará la palabra 3 por "vez"

	Había una vez un chivitddo que ...
	  1    2   3   4    5     6

	i 2,5 unas chivito  --> Esto cambiará la palabra 2 y 5 por unas y chivito respectivamente:

	Había unas vez un chivito que ...
	  1    2   3   4    5     6

	i 2-5 una vez un chivo. Éste chivo.. --> Esto cambiará desde la palabra 2 a la 5 por el texto introducido después:

	Había una vez un chivo. Éste chivo que ...
	  1    2   3   4    5     6    7    8


# txt2tex
Repositorio para proyecto de digitalizar libros: scanearlos y con un OCR darles formato y corregir posibles errores

## TO DO
- [] documentar dependencias
- [] Crear una estructura de carpetas, sugerida: http://padre.perlide.org/features/project-management.html
  - [] lib/
  - [x] bin/
  - [] t/
- [] Crear GUI
