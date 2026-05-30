# Proyecto 4 - VeriLang

Valentina Rojas 202420927
Isabella Salcedo 202420963

Este proyecto implementa un ejecutor para VeriLang usando Rascal y una interfaz gráfica de escritorio desarrollada en Kotlin.

El objetivo principal es reutilizar la gramática, el AST y los componentes del proyecto anterior de VeriLang, para ejecutar el análisis del lenguaje desde un entorno Kotlin. La interfaz permite seleccionar archivos `.veri`, ejecutar el parser de Rascal y visualizar los resultados del análisis.

## Componentes principales

### Parte de Rascal

* `Syntax.rsc`: define la sintaxis concreta del lenguaje VeriLang.
* `AST.rsc`: define las estructuras del árbol de sintaxis abstracta.
* `ToAST.rsc`: transforma el árbol de parseo en el AST de VeriLang.
* `Generator.rsc`: genera una representación legible a partir del AST.
* `TypeChecker.rsc`: realiza verificaciones básicas de tipos y reglas semánticas.
* `RunnerJson.rsc`: ejecuta el parser, construye el AST, ejecuta el verificador de tipos y retorna el resultado en formato JSON.

### Parte de Kotlin

* `Main.kt`: inicia la aplicación de escritorio.
* `RunResult.kt`: representa la respuesta JSON generada por Rascal.
* `LangService.kt`: ejecuta Rascal como un subproceso y recibe la salida JSON.
* `MainWindow.kt`: muestra la interfaz gráfica y los resultados del análisis.

## Cómo ejecutar el proyecto

Desde la raíz del proyecto, entrar a la carpeta de la aplicación Kotlin:

```powershell
cd kotlin-app
gradle run
```

Esto abrirá la interfaz gráfica de VeriLang Runner.

## Archivos de prueba

La carpeta `instance/` contiene tres archivos de prueba.

### Archivo válido

```text
instance/spec_ok.veri
```

Resultado esperado:

```text
Parser: OK
Tipos: OK
Semántica: OK
```

### Archivo con error de tipos

```text
instance/spec_type_error.veri
```

Resultado esperado:

```text
Parser: OK
Tipos: FAIL
Semántica: FAIL
```

Este archivo contiene un espacio que extiende un espacio padre que no está definido.

### Archivo con error de parser

```text
instance/spec_parse_error.veri
```

Resultado esperado:

```text
Parser: FAIL
Tipos: FAIL
Semántica: FAIL
```

Este archivo contiene una estructura inválida para la gramática de VeriLang.

## Funcionalidades implementadas

La aplicación permite:

* Seleccionar un archivo `.veri` desde el sistema de archivos.
* Ejecutar el parser de VeriLang usando Rascal.
* Construir el AST del archivo analizado.
* Retornar el resultado del análisis en formato JSON.
* Mostrar el estado del parser.
* Mostrar el estado del verificador de tipos.
* Mostrar el estado semántico.
* Mostrar los módulos encontrados.
* Mostrar errores de tipos cuando existen.
* Mostrar una representación generada desde el AST.
* Mostrar un resumen general del análisis.

## Notas importantes

La aplicación Kotlin espera encontrar el archivo `rascal-shell-stable.jar` en la raíz del proyecto.

El proyecto fue probado usando los archivos incluidos en la carpeta `instance/`, de igual manera se pueden usar lor archivos que se encuentran en src/ e inician con los nombres de 'test'.
