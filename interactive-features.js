/**
 * CLI Tools Guide - Interactive Features
 * Funcionalidades interactivas para el libro Quarto
 */

class CLIGuideInteractive {
    constructor() {
        this.apiUrl = 'http://localhost:3000';
        this.savedSnippets = JSON.parse(localStorage.getItem('cliSnippets') || '[]');
        this.init();
    }

    init() {
        this.setupToolbar();
        this.setupCodeBlocks();
        this.setupKeyboardShortcuts();
        this.loadSavedSnippets();
        this.detectAPIConnection();
    }

    // Configurar toolbar flotante
    setupToolbar() {
        const toolbar = document.getElementById('floating-toolbar');
        if (!toolbar) return;

        // Botón de edición de código
        const editBtn = document.getElementById('edit-code-btn');
        editBtn?.addEventListener('click', () => this.toggleCodeEditor());

        // Botón de ejecución
        const runBtn = document.getElementById('run-code-btn');
        runBtn?.addEventListener('click', () => this.runCurrentCode());

        // Botón de guardar snippet
        const saveBtn = document.getElementById('save-snippet-btn');
        saveBtn?.addEventListener('click', () => this.saveCurrentSnippet());

        // Botón de prueba con API
        const apiBtn = document.getElementById('api-test-btn');
        apiBtn?.addEventListener('click', () => this.testWithAPI());
    }

    // Hacer bloques de código interactivos
    setupCodeBlocks() {
        const codeBlocks = document.querySelectorAll('pre code');
        codeBlocks.forEach((block, index) => {
            this.makeCodeBlockInteractive(block, index);
        });
    }

    makeCodeBlockInteractive(codeBlock, index) {
        const pre = codeBlock.parentElement;
        const wrapper = document.createElement('div');
        wrapper.className = 'code-block-interactive';
        wrapper.id = `code-block-${index}`;

        // Header del bloque de código
        const header = document.createElement('div');
        header.className = 'code-header';
        header.innerHTML = `
            <span><i class="fas fa-terminal"></i> Código Interactivo</span>
            <div class="code-actions">
                <button class="code-action-btn" onclick="cliGuide.editCode(${index})" title="Editar">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="code-action-btn" onclick="cliGuide.copyCode(${index})" title="Copiar">
                    <i class="fas fa-copy"></i>
                </button>
                <button class="code-action-btn" onclick="cliGuide.runCode(${index})" title="Ejecutar">
                    <i class="fas fa-play"></i>
                </button>
                <button class="code-action-btn" onclick="cliGuide.saveCode(${index})" title="Guardar">
                    <i class="fas fa-save"></i>
                </button>
            </div>
        `;

        // Envolver el código original
        pre.parentNode.insertBefore(wrapper, pre);
        wrapper.appendChild(header);
        wrapper.appendChild(pre);

        // Almacenar código original
        wrapper.dataset.originalCode = codeBlock.textContent;
    }

    // Editar código en línea
    editCode(blockIndex) {
        const wrapper = document.getElementById(`code-block-${blockIndex}`);
        const pre = wrapper.querySelector('pre');
        const originalCode = wrapper.dataset.originalCode;

        // Crear editor en línea
        const editor = document.createElement('textarea');
        editor.className = 'inline-editor';
        editor.value = originalCode;
        editor.placeholder = 'Edita tu código aquí...';

        // Botones del editor
        const editorActions = document.createElement('div');
        editorActions.className = 'editor-actions';
        editorActions.style.padding = '10px';
        editorActions.style.background = '#f8f9fa';
        editorActions.innerHTML = `
            <button class="btn btn-primary btn-sm" onclick="cliGuide.applyEdit(${blockIndex})">
                <i class="fas fa-check"></i> Aplicar
            </button>
            <button class="btn btn-secondary btn-sm" onclick="cliGuide.cancelEdit(${blockIndex})">
                <i class="fas fa-times"></i> Cancelar
            </button>
        `;

        // Reemplazar temporalmente
        pre.style.display = 'none';
        wrapper.appendChild(editor);
        wrapper.appendChild(editorActions);
        
        editor.focus();
    }

    applyEdit(blockIndex) {
        const wrapper = document.getElementById(`code-block-${blockIndex}`);
        const editor = wrapper.querySelector('.inline-editor');
        const pre = wrapper.querySelector('pre');
        const code = pre.querySelector('code');

        // Actualizar código
        code.textContent = editor.value;
        wrapper.dataset.originalCode = editor.value;

        // Limpiar editor
        this.cancelEdit(blockIndex);

        // Re-highlight si existe Prism o similar
        if (window.Prism) {
            Prism.highlightElement(code);
        }

        this.showNotification('Código actualizado', 'success');
    }

