# 🏠 Busca CEP - Aplicação Completa

Uma aplicação completa para consulta de CEP brasileiro, composta por backend API em Python/FastAPI e frontend web moderno com tema escuro.

## 🚀 Visão Geral

Este projeto oferece uma solução completa para busca de endereços brasileiros através do CEP:

- **Backend**: API REST moderna com FastAPI, containerizada com Docker
- **Frontend**: Interface web responsiva com HTML, CSS e JavaScript puro
- **Integração**: Utiliza a API do ViaCEP para dados precisos e atualizados

## 📁 Estrutura do Projeto

```
busca_cep/
├── backend/                    # API Backend
│   ├── app/
│   │   ├── models/            # Modelos Pydantic
│   │   ├── routers/           # Endpoints da API
│   │   ├── services/          # Serviços (ViaCEP)
│   │   ├── config.py          # Configurações
│   │   └── main.py           # App principal
│   ├── Dockerfile            # Imagem Docker
│   ├── docker-compose.yml    # Orquestração
│   ├── requirements.txt      # Dependências Python
│   └── README.md            # Docs do backend
│
├── front-end/                 # Frontend Web
│   ├── css/
│   │   └── styles.css        # Estilos modernos
│   ├── js/
│   │   └── script.js         # Lógica JavaScript
│   ├── index.html            # Página principal
│   └── README.md            # Docs do frontend
│
└── README.md                 # Este arquivo
```

## ✨ Características

### 🎯 Backend (FastAPI)
- **API REST** moderna e documentada
- **Docker containerizado** para deployment fácil
- **Validação robusta** com Pydantic
- **Tratamento de erros** inteligente
- **CORS configurado** para frontend
- **Health checks** implementados

### 🎨 Frontend (HTML/CSS/JS)
- **Design moderno** com tema escuro
- **Interface responsiva** mobile-first
- **Animações fluidas** e feedback visual
- **Validação em tempo real** de CEP
- **Auto-busca** quando CEP completo
- **Cópia para clipboard** integrada

## 🚀 Como Executar

### Pré-requisitos
- Docker e Docker Compose
- Navegador moderno
- Python 3.8+ (opcional, para desenvolvimento)

### Opção 1: Docker Compose - Aplicação Completa (Recomendado)

1. **Clone o repositório:**
```bash
git clone <url-do-repositorio>
cd busca_cep
```

2. **Inicie toda a aplicação:**
```bash
docker compose up -d --build
```

3. **Acesse a aplicação:**
   - **Frontend**: http://localhost:3000
   - **Backend API**: http://localhost:8001
   - **Documentação**: http://localhost:8001/docs

### Opção 2: Docker Compose - Serviços Separados

1. **Backend apenas:**
```bash
cd backend
docker compose up -d --build
```

2. **Frontend apenas:**
```bash
cd front-end
docker build -t greglixandrao/busca-cep-frontend .
docker run -d -p 3000:3000 --name busca-cep-frontend greglixandrao/busca-cep-frontend
```

### Opção 2: Desenvolvimento Local

1. **Backend:**
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

2. **Frontend:**
```bash
cd front-end
python -m http.server 3000
```

## 📊 Endpoints da API

