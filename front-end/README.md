# 🌐 Busca CEP - Frontend

Interface web moderna e elegante para consulta de CEP brasileiro, desenvolvida com HTML, CSS e JavaScript puro.

## ✨ Características

### 🎨 Design
- **Tema escuro moderno** com gradientes suaves
- **Interface responsiva** que funciona em todos os dispositivos
- **Animações fluidas** e transições suaves
- **Feedback visual** em tempo real
- **Componentes glassmorphism** com blur effects

### 🚀 Funcionalidades
- **Busca automática** quando CEP completo é digitado
- **Máscara de entrada** automática (00000-000)
- **Validação em tempo real** com mensagens amigáveis
- **Copiar endereço** para área de transferência
- **Toast notifications** para feedback do usuário
- **Estados de loading** com spinners animados
- **Tratamento de erros** inteligente

### 📱 Responsividade
- **Mobile-first** design
- **Breakpoints otimizados** para todos os tamanhos
- **Touch-friendly** interface
- **Performance otimizada** para dispositivos móveis

## 📁 Estrutura do Projeto

```
front-end/
├── index.html              # Página principal
├── css/
│   └── styles.css         # Estilos CSS modernos
├── js/
│   └── script.js         # Lógica JavaScript
├── assets/
│   └── images/          # Imagens (se houver)
└── README.md           # Esta documentação
```

## 🔧 Configuração

### Pré-requisitos
- **Docker** e Docker Compose (recomendado)
- **Navegador moderno** (Chrome 80+, Firefox 75+, Safari 13+)
- **Servidor HTTP local** (opcional para desenvolvimento)

### Instalação

#### Opção A: Docker (Recomendado)

1. **Clone o repositório:**
```bash
git clone <url-do-repositorio>
cd busca_cep/front-end
```

2. **Construa a imagem:**
```bash
docker build -t greglixandrao/busca-cep-frontend .
```

3. **Execute o container:**
```bash
docker run -d -p 3000:3000 --name busca-cep-frontend greglixandrao/busca-cep-frontend
```

#### Opção B: Desenvolvimento Local

1. **Clone o repositório:**
```bash
git clone <url-do-repositorio>
cd busca_cep/front-end
```

2. **Abrir diretamente no navegador:**
```bash
open index.html
# ou
xdg-open index.html  # Linux
```

3. **Ou usar servidor HTTP local:**
```bash
# Python 3
python -m http.server 3000

# Python 2
python -m SimpleHTTPServer 3000

# Node.js
npx serve .

# PHP
php -S localhost:3000
```

### Configuração da API
No arquivo `js/script.js`, atualize a URL da API:

```javascript
// Linha 9
this.apiUrl = 'http://localhost:8001/api/v1'; // Sua URL da API
```

## 🎯 Como Usar

1. **Abra a aplicação** no navegador
2. **Digite um CEP** no campo de entrada (com ou sem hífen)
3. **Pressione Enter** ou clique em "Buscar Endereço"
4. **Veja os resultados** aparecerem com animação
5. **Copie o endereço** clicando no botão "Copiar Endereço"
6. **Faça nova busca** clicando em "Nova Busca"

### Exemplos de CEP para teste:
- `01310-100` - Avenida Paulista, São Paulo
- `20040020` - Centro, Rio de Janeiro
- `30112000` - Centro, Belo Horizonte

## 🎨 Customização

### Cores (CSS Variables)
```css
:root {
    --primary-color: #6366f1;      /* Cor principal */
    --primary-light: #8b5cf6;      /* Cor clara */
    --bg-primary: #0f0f23;         /* Fundo principal */
    --bg-secondary: #1a1a2e;       /* Fundo secundário */
    --text-primary: #ffffff;       /* Texto principal */
    /* ... mais variáveis */
}
```

### Tipografia
- Fonte principal: **Inter** (Google Fonts)
- Fallbacks: system fonts (-apple-system, BlinkMacSystemFont, etc.)

### Breakpoints
- **Mobile**: < 480px
- **Tablet**: 481px - 768px
- **Desktop**: > 768px

