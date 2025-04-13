#!/bin/sh
set -e

echo "📦 Running entrypoint.sh..."

# 🧬 Cargar variables si el archivo existe
if [ -f ./ci.env.sh ]; then
  echo "📦 Running ci.env.sh..."
  . ./ci.env.sh
else
  echo "⚠️ No ci.env.sh found. Skipping..."
fi

# 🧪 Ejecutar los tests con cobertura
echo "🧪 Running tests with coverage..."
poetry run "$@"

# 📤 Copiar archivos de cobertura a una carpeta controlada por el runner
echo "📤 Copying coverage reports to /app/coverage-reports/"
mkdir -p /app/coverage-reports/htmlcov
[ -f coverage.xml ] && cp coverage.xml /app/coverage-reports/ || echo "⚠️ coverage.xml not found."
[ -d htmlcov ] && cp -r htmlcov/* /app/coverage-reports/htmlcov/ || echo "⚠️ htmlcov directory not found."

# 📊 Mostrar resumen de cobertura (opcional)
if command -v poetry > /dev/null; then
  echo "📈 Coverage summary:"
  poetry run coverage report || echo "⚠️ coverage summary not available"
fi

echo "✅ Entrypoint complete."
