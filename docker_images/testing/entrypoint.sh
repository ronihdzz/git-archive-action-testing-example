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
poetry run pytest --cov=src --cov-report=xml --cov-report=html --junitxml=unittest_report.xml src/tests -v

# 🎨 Generar cobertura en SVG
poetry run coverage svg

# 📤 Copiar archivos específicos de cobertura a una carpeta controlada por el runner
echo "📤 Copying selected coverage reports to /app/coverage-reports/"
mkdir -p /app/coverage-reports/

[ -f coverage.xml ] && cp coverage.xml /app/coverage-reports/ || echo "⚠️ coverage.xml not found."
[ -f coverage.svg ] && cp coverage.svg /app/coverage-reports/ || echo "⚠️ coverage.svg not found."
[ -f unittest_report.xml ] && cp unittest_report.xml /app/coverage-reports/ || echo "⚠️ unittest_report.xml not found."

# 📊 Mostrar resumen de cobertura (opcional)
if command -v poetry > /dev/null; then
  echo "📈 Coverage summary:"
  poetry run coverage report || echo "⚠️ coverage summary not available"
fi

echo "✅ Entrypoint complete."
