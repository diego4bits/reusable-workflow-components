#!/usr/bin/env bash
set -euo pipefail

# --- SOLUCIÓN AUTOCONTENIDA ---
# Se añade la ruta al directorio de binarios de Java (instalado en el Dockerfile)
# al principio de la variable PATH del sistema.
# De esta forma, cuando cualquier script dentro del contenedor busque "java",
# encontrará esta versión primero, ignorando cualquier otra configuración
# o variable de entorno externa (como el JAVA_HOME heredado del runner).
export PATH="/usr/lib/jvm/java-17-openjdk-amd64/bin:$PATH"
# --- FIN DE LA SOLUCIÓN ---


# El resto del script original continúa sin cambios
scan_args="$1"
out_path="/github/workspace"

# El siguiente comando ahora usará la versión correcta de Java gracias al PATH modificado.
/usr/share/dependency-check/bin/dependency-check.sh \
      $scan_args \
      --out $out_path
exit_code=$?


echo "report-path=${out_path}" >>"$GITHUB_OUTPUT"


exit "$exit_code"