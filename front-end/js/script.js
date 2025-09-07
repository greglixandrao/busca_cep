/**
 * Busca CEP - Frontend JavaScript
 * Aplicação para buscar endereços brasileiros através do CEP
 */

class BuscaCEP {
    constructor() {
        // URL da API (pode ser alterada conforme necessário)
        this.apiUrl = 'http://localhost:8001/api/v1'; // Altere para sua URL da API
        
        // Elementos DOM
        this.form = document.getElementById('cepForm');
        this.input = document.getElementById('cepInput');
        this.searchBtn = document.getElementById('searchBtn');
        this.loadingSpinner = document.getElementById('loadingSpinner');
        this.btnText = document.querySelector('.btn-text');
        this.errorMessage = document.getElementById('errorMessage');
        this.resultsSection = document.getElementById('resultsSection');
        this.toast = document.getElementById('toast');
        
        // Elementos de resultado
        this.resultCep = document.getElementById('resultCep');
        this.resultLogradouro = document.getElementById('resultLogradouro');
        this.resultComplemento = document.getElementById('resultComplemento');
        this.resultBairro = document.getElementById('resultBairro');
        this.resultCidade = document.getElementById('resultCidade');
        this.resultEstado = document.getElementById('resultEstado');
        
        // Botões de ação
        this.copyBtn = document.getElementById('copyBtn');
        this.clearBtn = document.getElementById('clearBtn');
        
        this.init();
    }
    
    /**
     * Inicializa a aplicação
     */
    init() {
        this.bindEvents();
        this.setupInputMask();
        console.log('🚀 Busca CEP iniciado com sucesso!');
    }
    
    /**
     * Vincula todos os eventos
     */
    bindEvents() {
        // Submit do formulário
        this.form.addEventListener('submit', (e) => this.handleSubmit(e));
        
        // Validação em tempo real
        this.input.addEventListener('input', () => this.handleInputChange());
        this.input.addEventListener('keypress', (e) => this.handleKeyPress(e));
        
        // Botões de ação
        this.copyBtn.addEventListener('click', () => this.copyAddress());
        this.clearBtn.addEventListener('click', () => this.clearResults());
        
        // Fechar toast ao clicar
        this.toast.addEventListener('click', () => this.hideToast());
        
        // Fechar erro ao focar no input
        this.input.addEventListener('focus', () => this.clearError());
    }
    
    /**
     * Configura máscara de entrada para CEP
     */
    setupInputMask() {
        this.input.addEventListener('input', (e) => {
            let value = e.target.value.replace(/\D/g, ''); // Remove não números
            
            if (value.length > 5) {
                value = value.replace(/(\d{5})(\d)/, '$1-$2');
            }
            
            e.target.value = value;
        });
    }
    
    /**
     * Manipula mudanças no input
     */
    handleInputChange() {
        const cep = this.input.value.replace(/\D/g, '');
        
        // Remove erro se CEP está sendo digitado
        if (cep.length > 0) {
            this.clearError();
        }
        
        // Auto busca quando CEP completo for digitado
        if (cep.length === 8) {
            setTimeout(() => this.searchCep(), 300);
        }
    }
    