### Base URL: `http://localhost:8001/api/v1`

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/cep/{cep}` | Buscar endereço por CEP |
| GET | `/health` | Verificar saúde da API |
| GET | `/` | Informações da API |
| GET | `/docs` | Documentação Swagger |

### Exemplos de Uso

**Buscar CEP:**
```bash
curl http://localhost:8001/api/v1/cep/01310-100
```

**Response:**
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

## 🎯 Funcionalidades

### ✅ Implementadas
- [x] Busca de CEP via API ViaCEP
- [x] Validação de formato de CEP
- [x] Interface responsiva com tema escuro
- [x] Máscara automática de entrada
- [x] Cópia de endereço para clipboard
- [x] Tratamento de erros amigável
- [x] Containerização com Docker
- [x] Documentação automática da API
- [x] Health checks
- [x] CORS configurado
- [x] Loading states e animações

### 🔄 Roadmap Futuro
- [ ] Histórico de buscas
- [ ] Favoritos/salvos
- [ ] PWA (Progressive Web App)
- [ ] Busca reversa (endereço → CEP)
- [ ] Integração com mapas
- [ ] Cache offline
- [ ] Modo claro/escuro toggle
- [ ] Testes automatizados
- [ ] CI/CD pipeline

## 🛠️ Tecnologias Utilizadas

### Backend
- **Python 3.11+** - Linguagem principal
- **FastAPI** - Framework web moderno
- **Uvicorn** - Servidor ASGI
- **httpx** - Cliente HTTP assíncrono
- **Pydantic** - Validação de dados
- **Docker** - Containerização

### Frontend
- **HTML5** - Estrutura semântica
- **CSS3** - Estilos modernos (Grid, Flexbox, Variables)
- **JavaScript ES6+** - Lógica e interatividade
- **Font Awesome** - Ícones
- **Inter Font** - Tipografia
- **Fetch API** - Requisições HTTP

### DevOps & Ferramentas
- **Docker Compose** - Orquestração
- **Git** - Controle de versão
- **VSCode** - Editor recomendado

## 📦 Deploy

### 🏠 Produção Local
```bash
# Aplicação completa
docker compose up -d --build
```

### ☁️ AWS ECS (Produção)

#### Deploy Automatizado com Scripts
```bash
# Deploy completo na AWS
./scripts/deploy.sh

# Destruir infraestrutura
./scripts/destroy.sh
```

#### Deploy com GitHub Actions (CI/CD)
1. Configure secrets no GitHub:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. Push para branch main:
```bash
git push origin main
```

3. Acompanhe o deploy em **Actions**

#### Recursos AWS Criados
- **ECS Cluster** com Fargate
- **Application Load Balancer**
- **ECR Repositories** para imagens
- **VPC** com subnets públicas/privadas
- **CloudWatch Logs**
- **Auto Scaling** configurado

**📚 Documentação Completa**: [AWS Deploy Guide](docs/AWS_DEPLOY.md)

### 🌐 Outras Opções de Deploy
- **Backend**: Railway, Render, Google Cloud Run
- **Frontend**: Netlify, Vercel, GitHub Pages
- **Banco de Dados**: (futuro) RDS, MongoDB Atlas

## 🧪 Testes

### Testes Manuais
1. Abra http://localhost:3000
2. Teste CEPs válidos: `01310-100`, `20040-020`
3. Teste CEPs inválidos: `00000-000`, `123`
4. Teste responsividade em diferentes telas
5. Teste cópia para clipboard
6. Teste estados de loading

### CEPs para Teste
- `01310-100` - Avenida Paulista, São Paulo/SP
- `20040-020` - Centro, Rio de Janeiro/RJ
- `30112-000` - Centro, Belo Horizonte/MG
- `40070-110` - Centro, Salvador/BA
- `80010-000` - Centro, Curitiba/PR

## 📈 Performance

### Métricas Alvo
- **Backend**: < 200ms tempo de resposta
- **Frontend**: < 2s carregamento inicial
- **Lighthouse Score**: > 90 em todas as métricas

### Otimizações Implementadas
- CSS e JS minificados
- Imagens otimizadas
- Fontes pré-carregadas
- Lazy loading onde aplicável
- Cache headers configurados

## 🔒 Segurança

### Medidas Implementadas
- Input sanitization no frontend
- Validação robusta no backend
- CORS configurado adequadamente
- Headers de segurança
- Rate limiting (recomendado)

### Recomendações de Produção
- Usar HTTPS em produção
- Implementar rate limiting
- Monitoramento e logs
- Backup regular
- Atualizações de segurança

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch: `git checkout -b feature/nova-feature`
3. Commit: `git commit -m 'Adiciona nova feature'`
4. Push: `git push origin feature/nova-feature`
5. Abra um Pull Request

### Padrões de Código
- Backend: PEP 8, type hints, docstrings
- Frontend: ES6+, comments em português
- Commits: Conventional Commits

## 📄 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Desenvolvedor

**Greg Lixandrão**
- GitHub: [@greglixandrao](https://github.com/greglixandrao)
- Email: dev@exemplo.com

## 📞 Suporte

- 📧 Email: suporte@exemplo.com
- 🐛 Issues: [GitHub Issues](https://github.com/seu-usuario/busca-cep/issues)
- 📖 Docs: [Documentação Completa](link-para-docs)

---

⭐ Se este projeto foi útil, não esqueça de dar uma star!

Desenvolvido com ❤️ no Brasil 🇧🇷