    cancelEdit(blockIndex) {
        const wrapper = document.getElementById(`code-block-${blockIndex}`);
        const editor = wrapper.querySelector('.inline-editor');
        const editorActions = wrapper.querySelector('.editor-actions');
        const pre = wrapper.querySelector('pre');

        if (editor) editor.remove();
        if (editorActions) editorActions.remove();
        pre.style.display = 'block';
    }

    // Copiar código
    copyCode(blockIndex) {
        const wrapper = document.getElementById(`code-block-${blockIndex}`);
        const code = wrapper.dataset.originalCode;

        navigator.clipboard.writeText(code).then(() => {
            this.showNotification('Código copiado al portapapeles', 'success');
        }).catch(() => {
            this.showNotification('Error al copiar código', 'error');
        });
    }

    // Ejecutar código (simulado)
    async runCode(blockIndex) {
        const wrapper = document.getElementById(`code-block-${blockIndex}`);
        const code = wrapper.dataset.originalCode;

        // Mostrar indicador de carga
        this.showNotification('Ejecutando código...', 'info');

        // Crear área de resultados
        let resultArea = wrapper.querySelector('.execution-result');
        if (!resultArea) {
            resultArea = document.createElement('div');
            resultArea.className = 'execution-result';
            wrapper.appendChild(resultArea);
        }

        try {
            // Simular ejecución o enviar a API local
            const result = await this.executeCode(code);
            resultArea.textContent = result;
            resultArea.className = 'execution-result success';
            this.showNotification('Código ejecutado exitosamente', 'success');
        } catch (error) {
            resultArea.textContent = `Error: ${error.message}`;
            resultArea.className = 'execution-result error';
            this.showNotification('Error en la ejecución', 'error');
        }
    }

    // Ejecutar código a través de API local
    async executeCode(code) {
        // Detectar tipo de comando
        if (code.trim().startsWith('brew ')) {
            return await this.executeBrew(code);
        } else {
            return await this.executeShell(code);
        }
    }

    async executeBrew(command) {
        // Simular ejecución de comando brew
        return `$ ${command}
🍺 Simulando ejecución de Homebrew...
✅ Comando procesado correctamente
💡 Tip: Este es un entorno simulado. Para ejecución real, copia el comando a tu terminal.`;
    }

    async executeShell(command) {
        // Simular ejecución de comando shell
        return `$ ${command}
📋 Salida simulada del comando
🔍 Funcionalidad disponible en modo interactivo
💡 Usa el CLI local para ejecución real: ./scripts/cli-guide`;
    }

    // Guardar snippet
    saveCode(blockIndex) {
        const wrapper = document.getElementById(`code-block-${blockIndex}`);
        const code = wrapper.dataset.originalCode;
        
        const snippet = {
            id: Date.now(),
            code: code,
            timestamp: new Date().toISOString(),
            title: `Snippet del bloque ${blockIndex + 1}`
        };

        this.savedSnippets.push(snippet);
        localStorage.setItem('cliSnippets', JSON.stringify(this.savedSnippets));
        
        this.showNotification('Snippet guardado', 'success');
        this.updateSnippetsDisplay();
    }

    // Cargar snippets guardados
    loadSavedSnippets() {
        this.updateSnippetsDisplay();
    }

    updateSnippetsDisplay() {
        let container = document.getElementById('saved-snippets-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'saved-snippets-container';
            container.className = 'saved-snippets';
            container.innerHTML = '<h3><i class="fas fa-bookmark"></i> Snippets Guardados</h3>';
            document.body.appendChild(container);
        }

        // Limpiar snippets existentes
        const existing = container.querySelectorAll('.snippet-item');
        existing.forEach(item => item.remove());

        // Mostrar snippets
        this.savedSnippets.forEach(snippet => {
            const item = document.createElement('div');
            item.className = 'snippet-item';
            item.innerHTML = `
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <strong>${snippet.title}</strong>
                    <div>
                        <button class="code-action-btn" onclick="cliGuide.useSnippet('${snippet.id}')" title="Usar">
                            <i class="fas fa-play"></i>
                        </button>
                        <button class="code-action-btn" onclick="cliGuide.deleteSnippet('${snippet.id}')" title="Eliminar">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
                <pre style="background: rgba(0,0,0,0.2); padding: 10px; border-radius: 4px; margin-top: 8px;"><code>${snippet.code}</code></pre>
                <small>Guardado: ${new Date(snippet.timestamp).toLocaleString()}</small>
            `;
            container.appendChild(item);
        });
    }

    useSnippet(snippetId) {
        const snippet = this.savedSnippets.find(s => s.id == snippetId);
        if (snippet) {
            navigator.clipboard.writeText(snippet.code);
            this.showNotification('Snippet copiado al portapapeles', 'success');
        }
    }

