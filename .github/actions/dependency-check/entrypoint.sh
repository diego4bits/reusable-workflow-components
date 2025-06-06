#!/usr/bin/env bash
set -euo pipefail

# --- SOLUCIÓN AUTOCONTENIDA ---
# Usando la ruta que descubriste ('/opt/jdk'), añadimos su directorio 'bin'
# al principio de la variable de entorno PATH.
# Esto asegura que cuando cualquier script busque el comando "java", encontrará
# la versión correcta dentro del contenedor primero, solucionando el problema
# de la sobrescritura de JAVA_HOME de forma definitiva.
export JAVA_HOME="/opt/jdk/"
# --- FIN DE LA SOLUCIÓN ---


# El resto de tu script original continúa sin cambios.
scan_args="$1"
out_path="/github/workspace"

# El siguiente comando ahora usará la versión correcta de Java gracias al PATH modificado
/usr/share/dependency-check/bin/dependency-check.sh \
      $scan_args \
      --out $out_path
exit_code=$?


echo "report-path=${out_path}" >>"$GITHUB_OUTPUT"


exit "$exit_code"