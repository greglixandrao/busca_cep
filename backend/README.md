# API de Busca de CEP

Uma API simples e eficiente para buscar endereços brasileiros através do CEP, utilizando a API do ViaCEP.

## 🚀 Tecnologias

- **Python 3.8+**
- **FastAPI** - Framework web moderno e rápido
- **Uvicorn** - Servidor ASGI
- **httpx** - Cliente HTTP assíncrono
- **Pydantic** - Validação de dados

## 📁 Estrutura do Projeto

```
backend/
├── app/
│   ├── models/
│   │   ├── __init__.py
│   │   └── cep.py          # Modelos Pydantic
│   ├── routers/
│   │   ├── __init__.py
│   │   └── cep.py          # Endpoints da API
│   ├── services/
│   │   ├── __init__.py
│   │   └── viacep_service.py  # Integração com ViaCEP
│   ├── __init__.py
│   ├── config.py           # Configurações
│   └── main.py            # Aplicação principal
├── tests/
├── .dockerignore          # Arquivos ignorados pelo Docker
├── .env                   # Variáveis de ambiente
├── docker-compose.yml     # Configuração Docker Compose
├── Dockerfile            # Imagem Docker
├── requirements.txt      # Dependências
└── README.md
```

## 🔧 Instalação

1. **Clone o repositório:**
```bash
git clone <url-do-repositorio>
cd busca_cep/backend
```

2. **Crie um ambiente virtual:**
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows
```

3. **Instale as dependências:**
```bash
pip install -r requirements.txt
```

4. **Configure as variáveis de ambiente:**
O arquivo `.env` já está configurado com valores padrão. Ajuste se necessário.

## 🚀 Executando a Aplicação

### Modo de desenvolvimento:
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Ou execute diretamente:
```bash
python -m app.main
```

A API estará disponível em: `http://localhost:8000`

## 🐳 Executando com Docker

### Opção 1: Docker Compose (Recomendado)

1. **Execute com docker compose:**
```bash
docker compose up --build
```

2. **Para executar em background:**
```bash
docker compose up -d --build
```

3. **Para parar os containers:**
```bash
docker compose down
```

### Opção 2: Docker direto

1. **Construir a imagem:**
```bash
docker build -t greglixandrao/busca-cep-api .
```

2. **Executar o container:**
```bash
docker run -d -p 8000:8000 --name busca-cep-container greglixandrao/busca-cep-api
```

3. **Ver logs do container:**
```bash
docker logs busca-cep-container
```

4. **Parar o container:**
```bash
docker stop busca-cep-container
docker rm busca-cep-container
```

### 📦 Publicar no Docker Hub

1. **Login no Docker Hub:**
```bash
docker login
```

2. **Fazer push da imagem:**
```bash
docker push greglixandrao/busca-cep-api:latest
```

3. **Usar imagem do Docker Hub:**
```bash
docker run -d -p 8000:8000 --name busca-cep-container greglixandrao/busca-cep-api:latest
```

A API estará disponível em: `http://localhost:8000`

## 📚 Documentação da API

Após iniciar o servidor, acesse:

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

## 🔍 Endpoints

### GET `/api/v1/cep/{cep}`
Busca informações de endereço pelo CEP.

**Parâmetros:**
- `cep`: CEP no formato `12345678` ou `12345-678`

**Exemplo de requisição:**
```bash
curl http://localhost:8000/api/v1/cep/01310-100
```

**Exemplo de resposta:**
```json
{
  "cep": "01310-100",
  "logradouro": "Avenida Paulista",
  "complemento": "",
  "bairro": "Bela Vista",
  "localidade": "São Paulo",
  "uf": "SP"
}
```

### GET `/api/v1/health`
Verifica se a API está funcionando.

**Exemplo de resposta:**
```json
{
  "status": "ok",
  "message": "API de busca de CEP funcionando"
}
```

## ⚠️ Tratamento de Erros

A API retorna os seguintes códigos de erro:

- **400**: CEP inválido (formato incorreto)
- **404**: CEP não encontrado
- **500**: Erro interno do servidor

**Exemplo de erro:**
```json
{
  "detail": "CEP não encontrado"
}
```

## 🔧 Configurações

As configurações podem ser alteradas no arquivo `.env`:

```env
APP_NAME=API de Busca de CEP
APP_VERSION=1.0.0
DEBUG=True
HOST=0.0.0.0
PORT=8000
VIACEP_BASE_URL=https://viacep.com.br/ws
VIACEP_TIMEOUT=10
```

## 🧪 Testes

Para executar os testes (quando implementados):
```bash
pytest
```

## 📝 Licença

Este projeto está sob a licença MIT.

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request
