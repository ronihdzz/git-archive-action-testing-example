# Git Archive Action - Testing Example

[English](#english) | [Español](#español)

---

## English

### Showcase: Example Project in Action

This repository demonstrates how the [ronihdzz/git-archive-action](https://github.com/ronihdzz/git-archive-action) integrates into a complex and realistic CI/CD workflow. This project showcases a complete use case where integration tests run against multiple services (PostgreSQL, MongoDB, Redis), generate coverage reports within a Docker container, and finally use the Action to persist these reports.

| CI Environment | Coverage |
|-----------|----------|
| main| ![Coverage Badge](https://github.com/ronihdzz/testing-actions-coverage/blob/artifacts/main/latest/coverage.svg) |
| development| ![Coverage Badge](https://github.com/ronihdzz/testing-actions-coverage/blob/artifacts/development/latest/coverage.svg) |

### Example Project Workflow

Below is the workflow code used in this project:

```yaml
name: Run Tests

on:
  push:
    branches: [main,development]

permissions:
  contents: write

jobs:
  test:
    runs-on: ubuntu-latest
    env:
      COVERAGE_REPORTS: coverage-reports
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports: ['5432:5432']
        options: >-
          --health-cmd="pg_isready" --health-interval=10s --health-timeout=5s --health-retries=5
      mongodb:
        image: mongo:4.4
        ports: ['27017:27017']
        options: >-
          --health-cmd="mongo --eval 'db.runCommand({ ping: 1 })'" --health-interval=10s --health-timeout=5s --health-retries=5
      redis:
        image: redis:6
        ports: ['6379:6379']
        options: >-
          --health-cmd="redis-cli ping" --health-interval=10s --health-timeout=5s --health-retries=5
    steps:
      - name: 🧾 Checkout code
        uses: actions/checkout@v3

      - name: 🏗️ Build test image
        run: docker build --progress=plain -t my-test-image -f docker_images/testing/Dockerfile.testing .

      - name: 🚀 Run tests in container
        run: |
          docker run \
            --name my-tests \
            --network=host \
            -e CI=true \
            -e GITHUB_DATABASE_POSTGRESQL=postgres://test:test@localhost:5432/test_db \
            -e GITHUB_DATABASE_MONGODB=mongodb://localhost:27017 \
            -e GITHUB_DATABASE_REDIS=redis://localhost:6379 \
            -v ${{ github.workspace }}/artifacts:/app/artifacts \
            my-test-image

      - name: 📥 Copy reports from container
        run: |
          mkdir -p ${{ env.COVERAGE_REPORTS }}
          docker cp my-tests:/app/coverage-reports/. ${{ env.COVERAGE_REPORTS }}
          echo "📄 Files copied from container:"
          ls -lh ${{ env.COVERAGE_REPORTS }}
          
      - name: 📤 Upload coverage as artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ env.COVERAGE_REPORTS }}
          path: ${{ env.COVERAGE_REPORTS }}

      - name: Save coverage
        uses: ronihdzz/git-archive-action@v3
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          artifacts-branch: 'artifacts'
          coverage-source: ${{ env.COVERAGE_REPORTS }}
          is-artifact: false
```

### Detailed Explanation of the Real Flow

1. **services**: The workflow defines three services (PostgreSQL, MongoDB, and Redis) that start alongside the job. Thanks to health-checks, test steps won't begin until these databases are ready to accept connections, simulating a production environment.

2. **Build test image**: A Docker image specific for testing is built. This encapsulates all project dependencies and ensures a consistent testing environment.

3. **Run tests in container**: The test container is executed with:
   - `--network=host`: Allows the container to communicate with database services running on the runner through localhost
   - `-e ...`: Database connection strings are injected as environment variables

4. **Copy reports from container**: This is a critical step. Once tests finish inside the container, generated reports exist only within that container's file system. The `docker cp` command extracts these reports from the container (`my-tests:/app/coverage-reports/.`) to the GitHub runner's file system (`${{ env.COVERAGE_REPORTS }}`), making them accessible for subsequent steps.

5. **Upload coverage as artifact**: This step uses the official `upload-artifact` Action to upload reports to the workflow's "Artifacts" section in GitHub UI. This is useful for quick review and manual downloads.

6. **Save coverage**: Finally, our Action is called:
   - `uses: ronihdzz/git-archive-action@v3`: Executes the Action to persist reports
   - `coverage-source: ${{ env.COVERAGE_REPORTS }}`: Indicates the folder path containing reports (same folder created in "Copy reports..." step)
   - `is-artifact: false`: Important to note it's set to `false`. Although the previous step uploaded an artifact, our Action is working with the local folder extracted from the container with `docker cp`. This demonstrates the Action's flexibility to work directly with files on the runner.

---

## Español

### Showcase: Proyecto de Ejemplo en Acción

Este repositorio demuestra cómo la [ronihdzz/git-archive-action](https://github.com/ronihdzz/git-archive-action) se integra en un flujo de trabajo de CI/CD complejo y realista. Este proyecto muestra un caso de uso completo donde las pruebas de integración se ejecutan contra múltiples servicios (PostgreSQL, MongoDB, Redis), se generan reportes de cobertura dentro de un contenedor Docker, y finalmente se utiliza la Action para persistir dichos reportes.

| Entorno CI | Cobertura |
|-----------|----------|
| main| ![Coverage Badge](https://github.com/ronihdzz/testing-actions-coverage/blob/artifacts/main/latest/coverage.svg) |
| development| ![Coverage Badge](https://github.com/ronihdzz/testing-actions-coverage/blob/artifacts/development/latest/coverage.svg) |

### Workflow del Proyecto de Ejemplo

A continuación se muestra el código del workflow utilizado en el proyecto:

```yaml
name: Run Tests

on:
  push:
    branches: [main,development]

permissions:
  contents: write

jobs:
  test:
    runs-on: ubuntu-latest
    env:
      COVERAGE_REPORTS: coverage-reports
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports: ['5432:5432']
        options: >-
          --health-cmd="pg_isready" --health-interval=10s --health-timeout=5s --health-retries=5
      mongodb:
        image: mongo:4.4
        ports: ['27017:27017']
        options: >-
          --health-cmd="mongo --eval 'db.runCommand({ ping: 1 })'" --health-interval=10s --health-timeout=5s --health-retries=5
      redis:
        image: redis:6
        ports: ['6379:6379']
        options: >-
          --health-cmd="redis-cli ping" --health-interval=10s --health-timeout=5s --health-retries=5
    steps:
      - name: 🧾 Checkout code
        uses: actions/checkout@v3

      - name: 🏗️ Build test image
        run: docker build --progress=plain -t my-test-image -f docker_images/testing/Dockerfile.testing .

      - name: 🚀 Run tests in container
        run: |
          docker run \
            --name my-tests \
            --network=host \
            -e CI=true \
            -e GITHUB_DATABASE_POSTGRESQL=postgres://test:test@localhost:5432/test_db \
            -e GITHUB_DATABASE_MONGODB=mongodb://localhost:27017 \
            -e GITHUB_DATABASE_REDIS=redis://localhost:6379 \
            -v ${{ github.workspace }}/artifacts:/app/artifacts \
            my-test-image

      - name: 📥 Copiar reportes desde el contenedor
        run: |
          mkdir -p ${{ env.COVERAGE_REPORTS }}
          docker cp my-tests:/app/coverage-reports/. ${{ env.COVERAGE_REPORTS }}
          echo "📄 Archivos copiados desde el contenedor:"
          ls -lh ${{ env.COVERAGE_REPORTS }}
          
      - name: 📤 Subir cobertura como artefacto
        uses: actions/upload-artifact@v4
        with:
          name: ${{ env.COVERAGE_REPORTS }}
          path: ${{ env.COVERAGE_REPORTS }}

      - name: Guardar coverage
        uses: ronihdzz/git-archive-action@v3
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          artifacts-branch: 'artifacts'
          coverage-source: ${{ env.COVERAGE_REPORTS }}
          is-artifact: false
```

### Explicación Detallada del Flujo Real

1. **services**: El workflow define tres servicios (PostgreSQL, MongoDB y Redis) que se inician junto con el job. Gracias a los health-checks, los pasos de prueba no comenzarán hasta que estas bases de datos estén listas para aceptar conexiones, simulando un entorno de producción.

2. **Build test image**: Se construye una imagen de Docker específica para las pruebas. Esto encapsula todas las dependencias del proyecto y garantiza un entorno de prueba consistente.

3. **Run tests in container**: Se ejecuta el contenedor de pruebas con:
   - `--network=host`: Permite que el contenedor se comunique con los servicios de bases de datos que se ejecutan en el runner a través de localhost
   - `-e ...`: Se inyectan las cadenas de conexión a las bases de datos como variables de entorno

4. **Copiar reportes desde el contenedor**: Este es un paso crítico. Una vez que las pruebas terminan dentro del contenedor, los reportes generados existen únicamente dentro del sistema de archivos de ese contenedor. El comando `docker cp` se utiliza para extraer esos reportes desde el contenedor (`my-tests:/app/coverage-reports/.`) hacia el sistema de archivos del runner de GitHub (`${{ env.COVERAGE_REPORTS }}`), haciéndolos accesibles para los siguientes pasos.

5. **Subir cobertura como artefacto**: Este paso utiliza la Action oficial `upload-artifact` para subir los reportes a la sección de "Artifacts" del workflow en la UI de GitHub. Esto es útil para una revisión rápida y para descargas manuales.

6. **Guardar coverage**: Finalmente, se llama a nuestra Action:
   - `uses: ronihdzz/git-archive-action@v3`: Se ejecuta la Action para persistir los reportes
   - `coverage-source: ${{ env.COVERAGE_REPORTS }}`: Se le indica la ruta de la carpeta que contiene los reportes (es la misma carpeta que se creó en el paso "Copiar reportes...")
   - `is-artifact: false`: Es muy importante notar que se usa `false`. Aunque el paso anterior subió un artefacto, nuestra Action en este caso está trabajando con la carpeta local que fue extraída del contenedor con `docker cp`. Esto demuestra la flexibilidad de la Action para trabajar directamente con archivos en el runner.

### Repositorio de la Action Principal

Para más información sobre la Action utilizada en este ejemplo, visita: [ronihdzz/git-archive-action](https://github.com/ronihdzz/git-archive-action)
