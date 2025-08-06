#!/bin/bash
# benchmark-tools.sh - Sistema de benchmarking para herramientas CLI

set -euo pipefail

# Configuración
BENCHMARK_DIR="/tmp/homebrew-cli-benchmarks"
RESULTS_FILE="benchmark-results.json"
TEST_DATA_SIZE="1000000"  # 1M lines
ITERATIONS=5

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Crear datos de prueba
setup_test_data() {
    log "Setting up test data..."
    mkdir -p "$BENCHMARK_DIR"
    cd "$BENCHMARK_DIR"
    
    # Generar archivo de texto grande
    if [[ ! -f "large_text.txt" ]]; then
        log "Generating large text file ($TEST_DATA_SIZE lines)..."
        for i in $(seq 1 $TEST_DATA_SIZE); do
            echo "Line $i: $(date) - Random text content with pattern_$((RANDOM % 100))"
        done > large_text.txt
    fi
    
    # Generar estructura de directorios
    if [[ ! -d "test_dirs" ]]; then
        log "Generating directory structure..."
        mkdir -p test_dirs
        for i in $(seq 1 100); do
            mkdir -p "test_dirs/dir_$i"
            for j in $(seq 1 10); do
                touch "test_dirs/dir_$i/file_$j.txt"
                touch "test_dirs/dir_$i/file_$j.js"
                touch "test_dirs/dir_$i/file_$j.py"
            done
        done
    fi
    
    # Generar archivo JSON
    if [[ ! -f "data.json" ]]; then
        log "Generating JSON data..."
        echo '[' > data.json
        for i in $(seq 1 1000); do
            cat >> data.json << EOF
  {
    "id": $i,
    "name": "Item $i",
    "status": "$([ $((i % 3)) -eq 0 ] && echo "active" || echo "inactive")",
    "value": $((RANDOM % 1000)),
    "timestamp": "$(date -Iseconds)"
  }$([ $i -lt 1000 ] && echo "," || echo "")
EOF
        done
        echo ']' >> data.json
    fi
    
    success "Test data ready in $BENCHMARK_DIR"
}

# Función para medir tiempo
benchmark_command() {
    local name="$1"
    local command="$2"
    local description="$3"
    
    log "Benchmarking: $name"
    echo "  Command: $command"
    echo "  Description: $description"
    
    local times=()
    local total_time=0
    
    for i in $(seq 1 $ITERATIONS); do
        local start_time=$(date +%s.%N)
        eval "$command" > /dev/null 2>&1
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l)
        times+=($duration)
        total_time=$(echo "$total_time + $duration" | bc -l)
        printf "    Run %d: %.3fs\n" $i $duration
    done
    
    local avg_time=$(echo "scale=3; $total_time / $ITERATIONS" | bc -l)
    printf "    Average: ${GREEN}%.3fs${NC}\n\n" $avg_time
    
    # Guardar resultado en JSON
    cat >> "$RESULTS_FILE" << EOF
  {
    "name": "$name",
    "command": "$command", 
    "description": "$description",
    "average_time": $avg_time,
    "iterations": $ITERATIONS,
    "individual_times": [$(IFS=,; echo "${times[*]}")]
  },
EOF
}

# Benchmarks de búsqueda
benchmark_search_tools() {
    log "=== SEARCH TOOLS BENCHMARKS ==="
    
    benchmark_command \
        "find (traditional)" \
        "find test_dirs -name '*.js'" \
        "Traditional find command for JavaScript files"
    
    if command -v fd &> /dev/null; then
        benchmark_command \
            "fd (modern)" \
            "fd -e js . test_dirs" \
            "Modern fd command for JavaScript files"
    else
        warning "fd not installed, skipping benchmark"
    fi
    
    benchmark_command \
        "grep (traditional)" \
        "grep -r 'pattern_50' test_dirs/" \
        "Traditional grep for pattern search"
    
    if command -v rg &> /dev/null; then
        benchmark_command \
            "ripgrep (modern)" \
            "rg 'pattern_50' test_dirs/" \
            "Modern ripgrep for pattern search"
    else
        warning "ripgrep not installed, skipping benchmark"
    fi
}

