
pwd

cd "C:\Users\cony7\OneDrive\Documentos\Fundamentos de programación\tarea5-fundamentos"


* ============================================================
* T5 — Do-file automatizado
* Autor: Constanza Pinilla     Fecha: Noviembre 2026
* ============================================================

* 1. Encabezado con macros de configuración
clear all
set more off
capture mkdir "output"
capture log close
log using "output/tarea_t5.log", replace text

* --- Parámetros (lo único que se edita) ---
local datos     "data/raw/casen_reducido.csv"
local depvar    "ingreso"
local numericas "ingreso educ edad experiencia"
local controles "educ experiencia"
local grupos    "sector region genero"
global umbral   = 500000
global fuente   "CASEN, muestra del curso"

* Se utilizó 'local' para las rutas, variables y controles porque estos elementos 
* solo son necesarios dentro de este script, evitando que interfieran con otros 
* do-files. Por el contrario, se utilizó 'global' para el umbral simulando 
* un parámetro general que podría compartirse o mantenerse activo en toda la 
* sesión.

* 2. Carga y prepara los datos

import delimited "`datos'", clear varnames(1) encoding("utf-8")
generate experiencia = max(edad - educ - 6, 0)

generate mujer = (genero == "F")  

label define lb_mujer 0 "Hombre" 1 "Mujer"
label variable mujer "Indicador de género (1 = Mujer)"
label values mujer lb_mujer

* 3. Un `foreach` sobre una lista de variables

foreach v of local numericas {
    summarize `v', detail
}

* 4. Un `forvalues` con un rango

forvalues t = 20(10)60 {
    quietly count if edad >= `t' & edad < `t' + 10 & !missing(edad)
    display "Edad de `t' a " `t' + 9 " años: " r(N) " personas"
}

* 5. Un `program` reutilizable con argumentos

capture program drop descriptivos_grupo
program define descriptivos_grupo
    display _newline "=== Descriptivos por `1' ==="
    tabulate `1'
    tabstat ingreso educ, by(`1') statistics(mean sd n)
end

foreach g of local grupos {
    descriptivos_grupo `g'
}

* 6. Usa `tempvar` al menos una vez

tempvar ing_miles
generate `ing_miles' = ingreso / 1000
label variable `ing_miles' "Ingreso en miles de pesos"
summarize `ing_miles'

* Explica en un comentario **por qué** `tempvar` es más seguro que crear una variable normal y borrarla después.
* Porque tempvar genera un nombre temporal único que se elimina automáticamente 
* al terminar el do-file, evitando colisiones con nombres existentes y 
* previniendo errores si el script se interrumpe antes de llegar a un comando drop.

* 7. Maneja los missing correctamente

count if ingreso > $umbral & !missing(ingreso)

* qué pasaría sin el `& !missing(ingreso)`.
* Si filtramos con 'ingreso > $umbral' sin añadir '& !missing(ingreso)', 
* Stata incluiría erróneamente los valores perdidos como si superaran el
* umbral, inflando artificialmente el conteo.

* 8. Modelos guardados y comparados (S13)

quietly regress `depvar' `controles'
estimates store m1
quietly regress `depvar' `controles' i.mujer
estimates store m2
estimates table m1 m2, b(%9.0f) se stats(N r2) stfmt(%5.3f)

estimates restore m1 
display "El coeficiente estimado de educación en el modelo 1 es: " _b[educ]

estimates restore m2
display "El coeficiente estimado de educación en el modelo 2 es: " _b[educ]

* 9. Una regresión por grupo, guardada en una matriz y exportada

levelsof sector, local(sectores)
local k : word count `sectores'
matrix R = J(`k', 3, .)
local i = 1
foreach s of local sectores {
    quietly regress ingreso educ if sector == "`s'"
    matrix R[`i', 1] = _b[educ]
    matrix R[`i', 2] = _se[educ]
    matrix R[`i', 3] = e(N)
    local i = `i' + 1
}

matrix colnames R = beta_educ ee n
matrix rownames R = `sectores'
matrix list R, format(%9.0f)


* Excel
putexcel set "output/tarea_t5_por_sector.xlsx", replace      
putexcel A1 = ("Sector") B1 = ("Beta educ") C1 = ("Error est.") D1 = ("n")
putexcel B2 = matrix(R)                                    

local fila = 2
foreach s of local sectores {                           
    putexcel A`fila' = ("`s'")
    local fila = `fila' + 1
}
putexcel A9 = ("Fuente: $fuente")

* 10. Cierra el log e interpreta

log close

* ============================================================
* INTERPRETACIÓN DE RESULTADOS
* ============================================================

* Un año adicional de escolaridad se asocia en promedio con un aumento de 
* $42.019 en el ingreso en m1 y de $42.246 en m2, reflejando una relación
* positiva. Al incorporar el género en m2, el r2 aumenta en 0.017, pero no se 
* puede afirmar una mejora del modelo. Las regresiones por sector son poco 
* precisas debido al bajo tamaño muestral, teniendo con más personas Servicios * (15) y con menor personas Construcción (5), la principal limitación es el 
* reducido tamaño muestral (n=60).