    /**
     * Manipula teclas pressionadas
     */
    handleKeyPress(e) {
        // Permite apenas números, backspace, delete e tab
        const allowedKeys = ['Backspace', 'Delete', 'Tab', 'ArrowLeft', 'ArrowRight'];
        const isNumber = /[0-9]/.test(e.key);
        
        if (!isNumber && !allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    }
    
    /**
     * Manipula o submit do formulário
     */
    async handleSubmit(e) {
        e.preventDefault();
        await this.searchCep();
    }
    
    /**
     * Busca o CEP na API
     */
    async searchCep() {
        const cep = this.input.value.replace(/\D/g, '');
        
        // Validação
        if (!this.validateCep(cep)) {
            return;
        }
        
        try {
            this.setLoading(true);
            this.clearError();
            
            const response = await fetch(`${this.apiUrl}/cep/${cep}`);
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.detail || 'Erro ao buscar CEP');
            }
            
            this.displayResults(data);
            this.showToast('✅ Endereço encontrado com sucesso!', 'success');
            
        } catch (error) {
            console.error('Erro ao buscar CEP:', error);
            this.showError(this.getErrorMessage(error));
            this.showToast('❌ ' + this.getErrorMessage(error), 'error');
            this.hideResults();
        } finally {
            this.setLoading(false);
        }
    }
    
    /**
     * Valida o CEP inserido
     */
    validateCep(cep) {
        if (!cep) {
            this.showError('Por favor, digite um CEP');
            this.input.focus();
            return false;
        }
        
        if (cep.length !== 8) {
            this.showError('CEP deve conter exatamente 8 dígitos');
            this.input.focus();
            return false;
        }
        
        // Validação adicional: CEP não pode ser sequencial
        if (/^(\d)\1{7}$/.test(cep)) {
            this.showError('CEP inválido');
            this.input.focus();
            return false;
        }
        
        return true;
    }
    
    /**
     * Exibe os resultados da busca
     */
    displayResults(data) {
        // Preenche os campos com animação
        this.animateValue(this.resultCep, data.cep);
        this.animateValue(this.resultLogradouro, data.logradouro || 'Não informado');
        this.animateValue(this.resultComplemento, data.complemento || 'Não informado');
        this.animateValue(this.resultBairro, data.bairro || 'Não informado');
        this.animateValue(this.resultCidade, data.localidade || 'Não informado');
        this.animateValue(this.resultEstado, data.uf || 'Não informado');
        
        // Mostra seção de resultados com animação
        this.showResults();
        
        // Armazena dados para cópia
        this.lastResult = data;
    }
    
    /**
     * Anima a atualização de valores
     */
    animateValue(element, newValue) {
        element.style.opacity = '0.5';
        element.style.transform = 'translateY(-10px)';
        
        setTimeout(() => {
            element.textContent = newValue;
            element.style.opacity = '1';
            element.style.transform = 'translateY(0)';
        }, 150);
    }
    
    /**
     * Mostra a seção de resultados
     */
    showResults() {
        this.resultsSection.classList.add('show');
        this.resultsSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
    
    /**
     * Esconde a seção de resultados
     */
    hideResults() {
        this.resultsSection.classList.remove('show');
    }
    
    /**
     * Copia o endereço para a área de transferência
     */
    async copyAddress() {
        if (!this.lastResult) return;
        
        const address = [
            `CEP: ${this.lastResult.cep}`,
            `Logradouro: ${this.lastResult.logradouro || 'Não informado'}`,
            `Complemento: ${this.lastResult.complemento || 'Não informado'}`,
            `Bairro: ${this.lastResult.bairro || 'Não informado'}`,
            `Cidade: ${this.lastResult.localidade || 'Não informado'}`,
            `Estado: ${this.lastResult.uf || 'Não informado'}`
        ].join('\n');
        
        try {
            await navigator.clipboard.writeText(address);
            this.showToast('📋 Endereço copiado para a área de transferência!', 'success');
            
            // Feedback visual no botão
            const originalText = this.copyBtn.innerHTML;
            this.copyBtn.innerHTML = '<i class="fas fa-check"></i> Copiado!';
            this.copyBtn.style.background = '#059669';
            
            setTimeout(() => {
                this.copyBtn.innerHTML = originalText;
                this.copyBtn.style.background = '';
            }, 2000);
            
        } catch (error) {
            console.error('Erro ao copiar:', error);
            this.showToast('❌ Erro ao copiar endereço', 'error');
        }
    }
    
    /**
     * Limpa os resultados e reinicia
     */
    clearResults() {
        this.hideResults();
        this.input.value = '';
        this.input.focus();
        this.clearError();
        this.lastResult = null;
        this.showToast('🔄 Pronto para nova busca!', 'success');
    }
    
    /**
     * Define estado de loading
     */
    setLoading(loading) {
        if (loading) {
            this.searchBtn.classList.add('loading');
            this.searchBtn.disabled = true;
        } else {
            this.searchBtn.classList.remove('loading');
            this.searchBtn.disabled = false;
        }
    }
    
    /**
     * Exibe mensagem de erro
     */
    showError(message) {
        this.errorMessage.textContent = message;
        this.errorMessage.classList.add('show');
        this.input.style.borderColor = 'var(--error)';
    }
    
    /**
     * Limpa mensagem de erro
     */
    clearError() {
        this.errorMessage.classList.remove('show');
        this.input.style.borderColor = '';
    }
    
    /**
     * Exibe toast notification
     */
    showToast(message, type = 'success') {
        this.toast.textContent = message;
        this.toast.className = `toast ${type} show`;
        
        // Auto hide após 3 segundos
        setTimeout(() => {
            this.hideToast();
        }, 3000);
    }
    
    /**
     * Esconde toast notification
     */
    hideToast() {
        this.toast.classList.remove('show');
    }
    
    /**
     * Obtém mensagem de erro amigável
     */
    getErrorMessage(error) {
        const message = error.message.toLowerCase();
        
        if (message.includes('not found') || message.includes('404') || message.includes('não encontrado')) {
            return 'CEP não encontrado. Verifique se está correto.';
        }
        
        if (message.includes('network') || message.includes('fetch')) {
            return 'Erro de conexão. Verifique sua internet.';
        }
        
        if (message.includes('timeout')) {
            return 'Tempo limite excedido. Tente novamente.';
        }
        
        if (message.includes('400') || message.includes('inválido')) {
            return 'CEP inválido. Digite apenas números.';
        }
        
        return 'Erro inesperado. Tente novamente.';
    }
}