    deleteSnippet(snippetId) {
        this.savedSnippets = this.savedSnippets.filter(s => s.id != snippetId);
        localStorage.setItem('cliSnippets', JSON.stringify(this.savedSnippets));
        this.updateSnippetsDisplay();
        this.showNotification('Snippet eliminado', 'info');
    }

    // Configurar atajos de teclado
    setupKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // Ctrl/Cmd + E = Editar código activo
            if ((e.ctrlKey || e.metaKey) && e.key === 'e') {
                e.preventDefault();
                this.toggleCodeEditor();
            }

            // Ctrl/Cmd + R = Ejecutar código activo
            if ((e.ctrlKey || e.metaKey) && e.key === 'r') {
                e.preventDefault();
                this.runCurrentCode();
            }

            // Ctrl/Cmd + S = Guardar snippet
            if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                e.preventDefault();
                this.saveCurrentSnippet();
            }
        });
    }

    // Detectar conexión con API
    async detectAPIConnection() {
        try {
            const response = await fetch(`${this.apiUrl}/health`);
            if (response.ok) {
                this.showNotification('API local conectada', 'success');
                document.getElementById('api-test-btn').style.background = 'rgba(46, 204, 113, 0.3)';
            }
        } catch (error) {
            console.log('API local no disponible');
        }
    }

    // Probar con API
    async testWithAPI() {
        try {
            const response = await fetch(`${this.apiUrl}/tools`);
            const data = await response.json();
            
            this.showNotification(`API funcionando: ${data.length} herramientas disponibles`, 'success');
            
            // Mostrar datos en modal o sidebar
            this.showAPIData(data);
        } catch (error) {
            this.showNotification('API no disponible. Inicia el servidor local.', 'warning');
        }
    }

    showAPIData(data) {
        // Crear modal simple para mostrar datos de API
        const modal = document.createElement('div');
        modal.className = 'api-modal';
        modal.style.cssText = `
            position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
            background: white; padding: 20px; border-radius: 8px; box-shadow: 0 8px 25px rgba(0,0,0,0.3);
            max-width: 80%; max-height: 80%; overflow-y: auto; z-index: 2000;
        `;

        modal.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <h3>🔗 Datos de API</h3>
                <button onclick="this.parentElement.parentElement.remove()" style="background: none; border: none; font-size: 18px; cursor: pointer;">&times;</button>
            </div>
            <pre style="background: #f8f9fa; padding: 15px; border-radius: 4px; overflow-x: auto; max-height: 400px;">${JSON.stringify(data.slice(0, 5), null, 2)}</pre>
            <p><strong>Total de herramientas:</strong> ${data.length}</p>
        `;

        document.body.appendChild(modal);

        // Cerrar al hacer clic fuera
        const overlay = document.createElement('div');
        overlay.style.cssText = 'position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1999;';
        overlay.onclick = () => {
            modal.remove();
            overlay.remove();
        };
        document.body.appendChild(overlay);
    }

    // Mostrar notificaciones
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.style.cssText = `
            position: fixed; top: 20px; right: 20px; padding: 12px 20px;
            background: ${type === 'success' ? '#2ECC71' : type === 'error' ? '#E74C3C' : type === 'warning' ? '#F39C12' : '#31BAE9'};
            color: white; border-radius: 6px; box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            z-index: 3000; transform: translateX(400px); transition: all 0.3s ease;
        `;
        notification.textContent = message;

        document.body.appendChild(notification);

        // Animación de entrada
        setTimeout(() => {
            notification.style.transform = 'translateX(0)';
        }, 10);

        // Auto-eliminar
        setTimeout(() => {
            notification.style.transform = 'translateX(400px)';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }

    // Funciones de toolbar
    toggleCodeEditor() {
        // Encontrar el bloque de código más cercano al cursor
        const activeBlock = document.querySelector('.code-block-interactive:hover') || 
                           document.querySelector('.code-block-interactive');
        if (activeBlock) {
            const index = parseInt(activeBlock.id.split('-')[2]);
            this.editCode(index);
        }
    }

    runCurrentCode() {
        const activeBlock = document.querySelector('.code-block-interactive:hover') || 
                           document.querySelector('.code-block-interactive');
        if (activeBlock) {
            const index = parseInt(activeBlock.id.split('-')[2]);
            this.runCode(index);
        }
    }

    saveCurrentSnippet() {
        const activeBlock = document.querySelector('.code-block-interactive:hover') || 
                           document.querySelector('.code-block-interactive');
        if (activeBlock) {
            const index = parseInt(activeBlock.id.split('-')[2]);
            this.saveCode(index);
        }
    }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    window.cliGuide = new CLIGuideInteractive();
});

// Funciones globales para compatibilidad
function editCode(index) { window.cliGuide?.editCode(index); }
function copyCode(index) { window.cliGuide?.copyCode(index); }
function runCode(index) { window.cliGuide?.runCode(index); }
function saveCode(index) { window.cliGuide?.saveCode(index); }