## 🔌 Integração com API

### URL Base
```javascript
const apiUrl = 'http://localhost:8001/api/v1';
```

### Endpoints Utilizados
- `GET /cep/{cep}` - Buscar CEP
- `GET /health` - Health check (futuro uso)

### Formato de Resposta Esperado
```json
{
  "cep": "01310-100",
  "logradouro": "Avenida Paulista",
  "complemento": "de 612 a 1510 - lado par",
  "bairro": "Bela Vista",
  "localidade": "São Paulo",
  "uf": "SP"
}
```

### Tratamento de Erros
- **400**: CEP inválido
- **404**: CEP não encontrado
- **500**: Erro interno do servidor
- **Network**: Erro de conexão

## 🚀 Deploy

### GitHub Pages
1. Faça push do código para o GitHub
2. Vá em Settings > Pages
3. Selecione a branch main
4. A aplicação estará disponível em `https://seu-usuario.github.io/repositorio`

### Netlify
1. Arraste a pasta `front-end` para [netlify.com/drop](https://netlify.com/drop)
2. Ou conecte seu repositório GitHub no Netlify

### Vercel
1. Instale a CLI: `npm i -g vercel`
2. Execute: `vercel` na pasta do projeto

### Servidor próprio
1. Faça upload dos arquivos para seu servidor web
2. Configure o servidor para servir arquivos estáticos

## 🔧 Tecnologias Utilizadas

### HTML5
- Semântica moderna
- Acessibilidade (ARIA)
- Meta tags otimizadas
- Progressive Enhancement

### CSS3
- CSS Grid e Flexbox
- Custom Properties (CSS Variables)
- Animações e transições
- Media queries responsivas
- Glassmorphism effects

### JavaScript (ES6+)
- Classes e módulos
- Async/await
- Fetch API
- Event listeners modernos
- Intersection Observer API

### Bibliotecas Externas
- **Font Awesome** 6.4.0 - Ícones
- **Inter Font** - Tipografia
- **Google Fonts** - Web fonts

## 📊 Performance

### Métricas
- **First Contentful Paint**: < 1.5s
- **Largest Contentful Paint**: < 2.5s
- **Cumulative Layout Shift**: < 0.1
- **First Input Delay**: < 100ms

### Otimizações
- CSS e JS minificados em produção
- Imagens otimizadas (WebP quando possível)
- Fontes pré-carregadas
- Critical CSS inline
- Service Worker (futuro)

## 🧪 Testes

### Testes manuais
- [ ] Busca por CEP válido
- [ ] Busca por CEP inválido
- [ ] Busca por CEP inexistente
- [ ] Cópia de endereço
- [ ] Responsividade em diferentes telas
- [ ] Acessibilidade com teclado
- [ ] Modo escuro/claro

### Compatibilidade testada
- ✅ Chrome 80+
- ✅ Firefox 75+
- ✅ Safari 13+
- ✅ Edge 80+
- ✅ Mobile Chrome/Safari

## 🔒 Segurança

- **HTTPS obrigatório** em produção
- **CORS configurado** no backend
- **Input sanitization** implementada
- **CSP headers** recomendados
- **Rate limiting** no backend

## 🎯 Melhorias Futuras

### Versão 2.0
- [ ] PWA (Progressive Web App)
- [ ] Service Worker para cache offline
- [ ] Histórico de buscas
- [ ] Favoritos/salvos
- [ ] Busca por endereço (reversa)
- [ ] Integração com mapas
- [ ] Modo claro/escuro toggle
- [ ] Internacionalização (i18n)

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch: `git checkout -b feature/nova-feature`
3. Commit suas mudanças: `git commit -m 'Adiciona nova feature'`
4. Push para a branch: `git push origin feature/nova-feature`
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👨‍💻 Desenvolvedor

**Greg Lixandrão**
- GitHub: [@greglixandrao](https://github.com/greglixandrao)
- Email: greg@exemplo.com

---

Desenvolvido com ❤️ usando HTML, CSS e JavaScript puro.
