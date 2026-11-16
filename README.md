
## T5 — Do-file automatizado

Automatización en T5
Un script completamente automatizado mediante macros, loops, un programa 
reutilizable para descriptivos grupales y un loop con matrices que procesa y exporta 
automáticamente los coeficientes y errores estándar de las regresiones por sector 
hacia un archivo Excel.

Para aplicar este mismo script a una base de datos diferente, solo es necesario
modificar las macros ubicadas en el bloque de configuración inicial asegurándose
de que los nuevos nombres de las variables coincidan exactamente con las columnas 
del archivo de entrada.

## Datos

Archivos en `data/raw/casen_reducido.csv` 

## Cómo correrlo

Abrir Stata y ejecutar `scripts/tarea_t5.do`

## Estructura

```
 tarea5-fundamentos/
   ├── data/
       └── raw/ 
   ├── scripts/  
   ├── output/
   └── README.md
```

## Autor

Constanza Pinilla — Noviembre 2026

## Declaración de autoría y uso de IA
- Herramienta utilizada: Gemini Plus.
- Para qué la usé: Para resumir que se hizo en el do-file y ponerlo en el README 
y para ver las funciones label.
- Qué hice yo: Busqué las funciones pedidas en los guiones de clases, interprete 
resultados y verifique que todo funcionara bien.
- Verificación: Confirmo que entiendo y puedo explicar todo lo que entrego.