# Benchmarks de procesamiento de texto
benchmark_text_tools() {
    log "=== TEXT PROCESSING BENCHMARKS ==="
    
    benchmark_command \
        "cat (traditional)" \
        "cat large_text.txt" \
        "Traditional cat command"
    
    if command -v bat &> /dev/null; then
        benchmark_command \
            "bat (modern)" \
            "bat --plain large_text.txt" \
            "Modern bat command (plain mode)"
    else
        warning "bat not installed, skipping benchmark"
    fi
    
    benchmark_command \
        "wc lines (traditional)" \
        "wc -l large_text.txt" \
        "Traditional word count"
    
    if command -v tokei &> /dev/null; then
        benchmark_command \
            "tokei (modern)" \
            "tokei --files large_text.txt" \
            "Modern tokei for file analysis"
    else
        warning "tokei not installed, skipping benchmark"
    fi
}

# Benchmarks de JSON
benchmark_json_tools() {
    log "=== JSON PROCESSING BENCHMARKS ==="
    
    if command -v jq &> /dev/null; then
        benchmark_command \
            "jq filter" \
            "jq '.[] | select(.status == \"active\")' data.json" \
            "Filter active items with jq"
        
        benchmark_command \
            "jq transform" \
            "jq 'map({id, name, active: (.status == \"active\")})' data.json" \
            "Transform data structure with jq"
    else
        warning "jq not installed, skipping JSON benchmarks"
    fi
}

# Generar reporte
generate_report() {
    log "Generating performance report..."
    
    # Finalizar JSON
    sed -i '' '$ s/,$//' "$RESULTS_FILE" 2>/dev/null || sed -i '$ s/,$//' "$RESULTS_FILE"
    echo ']' >> "$RESULTS_FILE"
    
    # Generar reporte HTML
    cat > "benchmark-report.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>CLI Tools Benchmark Report</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .benchmark { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
        .faster { background-color: #e8f5e8; }
        .slower { background-color: #ffebee; }
        canvas { max-width: 600px; }
    </style>
</head>
<body>
    <h1>🚀 CLI Tools Performance Benchmark</h1>
    <div id="results"></div>
    <canvas id="chart"></canvas>
    
    <script>
        fetch('./benchmark-results.json')
            .then(response => response.json())
            .then(data => {
                displayResults(data);
                createChart(data);
            });
        
        function displayResults(data) {
            const container = document.getElementById('results');
            data.forEach(result => {
                const div = document.createElement('div');
                div.className = 'benchmark';
                div.innerHTML = `
                    <h3>${result.name}</h3>
                    <p><strong>Command:</strong> <code>${result.command}</code></p>
                    <p><strong>Description:</strong> ${result.description}</p>
                    <p><strong>Average Time:</strong> ${result.average_time}s</p>
                `;
                container.appendChild(div);
            });
        }
        
        function createChart(data) {
            const ctx = document.getElementById('chart').getContext('2d');
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.map(d => d.name),
                    datasets: [{
                        label: 'Average Time (seconds)',
                        data: data.map(d => d.average_time),
                        backgroundColor: 'rgba(75, 192, 192, 0.6)',
                        borderColor: 'rgba(75, 192, 192, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });
        }
    </script>
</body>
</html>
EOF
    
    success "Benchmark report generated: benchmark-report.html"
    success "Raw results available: $RESULTS_FILE"
}

# Función principal
main() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                         🚀 CLI Tools Benchmark Suite                           ║"
    echo "║                     Measuring performance of modern vs traditional tools       ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Verificar dependencias
    if ! command -v bc &> /dev/null; then
        error "bc calculator is required for benchmarks"
        exit 1
    fi
    
    # Inicializar archivo de resultados
    echo '[' > "$RESULTS_FILE"
    
    setup_test_data
    benchmark_search_tools
    benchmark_text_tools
    benchmark_json_tools
    generate_report
    
    echo -e "\n${GREEN}🎉 Benchmark completed!${NC}"
    echo "Results saved in: $BENCHMARK_DIR"
    echo "Open benchmark-report.html in your browser to view results"
    
    # Cleanup opcional
    read -p "Remove test data? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf test_dirs large_text.txt data.json
        success "Test data cleaned up"
    fi
}

# Verificar argumentos
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo "  --cleanup     Remove any existing test data"
    echo ""
    echo "This script benchmarks traditional vs modern CLI tools."
    echo "Results are saved as JSON and HTML report."
    exit 0
fi

if [[ "${1:-}" == "--cleanup" ]]; then
    log "Cleaning up previous benchmark data..."
    rm -rf "$BENCHMARK_DIR"
    success "Cleanup completed"
    exit 0
fi

# Ejecutar benchmark
main