/**
 * Utilitários globais
 */

// Detecta se está em modo escuro do sistema
function detectDarkMode() {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
}

// Adiciona animação de entrada aos elementos
function addEntranceAnimations() {
    const elements = document.querySelectorAll('.search-card, .info-card');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in-up');
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    });
    
    elements.forEach(el => observer.observe(el));
}

// Adiciona efeitos de partículas no fundo (opcional)
function createParticleEffect() {
    const canvas = document.createElement('canvas');
    canvas.style.position = 'fixed';
    canvas.style.top = '0';
    canvas.style.left = '0';
    canvas.style.width = '100%';
    canvas.style.height = '100%';
    canvas.style.pointerEvents = 'none';
    canvas.style.zIndex = '-1';
    canvas.style.opacity = '0.1';
    
    document.body.appendChild(canvas);
    
    const ctx = canvas.getContext('2d');
    let particles = [];
    
    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }
    
    function createParticle() {
        return {
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            vx: (Math.random() - 0.5) * 0.5,
            vy: (Math.random() - 0.5) * 0.5,
            size: Math.random() * 2 + 1
        };
    }
    
    function updateParticles() {
        particles.forEach(particle => {
            particle.x += particle.vx;
            particle.y += particle.vy;
            
            if (particle.x < 0 || particle.x > canvas.width) particle.vx *= -1;
            if (particle.y < 0 || particle.y > canvas.height) particle.vy *= -1;
        });
    }
    
    function drawParticles() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = '#6366f1';
        
        particles.forEach(particle => {
            ctx.beginPath();
            ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
            ctx.fill();
        });
    }
    
    function animate() {
        updateParticles();
        drawParticles();
        requestAnimationFrame(animate);
    }
    
    window.addEventListener('resize', resizeCanvas);
    resizeCanvas();
    
    // Criar partículas
    for (let i = 0; i < 50; i++) {
        particles.push(createParticle());
    }
    
    animate();
}

/**
 * Inicialização da aplicação
 */
document.addEventListener('DOMContentLoaded', () => {
    // Inicializa aplicação principal
    const app = new BuscaCEP();
    
    // Adiciona animações
    addEntranceAnimations();
    
    // Adiciona efeito de partículas (descomente se desejar)
    // createParticleEffect();
    
    // Log de inicialização
    console.log('%c🚀 Busca CEP Frontend carregado com sucesso!', 
        'color: #6366f1; font-size: 16px; font-weight: bold;');
    
    console.log('%cDesenvolvido com ❤️ por Greg Lixandrão', 
        'color: #10b981; font-size: 12px;');
});
