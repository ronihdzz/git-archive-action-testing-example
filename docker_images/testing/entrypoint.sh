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

# 📂 Crear directorio de artifacts si no existe
mkdir -p /app/artifacts/htmlcov

# 📤 Mover archivos de cobertura
echo "📤 Moving coverage.xml and htmlcov/ to /app/artifacts/"
[ -f coverage.xml ] && mv coverage.xml /app/artifacts/ || echo "⚠️ coverage.xml not found."
[ -d htmlcov ] && mv htmlcov/* /app/artifacts/htmlcov/ || echo "⚠️ htmlcov directory not found."

# 📊 Mostrar resumen de cobertura (opcional)
if command -v poetry > /dev/null; then
  echo "📈 Coverage summary:"
  poetry run coverage report || echo "⚠️ coverage summary not available"
fi

echo "✅ Entrypoint complete."
